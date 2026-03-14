use std::{convert::Infallible, future::Future, panic::AssertUnwindSafe, sync::Arc};

use futures::FutureExt;
use hyper::{
    Body, Method, Request, Response, Server, StatusCode,
    http::uri::PathAndQuery,
    service::{make_service_fn, service_fn},
};
use tokio::sync::broadcast::Sender;

use crate::serve::proxy::ProxyContext;
use super::{Action, Config};

mod fs;
mod proxy;


pub(crate) async fn run(config: Config, actions: Sender<Action>) -> Result<(), hyper::Error> {
    let addr = config.bind_addr;

    let ctx = Arc::new(Context {
        config,
        proxy: ProxyContext::new(),
    });
    let actions_for_service = actions.clone();
    let make_service = make_service_fn(move |_| {
        let ctx = Arc::clone(&ctx);
        let actions = actions_for_service.clone();

        async {
            Ok::<_, Infallible>(service_fn(move |req| {
                handle_internal_errors(
                    handle(req, Arc::clone(&ctx), actions.clone())
                )
            }))
        }
    });

    log::info!("Creating hyper server");
    let server = Server::try_bind(&addr)?.serve(make_service);
    let mut shutdown_rx = actions.subscribe();
    let server = server.with_graceful_shutdown(async move {
        loop {
            match shutdown_rx.recv().await {
                Ok(Action::Shutdown) => break,
                Ok(_) => {}
                Err(_) => break,
            }
        }
    });

    log::info!("Start listening with hyper server");
    server.await?;

    Ok(())
}

async fn handle_internal_errors(
    future: impl Future<Output = Response<Body>>,
) -> Result<Response<Body>, Infallible> {
    fn internal_server_error(msg: &str) -> Response<Body> {
        let body = format!("Internal server error: this is a bug in WebServer SYNC 1.5.0!\n\n{}\n", msg);
        Response::builder()
            .status(StatusCode::INTERNAL_SERVER_ERROR)
            .header("Server", SERVER_HEADER)
            .body(body.into())
            .unwrap()
    }

    // The `AssertUnwindSafe` is unfortunately necessary. The whole story of
    // unwind safety is strange. What we are basically saying here is: "if the
    // future panicks, the global/remaining application state is not 'broken'.
    // It is safe to continue with the program in case of a panic."
    match AssertUnwindSafe(future).catch_unwind().await {
        Ok(response) => Ok(response),
        Err(panic) => {
            // The `panic` information is just an `Any` object representing the
            // value the panic was invoked with. For most panics (which use
            // `panic!` like `println!`), this is either `&str` or `String`.
            let msg = panic.downcast_ref::<String>()
                .map(|s| s.as_str())
                .or(panic.downcast_ref::<&str>().copied());

            log::error!("HTTP handler panicked: {}", msg.unwrap_or("-"));

            Ok(internal_server_error(msg.unwrap_or("panic")))
        }
    }
}

pub(crate) struct Context {
    config: Config,
    proxy: ProxyContext,
}

/// Handles a single incoming request.
async fn handle(
    req: Request<Body>,
    ctx: Arc<Context>,
    actions: Sender<Action>,
) -> Response<Body> {
    log::trace!(
        "Incoming request: {:?} {}",
        req.method(),
        req.uri().path_and_query().unwrap_or(&PathAndQuery::from_static("/")),
    );

    if req.uri().path().starts_with(&ctx.config.control_path) {
        handle_control(req, &ctx.config, actions).await
    } else if let Some(response) = fs::try_serve(&req, &ctx.config).await {
        response
    } else if let Some(proxy) = &ctx.config.proxy {
        proxy::forward(req, proxy, &ctx, actions).await
    } else {
        not_found(&ctx.config)
    }
}

