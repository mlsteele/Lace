plantTimeout  = (ms, cb) -> setTimeout  cb, ms
plantInterval = (ms, cb) -> setInterval cb, ms

API_PREFIX = '/api/0.1'

console.log 'hi! chat.coffee has loaded.'

$ ->
  console.log 'chat.coffee is running under jquery after the dom'
  
  client = {}
  
  
  # DOM Setup
  $output = $ '.chat-log'
  $input = $ '.chat-input'
  $userlist = $ '.chat-userlist'
  
  post = (msg) ->
    $output.append (msg+'\n').replace /(\r\n|\n|\r)/gm, '<br>'
    $output.prop { scrollTop: $output.prop 'scrollHeight' }
  
  onInput = null
  $input.change ->
    v = $input.val()
    $input.val ''
    if onInput?
      post '\n-- ' + v + '\n'
      onInput? v
  
  updateUserList = (users) ->
    console.log 'updating user list to', users
    $userlist.children().remove()
    for lu in (_.filter users, (u) -> console.log client.activeUser, u; u.uniq isnt client.activeUser.uniq)
      $userlist.append ($ '<li>', text: lu.name + ' (' + lu.uniq + ')').data('user', lu)
  
  
  # transport
  post 'awaiting socket...'
  client.activeUser = null
  client.sock = io.connect()
  
  client.sock.on 'connect', ->
    post 'socket connected.'
    post 'enter name:'
    onInput = getName
  
  client.sock.on 'disconnect', ->
    post 'socket disconnected.'
    client.sock.removeAllListeners e for e in ['chat msg', 'chat list']
    activeUser = null
    onInput = null
  
  # states
  getName = (name) ->
    post 'waiting for server to acknowledge...'
    client.sock.emit 'set name', name, wereIn
  
  wereIn = (user) ->
    activeUser = user
    console.log 'name set to ' + user.name
    post 'you are ' + user.name + '.'
    post 'type to talk.'
    client.sock.on 'chat msg', (msg) ->
      console.log 'received message object', msg
      post msg.sender.name + ' (' + msg.sender.uniq + ') says "' + msg.msg + '"'
    client.sock.on 'chat list', (list) ->
      post 'user action: "' + list.delta.user.name + '" ' + list.delta.state
      updateUserList list.users
    onInput = chat
  
  chat = (msg) ->
    client.sock.emit 'chat msg', {msg: msg}
