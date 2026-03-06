const http = require('http');
const os = require('os');

const PORT = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  const now = new Date().toISOString();
  const body = JSON.stringify({
    message: 'Hello, World! 🚀',
    hostname: os.hostname(),
    timestamp: now,
    path: req.url,
  }, null, 2);

  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(body);
});

server.listen(PORT, () => {
  console.log(`[${new Date().toISOString()}] Server running on http://0.0.0.0:${PORT}`);
});
