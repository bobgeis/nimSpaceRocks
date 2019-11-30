
import ../helper/canvas2d
import ../helper/colors
import ../helper/geom
import ../helper/jsrand
import ../helper/sprite

import ../common

type
  Hooligan* = ref object
    x*,y*,a*,vx*,vy*,va*,r*: float
    acc*: float
    drag*:float
    glow*: int
    cd*: int
    burstPause*: int
    burstShots*: int

const
  radius = 10
  thrust = 0.015
  hooliganDrag = 0.01
  cooldown = 6
  burstPause = 180
  burstShots = 3
  maxGlow = 150
  presentColors = (rgb(160, 195, 255),rgb(50, 75, 200))

let
  imgRadius = radius * pixelRatio
  imgDims = newImageDimensions(imgRadius * 1.3 * 2.0)

var
  presentImgs: array[numGlowColors, Canvas]
  pastImg: Canvas
  futureImg: Canvas

# creation

proc newHooligan*(difficulty: float = 0.0): Hooligan =
  ## Create a new random hooligan
  let
    (x, y) = randSide().randEdgePt()
  Hooligan(
    x:x,
    y:y,
    a:randang(),
    r:radius,
    vx:0.0,vy:0.0,va:0.0,
    acc:thrust,drag:hooliganDrag,
    glow:0,
    cd:0,
    burstPause:burstPause div 10,
    burstShots:0,
  )

# manipulation

proc update*(obj: var Hooligan): bool =
  ## Update one hooligan for one tick
  obj.accelerate()
  obj.ballistics()
  drag(obj)
  wrapObj(obj)
  obj.glow = max(0, obj.glow-1)
  if obj.burstShots > 0 and obj.cd == 0:
    obj.cd = cooldown
    obj.burstShots -= 1
    obj.glow = maxGlow
  else:
    obj.cd = max(0, obj.cd-1)
  if obj.burstPause == 0:
    obj.burstShots = burstShots
    obj.burstPause = burstPause
  else:
    obj.burstPause = max(0, obj.burstPause-1)
  return true

# draw

proc draw*(ctx:Context,obj:Hooligan) =
  ## draw one hooligan
  let
    img = presentImgs[ratioToGlowOffset(obj.glow/maxGlow)]
  ctx.drawSprite(img,obj.x,obj.y,obj.a,imgDims)

proc drawPast*(ctx: Context, obj: Hooligan) =
  ctx.drawSprite(pastImg,obj.x,obj.y,obj.a,imgDims)

proc drawFuture*(ctx: Context, obj: Hooligan) =
  ctx.drawSprite(futureImg,obj.x,obj.y,obj.a,imgDims)

# init

proc makeHooliganImg(i:int,colors:(string,string)):Canvas =
  ## Make an image of a hooligan
  let
    ctx = createCanvas().getContext()
    glowColors = if i == -1: colors else: discreteEvilColors[i]
    r = imgRadius
    w = imgDims.w
  # set size and translate to the center
  ctx.canvas.width = w
  ctx.canvas.height = w
  ctx.translate w/2.0, w/2.0
  #
  ctx.fillStyle = colors[0]
  ctx.strokeStyle = colors[1]
  ctx.lineWidth = r * 0.12
  ctx.beginPath()
  ctx.moveTo(-r * 0.8, r)
  ctx.bezierCurveTo(r * 1.7, r, r * 1.7, -r, -r * 0.8, -r)
  ctx.quadraticCurveTo(r * 1.7, 0.0, -r * 0.8, r)
  ctx.closePath()
  ctx.fill()
  ctx.stroke()
  #
  ctx.fillStyle = glowColors[0]
  ctx.strokeStyle = glowColors[1]
  ctx.lineWidth = r * 0.07
  ctx.beginPath
  ctx.circle -r * 0.25, 0, r * 0.25
  ctx.fill()
  ctx.stroke()
  #
  return ctx.canvas


proc init*() =
  ## initialize player canvases
  for i in 0..<numGlowColors:
    presentImgs[i] = makeHooliganImg(i,presentColors)
  pastImg = makeHooliganImg(-1,pastColors)
  futureImg = makeHooliganImg(-1,futureColors)
