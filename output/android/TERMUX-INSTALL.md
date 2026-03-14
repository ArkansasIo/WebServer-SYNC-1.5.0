# Termux Installation Instructions

To build and install WebServer SYNC from GitHub using Cargo, follow these steps:

1. Install necessary packages:
   ```bash
   pkg install git curl
   ```
2. Install Rust via rustup:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```
3. Clone the repository:
   ```bash
   git clone https://github.com/ArkansasIo/WebServer-SYNC-1.5.0.git
   cd WebServer-SYNC-1.5.0
   ```
4. Build the application:
   ```bash
   cargo build --release
   ```
5. Run the server on port 4090:
   ```bash
   ./target/release/webserver_sync --port 4090
   ```
6. To open the panel, go to:
   http://localhost:4090/~~penguin/panel
