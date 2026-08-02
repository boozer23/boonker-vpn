# Boonker backend contract

The iOS client expects JSON over HTTPS. All endpoints use the `/v1` prefix.

## `POST /v1/auth/login`

Request:

```json
{"email":"user@example.com","password":"secret"}
```

Response `200`:

```json
{"accessToken":"eyJ..."}
```

## `GET /v1/locations`

The optional `Authorization: Bearer <token>` header enables premium locations.

Response `200`:

```json
[
  {
    "id":"de",
    "country":"Germany",
    "countryCode":"DE",
    "flag":"🇩🇪",
    "cities":[
      {
        "id":"de-berlin-s1",
        "city":"Berlin",
        "node":"S1",
        "pingMS":28,
        "loadPercent":23,
        "endpoint":"de-berlin-1.boonker.net:51820",
        "serverPublicKey":"base64-public-key"
      }
    ]
  }
]
```

## `POST /v1/tunnels/config`

Creates a short-lived device configuration for a selected node. The private key
must be generated on the device and never sent to the backend.

Request:

```json
{"nodeId":"de-berlin-s1","publicKey":"base64-device-public-key"}
```

Response `200`:

```json
{
  "nodeId":"de-berlin-s1",
  "address":"10.8.0.42/32",
  "dns":["1.1.1.1"],
  "server":"de-berlin-1.boonker.net:51820",
  "serverPublicKey":"base64-public-key",
  "allowedIPs":["0.0.0.0/0","::/0"],
  "expiresAt":"2026-08-03T20:00:00Z"
}
```

The Packet Tunnel must reject expired configurations and configurations with a
missing key, endpoint, address, or allowed route before applying network settings.

## Status codes

- `200`: successful request
- `401`: missing or expired session
- `403`: premium feature is unavailable for the current plan
- `404`: location or node no longer exists
- `409`: another device configuration is active
- `429`: rate limit reached
- `5xx`: temporary service failure
