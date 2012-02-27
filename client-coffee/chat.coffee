plantTimeout  = (ms, cb) -> setTimeout  cb, ms
plantInterval = (ms, cb) -> setInterval cb, ms

API_PREFIX = '/api/0.1'

#console.log 'hi! chat.coffee has loaded.'

$ ->
  #console.log 'chat.coffee is running under jquery after the dom'
  client = {}
  
  # DOM
  $output = ($ '.chat-log').on 'click', -> $input.focus()
  $input = ($ '.chat-input').focus()
  ($ '.dummy-toggle').on 'click', ->
    $(this).data 'isDummy', !$(this).data 'isDummy'
    if $(this).data 'isDummy' then window.Lace.dummyClient.start() else window.Lace.dummyClient.stop()
    $(this).css 'background-color': if ($(this).data 'isDummy') then '#FFC7AD' else 'transparent'
    $input.focus()
  
  post = (msg) ->
    $output.append (msg+'\n').replace /(\r\n|\n|\r)/gm, '<br>'
    $output.prop scrollTop: $output.prop 'scrollHeight'
  
  onInput = null
  $input.change ->
    v = $input.val()
    $input.val ''
    if onInput?
      post "\n-- #{v}\n"
      onInput? v
  
  $userlist = $ '.chat-userlist'
  $userlist.parent().hide()
  $userlist.on 'click', 'li', ->
    if !client.activeUser? then throw 'tried to click on other user with no activeUser'
    client.sendingTo = $(this).data().user
    $(this).siblings().removeAttr 'style'
    $(this).css 'background-color': '#ADF9FF'
    $input.focus()
  
  clearUserList = -> $userlist.children().remove()
  
  updateUserList = (users) ->
    if !client.activeUser? then throw 'tried to updateUserList with no activeUser'
    #console.log 'updating user list to', users
    $userlist.parent().show()
    clearUserList()
    # Create entry for all but activeUser
    for u in (_.filter users, (u) -> u.uniq isnt client.activeUser.uniq)
      $userlist.append ($ '<li>', text: "#{u.name} (#{compactUniq u.uniq})").data('user', u)
    client.sendingTo = null
    # Re-click previously clicked
    ($ _.detect $userlist.children(), (li) -> $(li).data().user.uniq is client.sendingTo?.uniq)?.click()
  
  compactUniq = (uniq) ->
    _.reduce uniq.split(''), ((a,b) -> a+parseInt(b)), 0
  
  # transport
  post 'awaiting socket...'
  client.activeUser = null
  client.sock = io.connect(document.domain + API_PREFIX + '/socks/chat')
  
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
    $userlist.parent().hide()
    onInput = null
  
  # states
  getName = (name) ->
    post 'waiting for server to acknowledge...'
    client.sock.emit 'set name', name, beUser
  
  beUser = (user) ->
    if !user? then throw 'server answer set name request with no user'
    client.activeUser = user
    #console.log "name set to #{user.name}"
    post "your name is now #{user.name}."
    post 'type to talk.'
    client.sock.on 'chat msg', (msg) ->
      if !client.activeUser? then throw 'tried to process chat msg without an activeUser'
      #console.log 'received message object', msg
      post "#{msg.from.name} (#{compactUniq msg.from.uniq}) says \"#{msg.msg}\""
    client.sock.on 'chat list', (list) ->
      if !client.activeUser? then throw 'tried to process a chat list msg without an activeUser'
      if list.delta?
        post "user action: \"#{list.delta.user.name}\" #{list.delta.state}"
      updateUserList list.users
    onInput = chat
  
  chat = (msg) ->
    if !client.activeUser? then throw 'tried to emit a chat msg without an activeUser'
    if !client.sendingTo?
      post 'select a recipient from the column.'
      return
    client.sock.emit 'chat msg',
      msg: msg
      to: client.sendingTo
  
  
  # Dummy Client
  window.Lace = window.Lace || {}
  window.Lace.dummyClient =
    start: ->
      dummyClientLoop = ->
        if $userlist.parent().is ':visible'
          ($userlist.children().sort -> Math.round(Math.random()) - 0.5).slice(0,1).click()
          $input.val('dummy client message').change()
        tid = plantTimeout 300 + Math.random()*3e3, dummyClientLoop
        window.Lace.dummyClient.stop = -> clearTimeout tid
      dummyClientLoop()
    stop: ->