/// Handles "control requests", i.e. request to the control path.
async fn handle_control(
    req: Request<Body>,
    config: &Config,
    actions: Sender<Action>,
) -> Response<Body> {
    log::trace!("Handling request to HTTP control API...");

    if hyper_tungstenite::is_upgrade_request(&req) {
        log::trace!("Handling WS upgrade request...");
        match hyper_tungstenite::upgrade(req, None) {
            Ok((response, websocket)) => {
                // Spawn a task to handle the websocket connection.
                let receiver = actions.subscribe();
                tokio::spawn(crate::ws::handle_connection(websocket, receiver));

                // Return the response so the spawned future can continue.
                response
            }
            Err(_) => {
                log::warn!("Invalid WS upgrade request");
                bad_request("Failed to upgrade to WS connection\n")
            }
        }
    } else {
        let subpath = req.uri().path().strip_prefix(&config.control_path).unwrap();
        match (req.method(), subpath) {
            (&Method::GET, "/api/v1") => {
                ok_json("{\"name\":\"WebServer SYNC 1.5.0 API\",\"version\":\"v1\"}".to_owned())
            }

            (&Method::GET, "/api/v1/status") => {
                ok_json(control_status_json(config))
            }

            (&Method::POST, "/api/v1/reload") => {
                log::debug!("Received reload request via app API");
                let _ = actions.send(Action::Reload);

                accepted_action_json("reload")
            }

            (&Method::POST, "/api/v1/message") => {
                let (_, body) = req.into_parts();
                let body = hyper::body::to_bytes(body)
                    .await
                    .expect("failed to download message body");

                match std::str::from_utf8(&body) {
                    Err(_) => bad_request("Bad request: request body is not UTF8\n"),
                    Ok(s) => {
                        log::debug!("Received message request via app API");
                        let _ = actions.send(Action::Message(s.into()));

                        accepted_action_json("message")
                    }
                }
            }

            (&Method::POST, "/api/v1/shutdown") => {
                log::info!("Received shutdown request via app API");
                let _ = actions.send(Action::Shutdown);

                accepted_action_json("shutdown")
            }

            (&Method::GET, "") | (&Method::GET, "/") | (&Method::GET, "/panel") => {
                let html = control_panel_html(config);
                Response::builder()
                    .header("Content-Type", "text/html; charset=UTF-8")
                    .header("Server", SERVER_HEADER)
                    .body(html.into())
                    .unwrap()
            }

            (&Method::GET, "/status") => {
                let body = control_status_json(config);
                Response::builder()
                    .header("Content-Type", "application/json; charset=UTF-8")
                    .header("Cache-Control", "no-store")
                    .header("Server", SERVER_HEADER)
                    .body(body.into())
                    .unwrap()
            }

            (&Method::GET, "/client.js") => {
                Response::builder()
                    .header("Content-Type", "application/javascript; charset=UTF-8")
                    .body(Body::from(crate::inject::script(config)))
                    .unwrap()
            }

            (&Method::POST, "/reload") => {
                // We ignore errors here: if there are no receivers, so be it.
                // Although we might want to include the number of receivers in
                // the event.
                log::debug!("Received reload request via HTTP control API");
                let _ = actions.send(Action::Reload);

                Response::new(Body::empty())
            }

            (&Method::POST, "/message") => {
                let (_, body) = req.into_parts();
                let body = hyper::body::to_bytes(body)
                    .await
                    .expect("failed to download message body");

                match std::str::from_utf8(&body) {
                    Err(_) => bad_request("Bad request: request body is not UTF8\n"),
                    Ok(s) => {
                        // We ignore errors here: if there are no receivers, so be it.
                        // Although we might want to include the number of receivers in
                        // the event.
                        log::debug!("Received message request via HTTP control API");
                        let _ = actions.send(Action::Message(s.into()));

                        Response::new(Body::empty())
                    }
                }
            }

            (&Method::POST, "/shutdown") => {
                log::info!("Received shutdown request via HTTP control API");
                let _ = actions.send(Action::Shutdown);

                Response::builder()
                    .status(StatusCode::ACCEPTED)
                    .body(Body::empty())
                    .unwrap()
            }

            _ => bad_request("Invalid request to WebServer SYNC 1.5.0 control path\n"),
        }
    }
}

