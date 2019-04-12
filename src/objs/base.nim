
import math

import ../helper/canvas2d
import ../helper/colors
import ../helper/jsrand
import ../helper/sprite

import ../common
import ../emblem

type
  BaseKind* = enum
    bkHospital, bkRefinery
  Base* = ref object
    x*, y*, a*, vx*, vy*, r*: float
    a1*, va1*, a2*, va2*: float
    kind*: BaseKind
    glow*: int

const
  hospital_pos* = (0.8*CANVAS_WIDTH, 0.25*CANVAS_HEIGHT)
  refinery_pos* = (0.2*CANVAS_WIDTH, 0.75*CANVAS_HEIGHT)
  baseRadius = 20
  baseMaxGlow* = 60

let
  imgRadius = baseRadius * pixelRatio
  imgDims = newImageDimensions imgRadius * 1.3 * 2.0
  imgColors: array[BaseKind, (string,string)] = [("#FFFFFF","#FF0000"),("#FFFFFF","#00CCAA")]

var
  topImgs: array[BaseKind, array[numGlowColors, Canvas]]
  middleImg: Canvas
  bottomImg: Canvas


# creation

proc newHospitalBase*(): Base =
  ## get a new base
  Base(
    x: hospital_pos[0], y: hospital_pos[1], a: randang(),
    vx: 0, vy: 0,
    a1: 0, va1: 0.01,
    a2:0, va2: -0.02,
    glow: 0,
    r: baseRadius, kind: bkHospital,
  )

proc newRefineryBase*(): Base =
  ## get a new base
  Base(
    x: refinery_pos[0], y: refinery_pos[1], a: randang(),
    vx: 0, vy: 0,
    a1: 0, va1: -0.03,
    a2:0, va2: 0.06,
    glow: 0,
    r: baseRadius, kind: bkRefinery,
  )

# manipulation

proc update*(obj: var Base): bool =
  ## update the base for one tick
  obj.a1 += obj.va1
  obj.a2 += obj.va2
  obj.glow = max(0,obj.glow - 1)
  return true

# draw

proc draw*(ctx: Context, obj: Base) =
  ## draw one base item, handling edge effects
  let
    x = obj.x
    y = obj.y
  ctx.drawSprite(bottomImg,x,y,obj.a1,imgDims)
  ctx.drawSprite(middleImg,x,y,obj.a2,imgDims)
  ctx.drawSprite(topImgs[obj.kind][ratioToGlowOffset(obj.glow.float / baseMaxGlow.float)],x,y,obj.a,imgDims)

# init

proc makeBottomImg() =
  ## Make the common bottom canvas
  let
    ctx = createCanvas().getContext()
    r = imgRadius
    w = imgDims.w
  ## set size and translate to the center
  ctx.canvas.width = w
  ctx.canvas.height = w
  ctx.translate w/2.0, w/2.0
  #
  const
    dgray = hsl(0,0,30)
    n = 7
  ctx.beginPath()
  ctx.strokeStyle = dgray
  ctx.lineWidth = 0.2*r
  for i in 1..n:
    ctx.moveTo(0,0)
    ctx.lineTo(0.0,r)
    ctx.stroke()
    ctx.rotate(TAU / n.float)
  ctx.closePath()
  # done
  bottomImg = ctx.canvas

proc makeMiddleImg() =
  ## Make the common middle canvas
  let
    ctx = createCanvas().getContext()
    # r = imgRadius
    w = imgDims.w
  ## set size and translate to the center
  ctx.canvas.width = w
  ctx.canvas.height = w
  ctx.translate w/2.0, w/2.0
  #
  # done
  middleImg = ctx.canvas


proc makeTopImg(i: int, kind: BaseKind) =
  ## Make on of top images
  let
    ctx = createCanvas().getContext()
    colors = imgColors[kind]
    glowColors = discreteGlowColors[i]
    r = imgRadius
    w = imgDims.w
  ## set size and translate to the center
  ctx.canvas.width = w
  ctx.canvas.height = w
  ctx.translate w/2.0, w/2.0
  # draw the main body
  const lgray = hsl(0,0,55)
  ctx.fillStyle = lgray
  ctx.strokeStyle = lgray
  ctx.beginPath()
  ctx.arc(0,0,0.15*r,0,TAU)
  ctx.fill()
  ctx.moveTo(0.0,0.0)
  ctx.lineWidth = 0.3*r
  ctx.lineTo(r,0.0)
  ctx.stroke()
  ctx.arc(0,0,r,0,TAU)
  ctx.stroke()
  # draw emblem
  case kind
    of bkHospital: ctx.emblemFatCross(0.4*r, colors[1])
    of bkRefinery: ctx.emblemDiamond(0.4*r, colors[1])
  # draw glow ring
  ctx.beginPath()
  ctx.strokeStyle = glowColors[1]
  ctx.lineWidth = 0.09*r
  ctx.arc(0,0,r,0,TAU)
  ctx.stroke()
  ctx.strokeStyle = glowColors[0]
  ctx.lineWidth = 0.06*r
  ctx.arc(0,0,r,0,TAU)
  ctx.stroke()
  # done!
  topImgs[kind][i] = ctx.canvas

proc makeTopImgs() =
  ## Make the station's top canvases
  for kind in BaseKind:
    for i in 0..<numGlowColors:
      makeTopImg i, kind

proc init*() =
  ## Initialize the space station canvases
  makeTopImgs()
  makeMiddleImg()
  makeBottomImg()
