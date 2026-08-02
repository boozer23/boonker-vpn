# Boonker VPN

Mobile-first VPN prototype for iOS with the Boonker interface.

## Included

- Interactive server picker with country and city selection
- All, Favorites, and Recent server tabs
- Search by country or city
- Best-ping route selection
- Connection state, protocol selection, metrics, and protection controls
- Account, sign-in, plans, and premium prototype flows
- SwiftUI/Xcode shell with a full-screen bundled web interface
- Packet Tunnel extension scaffold and backend API contract

## Run the web prototype

Open `outputs/vpn-prototype.html` in a browser, or serve the project directory with any static web server.

## Build the iOS shell

From the project root:

```sh
./ios/build.sh
```

The script syncs the web prototype into the Xcode bundle, validates the expected UI hooks, and runs an unsigned simulator build.

## Current scope

This repository is a functional UI prototype and iOS integration scaffold. A production VPN still needs a backend deployment, real WireGuard/Packet Tunnel configuration, secure authentication, StoreKit purchase handling, telemetry, and release signing.

## License

Private project. All rights reserved.
