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
    processMsg msg
  
  
  # DOM
  $canvas = $ '.observeCanvas'
  canvas = $canvas[0]
  if !canvas then throw "no canvas";
  ctx = canvas?.getContext? '2d'
  if !ctx? then throw 'could not get canvas context'
  
  
  # Draw
  V2D = window.Lace.V2D
  draw = {ctx: ctx, canvas: canvas}
  
  draw.resize = (color) ->
    canvas.width = $canvas.width()
    canvas.height = $canvas.height()
  
  draw.CIRCLE = (x, y, s, blur=0, color='rgba(0, 0, 0, .5)') ->
	  ctx.fillStyle = color
	  ctx.shadowColor = ctx.fillStyle
	  ctx.shadowBlur = blur
	  ctx.beginPath()
	  ctx.arc x, y, s, 0, 2*Math.PI, false
	  ctx.closePath()
	  ctx.fill()
  
  draw.LINE = (a, b, width=3, color='#555') ->
    ctx.lineWidth = width
    ctx.strokeStyle = color
    ctx.lineCap = 'round'
    ctx.beginPath()
    ctx.moveTo a.x, a.y
    ctx.lineTo b.x, b.y
    ctx.stroke()
  
  draw.TEXT = (x, y, str='', color='#555') ->
    ctx.font = '14px "Lucida Grande", Helvetica, Arial, sans-serif'
    ctx.textAlign = 'center'
    ctx.textBaseline = 'alphabetic'
    ctx.fillStyle = color
    ctx.fillText(str, x, y);
  
  
  # Viz
  
  [width, height] = [canvas.width, canvas.height]
  mainRad = (Math.min width, height) / 2 - 30
  center = (new V2D width, height).mulEq 1/2
  
  users = []
  binds = [] # careful, binds handle this themselves
  getBinds = -> binds = _.reject binds, (b) -> b.age > b.lifetime
  
  class UserBlob
    constructor: ({@name, @uniq}) ->
      @pos = new V2D Math.random() * mainRad, Math.random() * mainRad
      @vel = new V2D 0, 0
      @rad = 15
      @sinceMsg = 0
    
    update: ->
      @sinceMsg++
      
      for u in _.without users, this
        # repel
        diff = (@pos.sub u.pos)
        dist = diff.length()
        pow = (x, p) -> if x >= 0 then Math.pow x, p else -Math.pow -x, p
        f = (x) -> 0.5 - (pow (2*x-1), 1/3)/2
        factor = 1/30 * f (Math.min (Math.max 0, dist/200), 1)
        @vel.plusEq diff.norm().mul factor
        
        # collide
        if dist/2 < @rad + 15
          @pos.plusEq diff.norm().mul (@rad + 15 - dist / 2)
          u.pos.subEq diff.norm().mul (@rad + 15 - dist / 2)
      
      @pos.plusEq @vel
      @vel.mulEq 0.95
      
      # Stay in circle
      fromCenter = (@pos.sub center).length()
      if fromCenter > mainRad
        @pos.plusEq (center.sub @pos).norm().mul fromCenter - mainRad
        #draw.CIRCLE 50, 50, 20, 0, '#f00'
    
    render: ->
      draw.CIRCLE @pos.x, @pos.y, @rad, 15, '#B8D3EE'
      draw.TEXT @pos.x, @pos.y, @name.slice(0, 10), "rgba(76, 109, 141, #{1/(@sinceMsg/50)})"
  
  class Bind
    constructor: ({@from, @to, @msg}) ->
      #console.log 'creatd bind from', @from, 'to', @to
      @lifetime = 200
      @age = 0
      binds.push this
      u.sinceMsg = 0 for u in [@from, @to]
    
    update: ->
      @age++
      diff = @to.pos.sub @from.pos
      pullFactor = Math.min @msg.length / 50 + 0.1, 1.3
      attract = diff.norm().mul pullFactor/@age
      @from.vel.plusEq attract
      @to.vel.subEq  attract
    
    render: ->
      fastFade = 1 - Math.pow @age/@lifetime, 0.5
      draw.LINE @from.pos, @to.pos, 10 * (fastFade), 'rgba(100, 100, 255, ' + fastFade*0.4 + ')'
      drawMsg = (t) =>
        if 0 <= t <= 1
          diff = @to.pos.sub @from.pos
          p = @from.pos.plus diff.mul t
          rad = Math.min @msg.length / 10 + 2, 20
          draw.CIRCLE p.x, p.y, rad, 15, '#8080EB'
      drawMsg @age/30
  
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
    users.push u
    u
  
  vizMsg = (msg) ->
    #console.log 'visualizing message from', msg.from, 'to', msg.to, 'of length', msg.msg.length
    new Bind msg
  
  (frameLoop = ->
    draw.resize()
    (b.update(); b.render()) for b in getBinds()
    (u.update(); u.render()) for u in users
    requestAnimFrame frameLoop
  )()
