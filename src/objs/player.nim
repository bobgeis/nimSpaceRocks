
import jscore
import math

import ../helper/canvas2d
import ../helper/colors
import ../helper/geom
import ../helper/sprite

import ../common

const
  playerRadius = 10.0
  accThrust = 0.15
  accRetro = -0.05
  accstrafe = 0.05
  strafeAngle = TAU / 4.0
  turnRate = 0.1              ## rad/tick
  playerDrag = 0.02
  cooldown = 6                ## ticks
  glowBang = 45
  glowThrust = 25

type
  Player* = ref object
    x*, y*, a*, r*: float
    vx*, vy*, va*, drag*: float
    acc*, strafe*: float
    cd*, glow*: float
    firing*, alive*: bool
    spreadTime*: int ## ticks left of spread bonus
    burstTime*: int ## ticks left of shatter bonus
  PlayerCommand* = enum
    TurnLeft, TurnRight, TurnStop,
    AccThrust, AccRetro, AccStop,
    StrafeLeft, StrafeRight, StrafeStop
    WpnOn, WpnOff

# creation

proc newPlayer*(): Player =
  result = Player(
    x: CANVAS_WIDTH/2.0, y: CANVAS_HEIGHT/2.0,
    a: TAU/4.0, r: playerRadius,
    vx: 0.0,
    vy: 0.0,
    va: 0.0,
    acc: 0.0,
    strafe: 0.0,
    drag: playerDrag,
    cd: 0,
    glow: 0,
    firing: false,
    alive: true,
    spreadTime: 300,
    burstTime: 300,
  )

# manipulation

proc kill*(player: var Player) =
  ## Set values in the player object when the player is destroyed.
  player.alive = false
  player.vx = 0
  player.vy = 0
  player.acc = 0
  player.strafe = 0
  player.firing = false
  player.spreadTime = 0
  player.burstTime = 0

proc update*(player: var Player) =
  ## update the player one tick
  if not player.alive: return
  player.accelerate()
  if player.strafe != 0:
    player.accelerate(player.strafe, strafeAngle - player.a)
  player.ballistics()
  drag(player)
  wrapObj(player)
  player.glow = max(if player.acc != 0: glowThrust else: 0, player.glow - 1)
  if player.firing and player.cd == 0:
    player.cd = cooldown
    player.glow = max(player.glow, glowBang)
  else:
    player.cd = max(0, player.cd - 1)
  player.spreadTime = max(0, player.spreadTime - 1)
  player.burstTime = max(0, player.burstTime - 1)

proc command*(player: var Player, cmd: PlayerCommand) =
  case cmd
  of AccThrust:
    player.acc = accThrust
    player.glow = max(player.glow, glowThrust)
  of AccRetro:
    player.acc = accRetro
    player.glow = max(player.glow, glowThrust)
  of AccStop: player.acc = 0.0
  of TurnLeft: player.va = turnRate
  of TurnRight: player.va = -turnRate
  of TurnStop: player.va = 0.0
  of WpnOn: player.firing = true
  of WpnOff: player.firing = false
  of StrafeLeft:
    player.strafe = -accStrafe
    player.glow = max(player.glow, glowThrust)
  of Straferight:
    player.strafe = accStrafe
    player.glow = max(player.glow, glowThrust)
  of StrafeStop:
    player.strafe = 0

proc stop*(player: var Player) =
  ## stop the motion of the player
  player.command(AccStop)
  player.command(TurnStop)
  player.command(WpnOff)

# draw

var
  playerImgs: array[numGlowColors,Canvas]
  playerPastImg: Canvas
  playerFutureImg: Canvas

let
  playerImgRadius = playerRadius * pixelRatio
  playerCanvasWidth = playerImgRadius * 1.25 * 2.0
  playerImgDims = newImageDimensions(playerCanvasWidth)

proc draw*(ctx: Context, obj: Player) =
  ## draw the player sprite onto the canvas
  if not obj.alive: return
  let
    a = obj.a
    img = playerImgs[ratioToGlowOffset(obj.glow.float / glowBang.float)]
  ctx.drawSprite(img,obj.x,obj.y,a,playerImgDims)
  for edge in obj.edgesObj:
    ctx.drawSprite(img,edge[0], edge[1],a,playerImgDims)

proc drawPast*(ctx: Context, obj: Player) =
  if not obj.alive: return
  let
    a = obj.a
    img = playerPastImg
  ctx.drawSprite(img,obj.x,obj.y,a,playerImgDims)
  for edge in obj.edgesObj:
    ctx.drawSprite(img,edge[0],edge[1],a,playerImgDims)

proc drawFuture*(ctx: Context, obj: Player) =
  if not obj.alive: return
  let
    a = obj.a
    img = playerFutureImg
  ctx.drawSprite(img,obj.x,obj.y,a,playerImgDims)
  for edge in obj.edgesObj:
    ctx.drawSprite(img,edge[0],edge[1],a,playerImgDims)

# init

proc makePlayerImg(i:int,colors:(string,string)):Canvas =
  ## Draw one player image canvas
  let
    ctx = createCanvas().getContext()
    glowColors = if i == -1: colors else: discreteGlowColors[i]
    r = playerImgRadius
    w = playerImgDims.w
  ## set size and translate to the center
  ctx.canvas.width = w
  ctx.canvas.height = w
  ctx.translate w/2.0, w/2.0
  # draw the body
  ctx.fillStyle = colors[0]
  ctx.strokeStyle = colors[1]
  ctx.lineWidth = r * 0.12
  ctx.beginPath()
  ctx.moveTo(0.0, r)
  ctx.bezierCurveTo(r * 1.5, r, r * 1.5, -r, 0, -r)
  ctx.quadraticCurveTo(r / 2, -r / 4, -r, 0)
  ctx.quadraticCurveTo(r / 2, r / 4, 0, r)
  ctx.fill()
  ctx.stroke()
  # draw emblem
  ctx.lineWidth = r * 0.2
  ctx.beginPath()
  ctx.moveTo(r / 2.0, -r / 4.0)
  ctx.lineTo(r / 2.0, r / 4.0)
  ctx.stroke()
  ctx.moveTo(r * 0.75, 0.0)
  ctx.lineTo(r * 0.25, 0.0)
  ctx.stroke()
  ctx.closePath()
  # draw engines
  ctx.fillStyle = glowColors[0]
  ctx.strokeStyle = glowColors[1]
  ctx.lineWidth = r * 0.07
  ctx.beginPath()
  ctx.ellipse(r/12.0, -r/2.0, r/2.0, r/8.0, 0.0, 0.0, TAU)
  ctx.fill()
  ctx.stroke()
  ctx.beginPath()
  ctx.ellipse(r/12.0, r/2.0, r/2.0, r/8.0, 0.0, 0.0, TAU)
  ctx.fill()
  ctx.stroke()
  # done!
  return ctx.canvas

proc init*() =
  ## initialize player canvases
  const
    presentColors = (rgb(255, 255, 255),rgb(255, 0, 0))
  for i in 0..<numGlowColors:
    playerImgs[i] = makePlayerImg(i,presentColors)
  playerPastImg = makePlayerImg(-1,pastColors)
  playerFutureImg = makePlayerImg(-1,futureColors)
