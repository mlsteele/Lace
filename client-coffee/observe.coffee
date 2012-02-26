plantTimeout  = (ms, cb) -> setTimeout  cb, ms
plantInterval = (ms, cb) -> setInterval cb, ms

API_PREFIX = '/api/0.1'

$ ->
  # Socket
  client =
    sock: io.connect document.domain + API_PREFIX + '/socks/observe'
  
  client.sock.on 'connect', -> console.log 'socket connected'
  client.sock.on 'disconnect', -> console.log 'socket disconnected'
  client.sock.on 'msg', (msg) ->
    console.log 'received message', msg
    processMsg msg
  
  
  # DOM
  $canvas = $ '.observeCanvas'
  canvas = $canvas[0]
  if !canvas then throw "no canvas";
  ctx = canvas?.getContext? '2d'
  if !ctx? then throw 'could not get canvas context'
  draw = {ctx: ctx, canvas: canvas}
  
  draw.resize = ->
    canvas.width = $canvas.width()
    canvas.height = $canvas.height()
  
  draw.CIRCLE = (x, y, s, color='rgba(0, 0, 0, .5)') ->
	  ctx.fillStyle = color
	  ctx.beginPath()
	  ctx.arc x, y, s, 0, 2*Math.PI, false
	  ctx.closePath()
	  ctx.fill()
  
  
  # Viz
  
  [width, height] = [canvas.width, canvas.height]
  
  V2D = window.Lace.V2D
  
  class UserBlob
    constructor: (user) ->
      @name = user.name
      @uniq = user.uniq
      @pos = new V2D Math.random() * width, Math.random() * height
      @vel = new V2D 0, 0
    
    update: ->
      @pos.plusEq @vel
    
    render: ->
      draw.CIRCLE @pos.x, @pos.y, 10
  
  users = []
  
  processMsg = (msg) ->
    safeUseUser = (user) ->
      u = (_.detect users, (u) -> u.uniq is user.uniq)
      if u? then u else initUser(user)
    vizMsg
      from: safeUseUser msg.from
      to:   safeUseUser msg.to
      msg:  msg.msg
  
  initUser = (user) ->
    u = new UserBlob user
    console.log 'users is now of length', users.push u
    u
  
  vizMsg = (msg) ->
    console.log 'visualizing message from', msg.from, 'to', msg.to, 'of length', msg.msg.length
  
  (frameLoop = ->
    draw.resize()
    (u.update(); u.render()) for u in users
    plantTimeout 1000, frameLoop
  )()
