plantTimeout  = (ms, cb) -> setTimeout  cb, ms
plantInterval = (ms, cb) -> setInterval cb, ms

API_PREFIX = '/api/0.1'

$ ->
  client =
    sock: io.connect document.domain + API_PREFIX + '/socks/observe'
  
  client.sock.on 'connect', -> console.log 'socket connected'
  client.sock.on 'disconnect', -> console.log 'socket disconnected'
  client.sock.on 'msg', (msg) -> console.log 'received message', msg  
