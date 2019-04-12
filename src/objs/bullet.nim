## This file has the basics for bullets:
## types, creation, update, and drawing

import jscore
import math

import ../helper/canvas2d
import ../helper/geom
import ../helper/sprite

import ../common

type
  Bullet* = ref object
    x*, y*, a*, vx*, vy*, va*, r*: float
    life*: int
    shatter*: bool

const
  daSpread = TAU / 30.0
  rShatter = 25.0
  bulletRadius = 3.0
  bulletSpeed = 12.0
  bulletLife = 50

let
  imgRadius = bulletRadius * 2.5 * pixelRatio
  imgDims = newImageDimensions(imgRadius * 1.3 * 2.0)

var
  bulletImgs: array[numGlowColors,Canvas]
  bursterImgs: array[numGlowColors,Canvas]

## creation

proc newBullet(x, y, vx, vy, a: float, shatter: bool = false): Bullet =
  ## given a starting pos & vel, angle, and kind, return a Bullet
  let
    ax = Math.cos(a)
    ay = -Math.sin(a)
  result = Bullet(
    x: x, y: y, a: a,
    vx: vx + ax * bulletSpeed,
    vy: vy + ay * bulletSpeed,
    r: bulletRadius,
    life: bulletLife,
    shatter: shatter,
    )

proc createBullets*[Obj](bullets: var seq[Bullet], obj: Obj,
    spread: bool = false, shatter: bool = false) =
  ## create bullets from the obj,
  ## which should have normal object properties: x,y,a and vx,vy,va
  ## the created bullets will be added to the bullets seq
  bullets.add newBullet(obj.x, obj.y, obj.vx, obj.vy, obj.a, shatter)
  if spread:
    bullets.add newBullet(obj.x, obj.y, obj.vx, obj.vy, obj.a + daSpread,
        shatter)
    bullets.add newBullet(obj.x, obj.y, obj.vx, obj.vy, obj.a - daSpread,
        shatter)

proc addShrapnel*[Obj](bullets: var seq[Bullet], obj: Obj) =
  ## add shrapnel bullet from an exploding shatter shot
  ## it lasts one tick, but destroys everything in range in that tick
  bullets.add Bullet(x: obj.x, y: obj.y, vx:0, vy:0, life:1, r:rShatter, shatter:false)

## manipulation

proc update*(bullet: var Bullet): bool =
  ## update one bullet
  if bullet.life < 1: return false
  bullet.life -= 1
  bullet.ballistics()
  wrapObj(bullet)
  return true

## draw

proc draw*(ctx: Context, obj: Bullet) =
  ## draw one bullet
  let
    x = obj.x
    y = obj.y
    a = obj.a
    offset = ratioToGlowOffset(obj.life/bulletLife)
    img = if obj.shatter: bursterImgs[offset] else: bulletImgs[offset]
  ctx.drawSprite(img,x,y,a,imgDims)
  for edge in obj.edgesObj:
    ctx.drawSprite(img,edge[0],edge[1],a,imgDims)

# init

proc makeBulletImg(i:int):Canvas =
  ## make a basic bullet canvas
  let
    colors = discreteGlowColors[i]
    ctx = createCanvas().getContext()
    w = imgDims.w
    r = imgRadius
    xAxis = r * (0.6 + 0.5 * (i/numGlowColors))
    yAxis = r * (0.3 - 0.15 * (i/numGlowColors))
    thickness = r * 0.2 * (1.0 - 0.9 * (i/numGlowColors))
  #
  ctx.imageSmoothingEnabled = false
  ctx.canvas.width = w
  ctx.canvas.height = w
  ctx.translate w/2.0, w/2.0
  # #
  # ctx.beginPath
  # ctx.strokeStyle = colors[1]
  # ctx.lineWidth = r * 0.4
  # ctx.moveTo r * 0.6, 0.0
  # ctx.lineTo -r * 1.1, 0.0
  # ctx.stroke()
  # ctx.beginPath
  # ctx.strokeStyle = colors[0]
  # ctx.lineWidth = r * 0.2
  # ctx.moveTo r * 0.55, 0.0
  # ctx.lineTo -r, 0.0
  # ctx.stroke()
  #
  ctx.beginPath
  ctx.fillStyle = colors[0]
  ctx.strokeStyle = colors[1]
  ctx.lineWidth = thickness
  ctx.ellipse(0.0, 0.0, xAxis, yAxis, 0.0, 0.0, TAU)
  ctx.fill
  ctx.stroke
  # done
  return ctx.canvas

proc makeBursterImg(i:int):Canvas =
  ## make a basic bullet canvas
  let
    colors = discreteGlowColors[i]
    ctx = createCanvas().getContext()
    w = imgDims.w
    r = imgRadius
    rRing = r * (1.0 - 0.65 * (i/numGlowColors))
    thickness = r * (0.2 + 0.2 * (i/numGlowColors))
  #
  ctx.imageSmoothingEnabled = false
  ctx.canvas.width = w
  ctx.canvas.height = w
  ctx.translate w/2.0, w/2.0
  #
  ctx.beginPath
  ctx.strokeStyle = colors[1]
  ctx.lineWidth = thickness
  ctx.arc(0.0, 0.0, rRing, 0.0, TAU)
  ctx.stroke()
  ctx.beginPath
  ctx.strokeStyle = colors[0]
  ctx.lineWidth = thickness * 0.5
  ctx.arc(0.0, 0.0, rRing, 0.0, TAU)
  ctx.stroke()
  # done
  return ctx.canvas


proc init*() =
  ## create bullet canvases
  for i in 0..<numGlowColors:
    bulletImgs[i] = makeBulletImg(i)
    bursterImgs[i] = makeBursterImg(i)
