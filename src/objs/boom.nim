## this file contains basics for "booms", which are circular effects
## that represent explosions and ftl flashes
## types, helpers, self-update, etc.

import math

import ../helper/canvas2d
import ../helper/colors
import ../helper/geom
import ../helper/sprite

import ../common

## types

type
  BoomKind* = enum
    xkEx, xkOut, xkIn,
  BoomEdge* = enum
    xeClamp, xeWrap
  Boom* = object
    x*, y*, vx*, vy*, a*, va*, r*: float
    life*: int
    kind*: BoomKind
    edge*: BoomEdge

const
  defaultRadius = 100

let
  imgRadius = defaultRadius * pixelRatio
  imgDims = newImageDimensions(imgRadius * 1.1 * 2.0)

var
  boomImgs: array[BoomKind,seq[Canvas]]

## helpers

func lifetime*(kind: BoomKind): int =
  ## the duration of a boom effect in ticks
  case kind
  of xkEx: 13
  of xkOut: 30
  of xkIn: 60

func dr*(kind: BoomKind): float =
  ## how the radius of a boom effect changes each tick
  case kind
  of xkEx: 5.0
  of xkOut: 3.5
  of xkIn: -3.5

func color(kind: BoomKind, life: int): string =
  ## choose the color for the given BoomKind and life left
  let
    ratio = life.float / kind.lifetime.float # note that this goes 1.0 -> 0.0
  case kind
  of xkEx:
    return hsl(
      10 + 50 * ratio,
      100,
      50 + 50 * ratio,
      0.5 + ratio / 2,
    )
  of xkOut:
    return hsl(
      200,
      100,
      40 + 60 * ratio,
      ratio * ratio,
    )
  of xkIn:
    return hsl(
      200,
      100,
      100 - 60 * ratio,
      (1 - ratio) * (1 - ratio),
    )

## creation

proc newBoom*[Obj](obj: Obj, kind: BoomKind = xkEx,
    edge: BoomEdge = xeWrap): Boom =
  let r = case kind
    of xkEx: obj.r
    of xkIn: obj.r - (xkIn.dr * xkIn.lifetime.float)
    of xkOut: obj.r
  ## create a new boom from a given obj (needs x,y,a,r: float)
  Boom(
    x: obj.x, y: obj.y, a: obj.a,
    vx: 0.0, vy: 0.0, va: 0.0,
    r: r,
    life: kind.lifetime,
    kind: kind,
    edge: edge,
  )

## manipulation

proc update*(boom: var Boom): bool =
  if boom.life < 1: return false
  boom.life -= 1
  boom.r += boom.kind.dr
  return true

## draw

proc draw*(ctx: Context, obj: Boom) =
  ## Draw one boom effect
  let
    img = boomImgs[obj.kind][obj.life]
    scale = obj.r/defaultRadius
  case obj.edge
  of xeWrap:
    ctx.drawSprite(img,obj.x,obj.y,0,imgDims,scale=scale)
    for edge in obj.edgesObj:
      ctx.drawSprite(img,edge[0],edge[1],0,imgDims,scale=scale)
  of xeClamp:
    ctx.drawSprite(img,obj.x.clampX,obj.y.clampY,0,imgDims,scale=scale)

# init

proc makeBoomCanvas(kind:BoomKind, life: int) =
  ## make one boom canvas
  let
    r = imgRadius
    w = imgDims.w
    ctx = createCanvas().getContext()
    color = kind.color(life)
  ctx.imageSmoothingEnabled = false
  ctx.canvas.width = w
  ctx.canvas.height = w
  ctx.translate(w/2,w/2)
  ctx.beginPath()
  ctx.fillStyle = color
  ctx.arc(0.0, 0, r, 0, TAU)
  ctx.fill()
  boomImgs[kind].add ctx.canvas

proc init*() =
  ## initialize canvases for boom effects.
  for kind in BoomKind:
    for life in 0..kind.lifetime:
      makeBoomCanvas(kind,life)
