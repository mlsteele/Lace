console.log 'hi! chat.coffee has loaded.'

$ ->
  console.log 'chat.coffee is running under jquery after the dom'
  API_PREFIX = '/api01'
  
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
  
  
  activeUser = undefined
  
  # login
  login = (name) ->
    onInput = ->
    console.log 'input callback called with', name
    $.post API_PREFIX+'/login', {name: name}, (user) ->
      console.log 'received user', activeUser = user
      post 'you are ' + user.name + '\nyou were created ' + user.created
      post 'type to chat'
      onInput = chatting
  
  # chat
  chatting = (msg) ->
    post 'you said: "' + msg + '"'
    $.post API_PREFIX+'/say', {user: activeUser, msg: msg}, (status) ->
      if status is not 'ok' then console.error 'message could not be sent'
  
  # exec
  post 'Enter your name:'
  onInput = login
