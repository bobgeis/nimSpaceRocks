
import math

import ../helper/canvas2d
import ../helper/colors
import ../helper/geom
import ../helper/jsrand
import ../helper/sprite

import ../common

type
  HooliganKind* = enum
    hkVandal, hkOri, hkTrilobite
  Hooligan* = ref object
    x*,y*,a*,vx*,vy*,va*,r*: float
    acc*: float
    drag*:float
    glow*: int
    cd*: int
    burstPause*: int
    burstShots*: int
    kind*: HooliganKind

const
  radius = 10
  hooliganDrag = 0.01
  cooldown = 6
  burstPause = 180
  maxGlow = 150
  presentColors = (rgb(160, 195, 255),rgb(50, 75, 200))

let
  imgRadius = radius * pixelRatio
  imgDims = newImageDimensions(imgRadius * 1.3 * 2.0)

var
  presentImgs: array[HooliganKind,array[numGlowColors, Canvas]]
  pastImg: array[HooliganKind,Canvas]
  futureImg: array[HooliganKind,Canvas]

func getThrust(kind: HooliganKind): float =
  case kind
  of hkVandal: 0.015
  of hkOri: 0.03
  of hkTrilobite: 0.022

func getBurstShots(kind: HooliganKind): int =
  case kind
  of hkVandal: 3
  of hkOri: 4
  of hkTrilobite: 3

# creation

proc chooseKind(difficulty: float = 0.0): HooliganKind =
  ## Choose a random HooliganKind for the given difficulty
  let roll = randf() + (1.0 * difficulty)
  if roll < 0.5: hkVandal
  elif roll < 0.9: hkOri
  else: hkTrilobite

proc newHooligan*(difficulty: float = 0.0): Hooligan =
  ## Create a new random hooligan
  let
    (x, y) = randSide().randEdgePt()
    kind = chooseKind(difficulty)
  Hooligan(
    x:x,
    y:y,
    a:randang(),
    r:radius,
    vx:0.0,vy:0.0,va:0.0,
    kind:kind,
    acc:kind.getThrust,
    drag:hooliganDrag,
    glow:0,
    cd:0,
    burstPause:burstPause div 5,
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
    obj.burstShots = obj.kind.getBurstShots
    obj.burstPause = burstPause
  else:
    obj.burstPause = max(0, obj.burstPause-1)
  return true

# draw

proc draw*(ctx:Context,obj:Hooligan) =
  ## draw one hooligan
  let
    img = presentImgs[obj.kind][ratioToGlowOffset(obj.glow/maxGlow)]
  ctx.drawSprite(img,obj.x,obj.y,obj.a,imgDims)

proc drawPast*(ctx: Context, obj: Hooligan) =
  ctx.drawSprite(pastImg[obj.kind],obj.x,obj.y,obj.a,imgDims)

proc drawFuture*(ctx: Context, obj: Hooligan) =
  ctx.drawSprite(futureImg[obj.kind],obj.x,obj.y,obj.a,imgDims)

# init

proc makeVandalImg(i:int,colors:(string,string)):Canvas =
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

proc makeOriImg(i:int,colors:(string,string)):Canvas =
  ## Make image of an ori hooligan
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
  ctx.strokeStyle = colors[1]
  ctx.lineWidth = r * 0.35
  ctx.beginPath()
  ctx.circle(0.0,0.0,r*0.9)
  ctx.stroke()
  #
  ctx.strokeStyle = colors[0]
  ctx.lineWidth = r * 0.2
  ctx.beginPath()
  ctx.circle(0.0,0.0,r*0.9)
  ctx.stroke()
  #
  ctx.fillStyle = colors[0]
  ctx.strokeStyle = colors[1]
  ctx.lineWidth = r * 0.07
  ctx.beginPath
  ctx.ellipse r * 0.85, 0.0, r * 0.4, r * 0.2, 0.0, 0.0, TAU
  ctx.fill()
  #
  ctx.fillStyle = glowColors[0]
  ctx.strokeStyle = glowColors[1]
  ctx.lineWidth = r * 0.07
  ctx.beginPath
  ctx.circle -r * 0.85, 0, r * 0.3
  ctx.fill()
  ctx.stroke()
  #
  return ctx.canvas

proc makeTrilobiteImg(i:int,colors:(string,string)):Canvas =
  ## Make the image for a trilobite hooligan
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
  ctx.lineWidth = r * 0.08
  #
  ctx.beginPath()
  ctx.moveTo(-r * 0.8, r)
  ctx.bezierCurveTo(r * 1.7, r, r * 1.7, -r, -r * 0.8, -r)
  ctx.quadraticCurveTo(r * 2.3, 0.0, -r * 0.8, r)
  ctx.closePath()
  ctx.fill()
  ctx.stroke()
  #
  let
    r2 = r * 0.75
    x2 = -r2 * 1.3
    xBC2 = r2 * 1.38
    xQC2 = r2 * 1.79
  ctx.beginPath()
  ctx.moveTo(x2, r2)
  ctx.bezierCurveTo(xBC2, r2, xBC2, -r2, x2, -r2)
  ctx.quadraticCurveTo(xQC2, 0.0, x2, r2)
  ctx.closePath()
  ctx.fill()
  ctx.stroke()
  #
  let
    r3 = r * 0.5
    x3 = -r3 * 2.0
    xBC3 = r3 * 0.4
    xQC3 = r3 * 0.3
  ctx.beginPath()
  ctx.moveTo(x3, r3)
  ctx.bezierCurveTo(xBC3, r3, xBC3, -r3, x3, -r3)
  ctx.quadraticCurveTo(xQC3, 0.0, x3, r3)
  ctx.closePath()
  ctx.fill()
  ctx.stroke()
  #
  ctx.fillStyle = glowColors[0]
  ctx.strokeStyle = glowColors[1]
  ctx.lineWidth = r * 0.07
  ctx.beginPath
  ctx.circle -r * 0.85, 0, r * 0.25
  ctx.fill()
  ctx.stroke()
  #
  return ctx.canvas

proc makeHooliganImg(kind: HooliganKind,i:int,colors:(string,string)):Canvas =
  case kind
  of hkVandal: makeVandalImg(i,colors)
  of hkOri: makeOriImg(i,colors)
  of hkTrilobite: makeTrilobiteImg(i,colors)

proc init*() =
  ## initialize player canvases
  for kind in HooliganKind:
    for i in 0..<numGlowColors:
      presentImgs[kind][i] = makeHooliganImg(kind,i,presentColors)
    pastImg[kind] = makeHooliganImg(kind,-1,pastColors)
    futureImg[kind] = makeHooliganImg(kind,-1,futureColors)
