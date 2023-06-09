const http = require('http');
const fs = require('fs');
const url = require('url');

var server = http.createServer(async (req: any, res: any) => {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    const _url = req.url == "/" ? "/index.html" : req.url;
    const urlObj = url.parse(_url, true);
    fs.readFile('./public' + urlObj.pathname, (err: any, data: any) => {
        if (err) {
            res.writeHead(404);
            res.write('File Not Found');
        }
        else {
            res.write(data);
        }
        res.end();
    });
});

server.listen(5000);

console.log('Server at port 5000 is running')