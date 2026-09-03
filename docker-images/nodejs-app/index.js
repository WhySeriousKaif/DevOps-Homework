const http = require('http');

const PORT = 3000;
const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end('<!DOCTYPE html><html><head><title>Node.js App</title></head><body style="font-family:sans-serif;text-align:center;padding:50px;"><h1>Hello World from Node.js!</h1><p>Running inside a Docker container</p></body></html>');
});

server.listen(PORT, '0.0.0.0', () => {
    console.log(`Node.js server running on port ${PORT}`);
});
