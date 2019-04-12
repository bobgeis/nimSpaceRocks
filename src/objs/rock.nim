## this file deals with rocks; asteroids etc
## it deals with their creation self-update and drawing

import math

import ../helper/canvas2d
import ../helper/colors
import ../helper/geom
import ../helper/jsrand
import ../helper/sprite

import ../common


## types and helpers

type
  RockMat* = enum ##!
    ## the material the rock is made of: ice, silicaceous,
    ## carbonaceous, metallic, or exotic
    rmIce, rmC, rmS, rmM, rmX,
  RockSize* = enum ##!
    ## the size of the rock: tiny, small, medium, large, huge, gigantic
    rsTiny, rsSmall, rsMedium, rsLarge, rsHuge, rsGigantic
  Rock* = ref object
    x*, y*, a*, vx*, vy*, va*, r*: float
    size*: RockSize
    mat*: RockMat
    shape*: int

const
  va = 0.05                   ## initial angular velocity of rocks (rad/tick)
  vr = 1.00                   ## initial linear velocity of rocks (px/tick)
  dva = 0.025                 ## change in angular velocity of calves (rad/tick)
  dvr = 1.00                  ## change in linear velocity of calves (px/tick)
  points_n = 9                ## avg number of points a rock has
  points_dn = 2               ## variability in number of points: n +/- dn
  points_da = TAU / (points_dn + points_n).float / 6 ##!
  ## variability in degrees between each point
  points_dr = 0.25            ## variability in radius of points (fractional)
  shapesInnerRadius = 0.75       ## ratio of the rock inner radius to outer
  shapes_n = 16               ## number of different rock shapes to make

type
  RockPoints* = array[shapes_n,seq[(float, float)]]

var
  rockPoints*: RockPoints ##!
  ## all the points to draw all the rocks.
  ## easier to populate at runtime due to using js libs
  ## which are not available to the compiler
  rockImgs: array[shapes_n,array[RockSize, array[RockMat, Canvas]]]
  rockPastImgs: array[shapes_n,array[RockSize, Canvas]]
  rockFutureImgs: array[shapes_n,array[RockSize, Canvas]]
  rockImgDimensions: array[RockSize,ImageDimensions]

func toRadius(size:RockSize):float =
  ## given a size, get radius
  case size
  of rsTiny: 10
  of rsSmall: 15
  of rsMedium: 20
  of rsLarge: 25
  of rsHuge: 30
  of rsGigantic: 35

proc toImgRadius(size: RockSize): float =
  size.toRadius * pixelRatio

proc toCanvasWidth(size: RockSize): float =
  size.toImgRadius * (1.1 + points_dr) * 2.0

func shrink(size: RockSize): RockSize =
  ## get the next smaller size, if there is one
  max(size.ord - 1, 0).RockSize

func matToColor(mat: RockMat): (string, string) =
  ## given a mat, get (outer color, inner color)
  case mat
  of rmIce: (hsl(220, 30, 65), hsl(220, 30, 75))
  # of rmC: (hsl(50,30,50),hsl(50,30,60))
  of rmC: (hsl(80, 10, 50), hsl(80, 10, 60))
  # of rmS: (hsl(25,30,50),hsl(25,30,75))
  of rmS: (hsl(50, 30, 50), hsl(50, 30, 60))
  of rmM: (hsl(10, 30, 50), hsl(10, 30, 60))
  of rmX: (hsl(300, 80, 70), hsl(300, 90, 90))
  # of rmX: (hsl(200,80,70),hsl(180,90,90))
  # else: (hsl(200,80,70),hsl(180,90,90))

func gemChance*(mat: RockMat): float =
  ## chance to get a gem when each type of RockMat is busted
  case mat
  of rmIce: 0.15
  of rmC:   0.11
  of rmS:   0.09
  of rmM:   0.04
  of rmX:   0.02

