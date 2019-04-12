## This file is for data types and basic procs handling in-game loot.
## This includes crystals ("gems") that drop from exploding rocks,
## and lifepods ("pods") that drop from exploding ships.

import math

import ../helper/canvas2d
import ../helper/geom
import ../helper/jsrand
import ../helper/sprite

import ../common
import ../emblem

# types and helpers

type
  LootKind* = enum
    lkGem, lkPod,
  Loot* = ref object
    x*, y*, a*, vx*, vy*, va*, r*: float
    kind*: LootKind
    life*: int

const
  lifetime = 1500             ## how many ticks before loot fades
  speed = 3.0                 ## additional speed loot gets on creation
  spin = TAU / 36.0           ## additional angular vel loot gets on creation
  radius = 4.0                ## radius of a loot item
  lootDrag = 0.003             ## drag on a loot item every tick

let
  lootImgRadius = radius * pixelRatio
  lootImgDims = newImageDimensions(lootImgRadius * 1.2 * 2.0)

var
  lootImgs: array[LootKind,array[numGlowColors,Canvas]]

# creation

proc newLoot*[Obj](obj: Obj, kind: LootKind): Loot =
  let
    (dvx, dvy) = ratoxy(speed.randf, randang())
  Loot(
    x: obj.x, y: obj.y, a: obj.a,
    vx: obj.vx + dvx, vy: obj.vy + dvy,
    va: obj.va + randctr(spin),
    r: radius,
    kind: kind,
    life: lifetime,
  )

# manipulation

proc update*(obj: var Loot): bool =
  ## update one item
  if obj.life < 1:
    return false
  obj.life -= 1
  obj.ballistics()
  drag(obj,lootDrag)
  obj.wrapObj()
  return true

# draw

proc draw*(ctx: Context, loot: Loot) =
  ## draw one loot item, handling edge effects
  let
    x = loot.x
    y = loot.y
    a = loot.a
    offset = ratioToGlowOffset(loot.life/lifetime)
    img = lootImgs[loot.kind][offset]
  ctx.drawSprite(img,x,y,a,lootImgDims)
  for edge in loot.edgesObj:
    ctx.drawSprite(img,edge[0],edge[1],a,lootImgDims)

# initialization

proc makePodCanvas(i:int): Canvas =
  ## Make a pod canvas for the given glow color offset.
  let
    colors = discreteGlowColors[i]
    ctx = createCanvas().getContext()
    w = lootImgDims.w
    r = lootImgRadius
  #
  ctx.imageSmoothingEnabled = false
  ctx.canvas.width = w
  ctx.canvas.height = w
  ctx.translate w/2.0, w/2.0
  #
  ctx.beginPath
  ctx.lineWidth = 0.3*r
  ctx.fillStyle = "#FFFFFF"
  ctx.strokeStyle = "#FF0000"
  ctx.ellipse(0.0, 0.0, 0.8*r, r, 0.0, 0.0, TAU)
  ctx.fill
  ctx.stroke
  ctx.emblemFatCross(0.8*r,"#FF0000")
  #
  ctx.beginpath
  ctx.fillStyle = colors[0]
  ctx.strokeStyle = colors[1]
  ctx.lineWidth = 0.2*r
  ctx.arc(0.0,r*0.85,r/3.5,0.0,TAU)
  ctx.fill
  ctx.stroke
  #
  ctx.beginpath
  ctx.fillStyle = colors[0]
  ctx.strokeStyle = colors[1]
  ctx.lineWidth = 0.2*r
  ctx.arc(0.0,-r*0.85,r/3.5,0.0,TAU)
  ctx.fill
  ctx.stroke
  #
  return ctx.canvas

proc makeGemCanvas(i:int): Canvas =
  ## make a ge
  let
    colors = discreteGlowColors[i]
    ctx = createCanvas().getContext()
    w = lootImgDims.w
    r = lootImgRadius
  ctx.imageSmoothingEnabled = false
  ctx.canvas.width = w
  ctx.canvas.height = w
  # remember to translate to the center of the canvas
  ctx.translate w/2.0, w/2.0
  ctx.beginPath()
  ctx.fillStyle = colors[0]
  ctx.rect(-r, -r, 2*r, 2*r)
  ctx.fill()
  ctx.beginPath()
  ctx.fillStyle = colors[1]
  ctx.rect(-r, -r, r, r)
  ctx.fill()
  ctx.beginPath()
  ctx.rect(0.0, 0.0, r, r)
  ctx.fill()
  return ctx.canvas

proc init*() =
  ## Do initialization for the loot module.
  ## * Create pod canvases
  ## * Create gem canvases
  for i in 0..<numGlowColors:
    lootImgs[lkPod][i] = makePodCanvas(i)
    lootImgs[lkGem][i] = makeGemCanvas(i)
