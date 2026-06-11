const fs = require('fs');
const http = require('http');
const path = require('path');

const root = path.resolve(__dirname, '..', 'mobile', 'build', 'web');
const port = Number(process.env.PORT || 8095);

const contentTypes = {
  '.css': 'text/css;charset=utf-8',
  '.html': 'text/html;charset=utf-8',
  '.ico': 'image/x-icon',
  '.js': 'text/javascript;charset=utf-8',
  '.json': 'application/json;charset=utf-8',
  '.png': 'image/png',
  '.svg': 'image/svg+xml',
  '.wasm': 'application/wasm',
};

http
  .createServer((request, response) => {
    const pathname = decodeURIComponent(request.url.split('?')[0]);
    const target = pathname === '/' ? '/index.html' : pathname;
    const filePath = path.resolve(root, `.${target}`);

    if (!filePath.startsWith(root)) {
      response.writeHead(403);
      response.end('Forbidden');
      return;
    }

    fs.readFile(filePath, (error, data) => {
      if (error) {
        fs.readFile(path.join(root, 'index.html'), (fallbackError, fallback) => {
          if (fallbackError) {
            response.writeHead(404);
            response.end('Not found');
            return;
          }

          response.writeHead(200, { 'Content-Type': contentTypes['.html'] });
          response.end(fallback);
        });
        return;
      }

      response.writeHead(200, {
        'Content-Type':
          contentTypes[path.extname(filePath)] || 'application/octet-stream',
      });
      response.end(data);
    });
  })
  .listen(port, '127.0.0.1', () => {
    console.log(`Potatos preview http://127.0.0.1:${port}`);
  });