func getCalfNumber(mat: RockMat, roll: float): int =
  ## the number of calves to get for each RockMat
  case mat
  of rmIce:
    if roll < 0.05: 0
    elif roll < 0.5: 1
    else: 1
  of rmC:
    if roll < 0.25: 1
    elif roll < 0.99: 2
    else: 3
  of rmS:
    if roll < 0.3: 1
    elif roll < 0.9: 2
    else: 3
  of rmM:
    if roll < 0.1: 1
    elif roll < 0.6: 2
    elif roll < 0.99: 3
    else: 4
  of rmX:
    if roll < 0.1: 1
    elif roll < 0.4: 2
    elif roll < 0.9: 3
    else: 4

func getSmallerCalfNumber(mat: RockMat, roll: float): int =
  ## the number of mini calves to get for each RockMat
  case mat
  of rmIce:
    if roll < 0.1: 0
    elif roll < 0.4: 1
    elif roll < 0.9: 2
    else: 2
  of rmC:
    if roll < 0.3: 0
    elif roll < 0.8: 1
    elif roll < 0.95: 2
    else: 3
  of rmS:
    if roll < 0.4: 0
    elif roll < 0.8: 1
    elif roll < 0.99: 2
    else: 3
  of rmM:
    if roll < 0.5: 0
    elif roll < 0.9: 1
    elif roll < 1.0: 2
    else: 3
  of rmX:
    if roll < 0.1: 0
    elif roll < 0.4: 1
    elif roll < 0.9: 2
    else: 3


proc makePoints(): seq[(float, float)] =
  ## randomly generate points for the outline of a rock
  let
    n = randictr(points_n, points_dn)
    da = TAU / n.float
  result = @[]
  for i in 0..<n:
    result.add(ratoxy(randctr(1.0, points_dr), randctr(da * i.float,
        points_da)))

proc initPoints() =
  ## randomly generate the points for the rock shapes
  for i in 0..<shapes_n:
    rockPoints[i] = makePoints()

## creation

proc newRock*(x, y, a, vx, vy, va: float, mat: RockMat, size: RockSize,
    shape: int = 0): Rock =
  ## make a new rock from args
  result = Rock(
    x: x, y: y, a: a, vx: vx, vy: vy,
    mat: mat, size: size,
    va: va, r: size.toRadius(),
    shape: shape,
  )

proc chooseSize(difficulty: float = 0.0): RockSize =
  let
    roll = randf() + difficulty
  if roll < 0.1:
    rsSmall
  elif roll < 0.3:
    rsMedium
  elif roll < 0.7:
    rsLarge
  elif roll < 1.1:
    rsHuge
  else:
    rsGigantic

proc chooseMat(difficulty: float = 0.0): RockMat =
  let
    roll = randf() + difficulty
  if roll < 0.3:
    rmIce
  elif roll < 0.55:
    rmC
  elif roll < 0.8:
    rmS
  elif roll < 1.05:
    rmM
  else:
    rmX

proc spawnRock*(difficulty: float = 0.0): Rock =
  ## spawn a new random rock
  let
    (x, y) = randEdgePt()
    a = randang()
  newRock(x, y, a, randctr(vr), randctr(vr), randctr(va),
    chooseMat(difficulty), chooseSize(difficulty), randi(shapes_n))

proc makeCalf*(rock: Rock, size: RockSize): Rock =
  ## make one calf from this rock
  let
    (dvx, dvy) = ratoxy(dvr, randang())
    (dx, dy) = ratoxy(rock.r/2.0, randang())
  newRock(
    rock.x + dx, rock.y + dy, rock.a,
    rock.vx + dvx,
    rock.vy + dvy,
    rock.va + randctr(dva),
    rock.mat,
    size,
    randi(shapes_n)
  )

