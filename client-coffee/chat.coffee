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
    post 'wait for name to be set...'
    socket.emit 'set name', name, ->
      console.log 'name set to ' + name
      post 'you are ' + name + '.'
      post 'type to talk.'
      socket.on 'chat msg', (msgobj) ->
        console.log 'received message object', msgobj
        post msgobj.sender + ' says "' + msgobj.msg + '"'
      # socket.on 'chat msg', ->
      onInput = chat
  
  chat = (msg) ->
    socket.emit 'chat msg', {msg: msg}
  
  # transport
  post 'awaiting socket...'
  
  socket = io.connect()
  
  socket.on 'connect', ->
    post 'socket connected.'
    post 'enter name:'
    onInput = getName
  
  socket.on 'disconnect', ->
    post 'socket disconnected.'
    onInput = ->
