import * as http from 'http'
import * as httpProxy from 'http-proxy'

const PORT = 9090

console.log(`YNAB API Proxy listening at http://localhost:${PORT}`)

const setCORSHeaders = (res: http.ServerResponse) => {
  res.setHeader('Access-Control-Allow-Origin', '*')
  res.setHeader('Access-Control-Allow-Headers', '*')
  res.setHeader('Access-Control-Allow-Methods', '*')
}

const proxy = httpProxy
  .createServer({
    changeOrigin: true,
    target: 'https://api.youneedabudget.com:443/'
  })
  .on('proxyRes', (_proxyRes, _req, res) => {
    setCORSHeaders(res)
  })

http
  .createServer((req, res) => {
    if (req.method === 'OPTIONS') {
      setCORSHeaders(res)
      res.statusCode = 200
      res.end()
    } else {
      proxy.web(req, res)
    }
  })
  .listen(PORT)
