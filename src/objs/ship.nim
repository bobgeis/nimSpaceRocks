## This file contains basic types, data, and procs for ship game entities
## Ships represent NPC ships that fly through the scene.
## The player is ostensibly trying to protect them.
## They will explode and leave loot if struck by a rock.

import math

import ../helper/canvas2d
import ../helper/geom
import ../helper/jsrand
import ../helper/sprite

import ../common
import ../emblem

# types and helpers

type
  ShipKind* = enum
    skLiner, skMiner, skScience, skMedic, skPolice, skGuild,

  Ship* = ref object
    x*, y*, a*, vx*, vy*, va*, r*: float
    glow*: int
    kind*: ShipKind

const
  shipRadius = 7.0
  shipSpeed = 5.0 / 6.0
  shipGlow = 45

let
  imgRadius = shipRadius * pixelRatio
  imgDims = newImageDimensions imgRadius * 1.3 * 2.0

var
  shipImgs: array[ShipKind, array[numGlowColors,Canvas]]
  shipPastImg: Canvas
  shipFutureImg: Canvas

func hullColors(kind: ShipKind): (string, string) =
  ## get hull colors from shipkind (hull,trim)
  case kind
  of skLiner: ("#FAFAFA", "#FA00FA")
  of skMiner: ("#F0F0F0", "#ED9800")
  of skMedic: ("#FFFFFF", "#FF0000")
  of skScience: ("#FFFFFF", "#009696")
  of skPolice: ("#D9D9D9", "#0000FF")
  of skGuild: ("#C8C8C8", "#FF8000")

proc randKind(difficulty: float = 0.0): ShipKind =
  ## get a random ShipKind
  let
    roll = randf() + difficulty
    roll2 = randf()
  if roll < 0.5:
    if roll2 < 0.5: skLiner else: skMiner
  elif roll < 0.9:
    if roll2 < 0.5: skMedic else: skGuild
  else:
    if roll2 < 0.5: skPolice else: skScience

# creation

proc newRandShip*(difficulty: float = 0.0): Ship =
  ## return a new random ship
  let
    side = randSide()
    (x, y) = randEdgePt(side)
    a = randAngleIn(side)
    # note we have -a here because y increases going *down*
    (vx, vy) = ratoxy(shipSpeed, -a)
  Ship(
    x: x, y: y, a: a,
    vx: vx, vy: vy, va: 0,
    r: shipRadius, glow: shipGlow,
    kind: randKind(difficulty),
  )

# manipulation

proc update*(obj: var Ship): bool =
  ## update one ship obj
  obj.ballistics()
  obj.glow = if obj.glow < 1: shipGlow
    else: max(0, obj.glow-1)
  return true

# draw

proc draw*(ctx:Context,obj:Ship) =
  ## draw one ship
  let
    img = shipImgs[obj.kind][ratioToGlowOffset(obj.glow.float / shipGlow.float)]
  ctx.drawSprite(img,obj.x,obj.y,obj.a,imgDims)

proc drawPast*(ctx: Context, obj: Ship) =
  ctx.drawSprite(shipPastImg,obj.x,obj.y,obj.a,imgDims)

proc drawFuture*(ctx: Context, obj: Ship) =
  ctx.drawSprite(shipFutureImg,obj.x,obj.y,obj.a,imgDims)

# init

proc makeShipCanvas(i:int, colors:(string,string), sk: ShipKind):Canvas =
  ## Make and return a ship canvas
  let
    ctx = createCanvas().getContext()
    glowColors = if i == -1: colors else: discreteGlowColors[i]
    r = imgRadius
    w = imgDims.w
  ## set size and translate to the center
  ctx.canvas.width = w
  ctx.canvas.height = w
  ctx.translate w/2.0, w/2.0
  # body
  ctx.fillStyle = colors[0]
  ctx.strokeStyle = colors[1]
  ctx.lineWidth = r * 0.18
  ctx.beginPath()
  ctx.arc(0.0, 0.0, r, 0.0, TAU)
  ctx.fill()
  ctx.stroke()
  # emblem if present time
  if i != -1:
    case sk:
    of skGuild: ctx.emblemWidget(r, colors[1])
    of skLiner: ctx.emblemPipeTriangle(r, colors[1])
    of skMedic: ctx.emblemFatCross(r, colors[1])
    of skMiner: ctx.emblemTeeBar(r,colors[1])
    of skPolice: ctx.emblemShield(r, colors[1])
    of skScience: ctx.emblemThreeEllpises(r, colors[1])
  # engine
  ctx.fillStyle = glowColors[0]
  ctx.strokeStyle = glowColors[1]
  ctx.lineWidth = 0.15 * r
  ctx.beginPath()
  ctx.ellipse(-r*0.82, 0.0, r*0.42, r*0.25, 0.0, 0.0, TAU)
  ctx.fill()
  ctx.stroke()
  # done!
  return ctx.canvas

proc init*() =
  ## initialize the ship image canvases
  for sk in ShipKind:
    for i in 0..<numGlowColors:
      shipImgs[sk][i] = makeShipCanvas(i,sk.hullColors,sk)
  shipPastImg = makeShipCanvas(-1,pastColors,skMedic)
  shipFutureImg = makeShipCanvas(-1,futureColors,skMedic)
