plantTimeout  = (ms, cb) -> setTimeout  cb, ms
plantInterval = (ms, cb) -> setInterval cb, ms

API_PREFIX = '/api/0.1'

console.log 'hi! chat.coffee has loaded.'

$ ->
  console.log 'chat.coffee is running under jquery after the dom'
  client = {}
  
  # DOM Setup
  $output = $ '.chat-log'
  $input = ($ '.chat-input').focus()
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
  
  clearUserList = -> $userlist.children().remove()
  
  updateUserList = (users) ->
    if !client.activeUser? then throw 'tried to updateUserList with no activeUser'
    console.log 'updating user list to', users
    clearUserList()
    for lu in (_.filter users, (u) -> u.uniq isnt client.activeUser.uniq)
      li = ($ '<li>', text: lu.name + ' (' + lu.uniq + ')').data('user', lu)
      $userlist.append li
      li.click ->
        client.sendingTo = li.data().user
        li.css 'background-color': '#ADF9FF'
        console.log 'clicked on', li
        $input.focus()
    selectedLi = $ _.detect $userlist.children(), (li) -> $(li).data().user.uniq is client.sendingTo?.uniq
    if !selectedLi?.click()?
      console.log 'nullifying client.sendingTo'
      client.sendingTo = null
    else
      console.log 'selectedLi set to', selectedLi
  
  
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
    client.activeUser = null
    client.sendingTo = null
    clearUserList()
    onInput = null
  
  # states
  getName = (name) ->
    post 'waiting for server to acknowledge...'
    client.sock.emit 'set name', name, beUser
  
  beUser = (user) ->
    if !user? then throw 'server answer set name request with no user'
    client.activeUser = user
    console.log 'name set to ' + user.name
    post 'you are ' + user.name + '.'
    post 'type to talk.'
    client.sock.on 'chat msg', (msg) ->
      if !client.activeUser? then throw 'tried to process chat msg without an activeUser'
      console.log 'received message object', msg
      post msg.from.name + ' (' + msg.from.uniq + ') says "' + msg.msg + '"'
    client.sock.on 'chat list', (list) ->
      if !client.activeUser? then throw 'tried to process a chat list msg without an activeUser'
      post 'user action: "' + list.delta.user.name + '" ' + list.delta.state
      updateUserList list.users
    onInput = chat
  
  chat = (msg) ->
    if !client.activeUser? then throw 'tried to emit a chat msg without an activeUser'
    if !client.sendingTo?
      post 'Select a user from the column to send a message to'
      return
    client.sock.emit 'chat msg',
      msg: msg
      to: client.sendingTo
