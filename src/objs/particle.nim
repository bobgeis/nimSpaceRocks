## File for creating and drawing simple particle effects

import ../helper/canvas2d
import ../helper/colors
import ../helper/geom
import ../helper/jsrand
import ../helper/sprite

import ../common

# types

type
  Particle* = ref object
    x*, y*, vx*, vy*: float
    life*: int

const
  minStartLife = 15
  maxlife = 25
  minspeed = 6.0
  maxspeed = 18.0
  particleDrag = 0.08
  radius = 2.5

let
  imgRadius = radius * pixelRatio
  imgDims = newImageDimensions(imgRadius * 1.3 * 2.0)

var
  imgCanvases: array[maxlife+1,Canvas]

func drag*(par: Particle): float = particleDrag

proc getColors(ratio: float): (string,string) =
  ## get the color of the particle
  (
    hsl(
      30 + 30 * ratio,
      100,
      70 + 30 * ratio,
      1
    ),
    hsl(
      10 + 50 * ratio,
      100,
      50 + 50 * ratio,
      0.1 + 0.9 * ratio,
    ),
  )

# creation

proc newParticle*[Obj](obj: Obj): Particle =
  ## create a new particle on the object
  let
    (dvx, dvy) = ratoxy(randf(minspeed, maxspeed), randang())
  Particle(
    x: obj.x,
    y: obj.y,
    vx: obj.vx + dvx,
    vy: obj.vy + dvy,
    life: randi(minStartLife,maxlife),
  )

proc addParticlesOn*[Obj](pars: var seq[Particle], obj:Obj) =
  ## Create a burst of particles on the object and add them to the sequence.  This will create fewer particles if there are already a lot in the seq.
  let
    l = pars.len
    n = if l > 400: 1
      elif l > 200: 5.randi()
      elif l > 100: 10.randi()
      elif l > 50: 15.randi()
      else: 20.randi()
  for i in 0..<n: pars.add obj.newParticle()

# manipulation

proc update*(obj: var Particle): bool =
  ## update the particle for one tick
  if obj.life < 1: return false
  obj.life -= 1
  obj.x += obj.vx
  obj.y += obj.vy
  obj.wrapObj()
  geom.drag(obj)
  return true

# draw

proc draw*(ctx: Context, obj: Particle) =
  ## draw one particle
  let
    img = imgCanvases[obj.life]
  ctx.drawSprite(img,obj.x,obj.y,0.0,imgDims)

# init

proc makeParticleCanvas(i:int) =
  ## Make one particle canvas
  let
    r = imgRadius
    w = imgDims.w
    ctx = createCanvas().getContext()
  ctx.imageSmoothingEnabled = false
  ctx.canvas.width = w
  ctx.canvas.height = w
  ctx.translate(w/2,w/2)
  #
  let
    grad = ctx.createRadialGradient(0.0,0,0.5*r,0,0,r)
    imgColors = getColors(i/maxlife)
  grad.addColorStop 0, imgColors[0]
  grad.addColorStop 1, imgColors[1]
  ctx.setFillStyle grad
  ctx.circle(0.0,0,r)
  ctx.fill
  #
  imgCanvases[i] = ctx.canvas

proc init*() =
  ## initialize particle canvases
  for i in 0..maxLife:
    makeParticleCanvas(i)
