import http from "node:http";

const port = Number(process.env.PORT || 8787);
const demoEmail = process.env.DEMO_EMAIL || "demo@boonker.test";
const demoPassword = process.env.DEMO_PASSWORD || "demo-password";
const publicKey = process.env.SERVER_PUBLIC_KEY || "replace-with-wireguard-server-public-key";
const tunnelAddress = process.env.TUNNEL_ADDRESS || "10.8.0.42/32";
const tunnelServer = process.env.TUNNEL_SERVER || "de-berlin-1.boonker.test:51820";

const locations = [
  {
    id: "de",
    country: "Germany",
    countryCode: "DE",
    flag: "🇩🇪",
    cities: [
      { id: "de-berlin-s1", city: "Berlin", node: "S1", pingMS: 28, loadPercent: 23, endpoint: tunnelServer, serverPublicKey: publicKey },
      { id: "de-munich-s2", city: "Munich", node: "S2", pingMS: 32, loadPercent: 41, endpoint: tunnelServer, serverPublicKey: publicKey }
    ]
  },
  {
    id: "us",
    country: "United States",
    countryCode: "US",
    flag: "🇺🇸",
    cities: [
      { id: "us-new-york-s1", city: "New York", node: "S1", pingMS: 24, loadPercent: 23, endpoint: "us-new-york-1.boonker.test:51820", serverPublicKey: publicKey }
    ]
  }
];

function json(response, status, body) {
  response.writeHead(status, {
    "content-type": "application/json; charset=utf-8",
    "cache-control": "no-store",
    "access-control-allow-origin": "*"
  });
  response.end(JSON.stringify(body));
}

async function readBody(request) {
  let raw = "";
  for await (const chunk of request) raw += chunk;
  return raw ? JSON.parse(raw) : {};
}

function isAuthorized(request) {
  return request.headers.authorization === "Bearer demo-access-token";
}

const server = http.createServer(async (request, response) => {
  if (request.method === "OPTIONS") {
    response.writeHead(204, {
      "access-control-allow-origin": "*",
      "access-control-allow-methods": "GET,POST,OPTIONS",
      "access-control-allow-headers": "authorization,content-type"
    });
    return response.end();
  }

  try {
    if (request.method === "GET" && request.url === "/health") {
      return json(response, 200, { ok: true, environment: "demo" });
    }

    if (request.method === "POST" && request.url === "/v1/auth/login") {
      const body = await readBody(request);
      if (body.email !== demoEmail || body.password !== demoPassword) {
        return json(response, 401, { error: "unauthorized" });
      }
      return json(response, 200, { accessToken: "demo-access-token" });
    }

    if (request.method === "GET" && request.url === "/v1/locations") {
      return json(response, 200, locations);
    }

    if (request.method === "POST" && request.url === "/v1/tunnels/config") {
      if (!isAuthorized(request)) return json(response, 401, { error: "unauthorized" });
      const body = await readBody(request);
      const node = locations.flatMap((location) => location.cities).find((item) => item.id === body.nodeId);
      if (!node) return json(response, 404, { error: "node_not_found" });
      if (!body.publicKey) return json(response, 400, { error: "public_key_required" });

      return json(response, 200, {
        nodeID: node.id,
        address: tunnelAddress,
        dns: ["1.1.1.1"],
        server: node.endpoint,
        serverPublicKey: node.serverPublicKey,
        allowedIPs: ["0.0.0.0/0", "::/0"],
        expiresAt: new Date(Date.now() + 60 * 60 * 1000).toISOString()
      });
    }

    return json(response, 404, { error: "not_found" });
  } catch (error) {
    console.error(error);
    return json(response, 400, { error: "invalid_request" });
  }
});

server.listen(port, () => {
  console.log(`Boonker demo API listening on http://localhost:${port}`);
});
