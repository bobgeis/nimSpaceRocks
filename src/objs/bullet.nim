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
    ring*: bool
    evil*: bool

const
  daSpread = TAU / 30.0
  bulletRadius = 3.0
  bulletSpeed = 12.0
  bulletLife = 50
  ringShotMaxRadius = 15.0
  ringShotGrowth = (ringShotMaxRadius - bulletRadius) * (1/50)

let
  imgRadius = bulletRadius * 2.5 * pixelRatio
  imgDims = newImageDimensions(imgRadius * 1.3 * 2.0)

var
  bulletImgs: array[bool,array[bool,array[numGlowColors,Canvas]]]

## creation

proc newBullet(x, y, vx, vy, a: float, ring: bool = false, evil: bool = false): Bullet =
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
    ring: ring,
    evil: evil,
    )

proc createBullets*[Obj](bullets: var seq[Bullet], obj: Obj,
    spread: bool = false, ring: bool = false, evil: bool = false) =
  ## create bullets from the obj,
  ## which should have normal object properties: x,y,a and vx,vy,va
  ## the created bullets will be added to the bullets seq
  bullets.add newBullet(obj.x, obj.y, obj.vx, obj.vy, obj.a, ring, evil)
  if spread:
    bullets.add newBullet(obj.x, obj.y, obj.vx, obj.vy, obj.a + daSpread,
        ring, evil)
    bullets.add newBullet(obj.x, obj.y, obj.vx, obj.vy, obj.a - daSpread,
        ring, evil)

## manipulation

proc update*(bullet: var Bullet): bool =
  ## update one bullet
  if bullet.life < 1: return false
  bullet.life -= 1
  bullet.ballistics()
  wrapObj(bullet)
  if bullet.ring: bullet.r += ringShotGrowth
  return true

## draw

proc draw*(ctx: Context, obj: Bullet) =
  ## draw one bullet
  let
    x = obj.x
    y = obj.y
    a = obj.a
    offset = ratioToGlowOffset(obj.life/bulletLife)
    img = bulletImgs[obj.ring][obj.evil][offset]
  ctx.drawSprite(img,x,y,a,imgDims)
  for edge in obj.edgesObj:
    ctx.drawSprite(img,edge[0],edge[1],a,imgDims)

# init

proc makeBulletImg(i:int,evil=false):Canvas =
  ## make a basic bullet canvas
  let
    colors = if not evil: discreteGlowColors[i] else: discreteEvilColors[i]
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

proc makeBursterImg(i:int,evil=false):Canvas =
  ## make a basic bullet canvas
  let
    colors = if not evil: discreteGlowColors[i] else: discreteEvilColors[i]
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
  for ring in false..true:
    for evil in false..true:
      for i in 0..<numGlowColors:
        if ring == true:
          bulletImgs[ring][evil][i] = makeBursterImg(i,evil)
        else:
          bulletImgs[ring][evil][i] = makeBulletImg(i,evil)
