module.exports = (app) ->
  io = (require 'socket.io').listen app
  io.set 'log level', 1
  
  io.sockets.on 'connection', (socket) ->
    console.log 'socket connected'
    socket.on 'set name', (name, cb) ->
      user = app.users.join {
        name: name,
        send: (msgObj) -> socket.emit 'chat msg', msgObj}
      
      console.log 'user created from socket named ' + user.name
      
      socket.on 'chat msg', (msgObj) ->
        console.log 'chat message from socket of user named ' + user.name + ' -> ' + msgObj.msg
        app.users.recvMsg user, msgObj
      
      socket.on 'disconnect', ->
        console.log 'socket disconnected of user named ' + user.name
        app.users.leave user
      
      cb?()