proc makeCalves*(rock: Rock): seq[Rock] =
  ## make any calves that should be created from this rock
  result = @[]
  if rock.size == rsTiny: return
  for i in 0..<getCalfNumber(rock.mat, randf()):
    result.add rock.makeCalf(rock.size.shrink)
  if rock.size == rsSmall: return
  for i in 0..<getSmallerCalfNumber(rock.mat, randf()):
    result.add rock.makeCalf(rock.size.shrink.shrink)

## manipulation

proc update*(rock: var Rock): bool =
  ## update a rock by one tick
  rock.ballistics()
  wrapObj(rock)
  return true

## draw

proc draw*(ctx: Context, obj: Rock) =
  ## draw one rock
  let
    a = obj.a
    dims = rockImgDimensions[obj.size]
    img = rockImgs[obj.shape][obj.size][obj.mat]
  ctx.drawSprite(img,obj.x,obj.y,a,dims)
  for edge in obj.edgesObj:
    ctx.drawSprite(img,edge[0],edge[1],a,dims)

proc drawPast*(ctx:Context, rock:Rock)=
  ## draw one rock
  let
    a = rock.a
    dims = rockImgDimensions[rock.size]
    img = rockPastImgs[rock.shape][rock.size]
  ctx.drawSprite(img,rock.x,rock.y,a,dims)

proc drawFuture*(ctx: Context, rock:Rock)=
  let
    a = rock.a
    dims = rockImgDimensions[rock.size]
    img = rockFutureImgs[rock.shape][rock.size]
  ctx.drawSprite(img,rock.x,rock.y,a,dims)

## init

proc initImageDimensionss() =
  for size in RockSize:
    rockImgDimensions[size] = newImageDimensions(size.toCanvasWidth)

proc makeRockCanvas(shape: int, size: RockSize, colors: (string,string), stroke = true): Canvas =
  ## create one rock image on a fresh canvas
  let
    r = size.toImgRadius()
    w = rockImgDimensions[size].w
    pts = rockPoints[shape]
    ctx = createCanvas().getContext()
  ctx.imageSmoothingEnabled = false
  ctx.canvas.width = w
  ctx.canvas.height = w
  ctx.translate(w/2,w/2)
  ctx.beginPath()
  ctx.fillStyle = colors[0]
  ctx.moveTo(pts[^1][0]*r, pts[^1][1]*r)
  for pt in pts:
    ctx.lineTo(pt[0]*r, pt[1]*r)
  ctx.closePath()
  ctx.fill()
  if stroke:
    ctx.strokeStyle = "#000000"
    ctx.lineWidth = 1.0 * pixelRatio
    ctx.stroke()
  ctx.beginPath()
  ctx.fillStyle = colors[1]
  ctx.moveTo(pts[^1][0]*r*shapesInnerRadius, pts[^1][1]*r*shapesInnerRadius)
  for pt in pts:
    ctx.lineTo(pt[0]*r*shapesInnerRadius, pt[1]*r*shapesInnerRadius)
  ctx.closePath()
  ctx.fill()
  return ctx.canvas

proc initRockImgs() =
  ## initialize the rockImgs arrays
  for shape in 0..<shapes_n:
    for size in RockSize:
      for mat in RockMat:
        rockImgs[shape][size][mat] = makeRockCanvas(shape,size,mat.matToColor())

proc initPastFutureRockImgs() =
  ## initialize the past and future rock images
  for shape in 0..<shapes_n:
    for size in RockSize:
      rockPastImgs[shape][size] = makeRockCanvas(shape,size,pastColors,stroke=false)
      rockFutureImgs[shape][size] = makeRockCanvas(shape,size,futureColors,stroke=false)


## initialization

proc initImgs() =
  initImageDimensionss()
  initRockImgs()
  initPastFutureRockImgs()


proc init*(rpts: RockPoints) =
  ## Initialize the off screen canvases that contain the rock images.  This must be called before any rocks can be drawn.
  # rockPoints = if not rpts: initPoints() else: rpts
  rockPoints = rpts
  initImgs()

proc init*() =
  initPoints()
  initImgs()