fn control_panel_html(config: &Config) -> String {
    const CONTROL_PANEL_HTML: &str = include_str!("../assets/control-panel.html");

    let mounts = if config.mounts().is_empty() {
        "<li>None</li>".to_owned()
    } else {
        config.mounts().iter().map(|mount| {
            format!(
                "<li><code>{}</code> → <code>{}</code></li>",
                escape_html(&mount.uri_path),
                escape_html(&mount.fs_path.display().to_string()),
            )
        }).collect::<Vec<_>>().join("")
    };

    let public_url = config.public_authority()
        .map(|authority| format!("http://{}", authority))
        .unwrap_or_else(|| format!("http://{}", config.bind_addr));

    let proxy = config.proxy()
        .map(|target| target.to_string())
        .unwrap_or_else(|| "None".to_owned());

    CONTROL_PANEL_HTML
        .replace("{{ control_path }}", config.control_path())
        .replace("{{ public_url }}", &escape_html(&public_url))
        .replace("{{ bind_addr }}", &escape_html(&config.bind_addr.to_string()))
        .replace("{{ proxy_target }}", &escape_html(&proxy))
        .replace("{{ mounts_list }}", &mounts)
}

fn control_status_json(config: &Config) -> String {
    let mounts = config.mounts().iter().map(|mount| {
        format!(
            "{{\"uri_path\":\"{}\",\"fs_path\":\"{}\"}}",
            escape_json(&mount.uri_path),
            escape_json(&mount.fs_path.display().to_string()),
        )
    }).collect::<Vec<_>>().join(",");

    let public_url = config.public_authority()
        .map(|authority| format!("http://{}", authority))
        .unwrap_or_else(|| format!("http://{}", config.bind_addr));

    format!(
        "{{\"name\":\"WebServer SYNC 1.5.0\",\"bind_addr\":\"{}\",\"public_url\":\"{}\",\"control_path\":\"{}\",\"proxy\":{},\"mounts\":[{}]}}",
        escape_json(&config.bind_addr.to_string()),
        escape_json(&public_url),
        escape_json(config.control_path()),
        config.proxy().map(|target| format!("\"{}\"", escape_json(&target.to_string()))).unwrap_or_else(|| "null".to_owned()),
        mounts,
    )
}

fn escape_html(input: &str) -> String {
    input
        .replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
        .replace('"', "&quot;")
        .replace('\'', "&#39;")
}

fn escape_json(input: &str) -> String {
    let mut out = String::with_capacity(input.len());
    for c in input.chars() {
        match c {
            '"' => out.push_str("\\\""),
            '\\' => out.push_str("\\\\"),
            '\n' => out.push_str("\\n"),
            '\r' => out.push_str("\\r"),
            '\t' => out.push_str("\\t"),
            c if c.is_control() => out.push_str(&format!("\\u{:04x}", c as u32)),
            _ => out.push(c),
        }
    }
    out
}

fn ok_json(body: String) -> Response<Body> {
    Response::builder()
        .status(StatusCode::OK)
        .header("Content-Type", "application/json; charset=UTF-8")
        .header("Cache-Control", "no-store")
        .header("Server", SERVER_HEADER)
        .body(body.into())
        .expect("bug: invalid response")
}

fn accepted_action_json(action: &str) -> Response<Body> {
    let body = format!("{{\"ok\":true,\"action\":\"{}\"}}", escape_json(action));

    Response::builder()
        .status(StatusCode::ACCEPTED)
        .header("Content-Type", "application/json; charset=UTF-8")
        .header("Cache-Control", "no-store")
        .header("Server", SERVER_HEADER)
        .body(body.into())
        .expect("bug: invalid response")
}

fn bad_request(msg: &'static str) -> Response<Body> {
    log::debug!("Replying BAD REQUEST: {}", msg);

    Response::builder()
        .status(StatusCode::BAD_REQUEST)
        .header("Server", SERVER_HEADER)
        .body(msg.into())
        .expect("bug: invalid response")
}

fn not_found(config: &Config) -> Response<Body> {
    const NOT_FOUND_HTML: &str = include_str!("../assets/not-found.html");

    log::debug!("Responding with 404 NOT FOUND");
    let html = NOT_FOUND_HTML.replace("{{ control_path }}", config.control_path());

    Response::builder()
        .status(StatusCode::NOT_FOUND)
        .header("Content-Type", "text/html")
        .header("Content-Length", html.len().to_string())
        .header("Server", SERVER_HEADER)
        .body(html.into())
        .expect("bug: invalid response")
}

const SERVER_HEADER: &str = concat!("WebServer SYNC ", env!("CARGO_PKG_VERSION"));
