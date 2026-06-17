const http = require('http');
const os = require('os');
http.createServer((req, res) => {
    // We add a custom header and body to prove exactly who served it
    res.setHeader('X-Backend-Server', os.hostname());
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end(`Processed by App Replica: ${os.hostname()}\n`);
}).listen(8080);
