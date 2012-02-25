module.exports = (app) ->
  io = (require 'socket.io').listen app
  
  io.sockets.on 'connection', (socket) ->
    console.log 'socket connected'
    socket.on 'set name', (name) ->
      user = app.users.join {
        name: name,
        uniq: socket,
        send: (msgObj) -> socket.emit 'chat msg', msgObj}
      socket.on 'chat msg', (msgObj) ->
        console.log user.name + ' -> ' + msgObj.msg
        app.users.recvMsg user, msgObj.msg
