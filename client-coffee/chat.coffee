plantTimeout  = (ms, cb) -> setTimeout  cb, ms
plantInterval = (ms, cb) -> setInterval cb, ms

API_PREFIX = '/api/0.1'

console.log 'hi! chat.coffee has loaded.'

$ ->
  console.log 'chat.coffee is running under jquery after the dom'
  
  
  # DOM Setup
  $output = $ '.chat-log'
  $input = $ '.chat-input'
  
  post = (msg) ->
    $output.append (msg+'\n').replace /(\r\n|\n|\r)/gm, '<br>'
    $output.prop { scrollTop: $output.prop 'scrollHeight' }
  
  onInput = ->
  $input.change ->
    v = $input.val()
    post '\n-- ' + v + '\n'
    $input.val ''
    onInput? v
  
  
  # states
  getName = (name) ->
    onInput = ->
    console.log 'setting name to ' + name
    socket.emit 'set name', name
    post 'type to talk.'
    onInput = chat
    socket.on 'chat msg', (msgobj) ->
      post msgobj.sender + ' says "' + msgobj.msg + '"'
  
  chat = (msg) ->
    socket.emit 'chat msg', {msg: msg}
  
  # Transport
  post 'awaiting socket...'
  
  socket = io.connect()
  
  socket.on 'connect', ->
    post 'socket connected'
    console.log socket
    post 'enter name.'
    onInput = getName
  
  socket.on 'disconnect', ->
    post 'socket disconnected'
