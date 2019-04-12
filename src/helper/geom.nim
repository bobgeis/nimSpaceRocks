## geometry and physics functions

import jscore
import math

import utils

func wrap*(s: float, max: float): float =
  ## wrap a coordinate s around 0 and max
  if s < 0.0: return s + max
  elif s > max: return s - max
  else: return s

func wrapA*(a: float): float =
  ## wrap an angle a to within a circle
  a.wrap(TAU)

func clamp*(s: float, max: float): float =
  ## clamp a coordinate s to between 0 and max
  if s < 0.0: return 0.0
  elif s > max: return max
  else: return s

func drag*(v: float, d: float = 0.0): float =
  ## apply drag to a velocity
  v * (1.0 - d)

proc drag*[Obj](obj: var Obj,d:float) =
  ## apply drag to an object using a given drag value
  obj.vx = drag(obj.vx, d)
  obj.vy = drag(obj.vy, d)

proc drag*[Obj](obj: var Obj) =
  ## apply drag to an object using the object's drag property
  obj.vx = drag(obj.vx, obj.drag)
  obj.vy = drag(obj.vy, obj.drag)

proc mag*(x, y: SomeNumber): float =
  ## get the magnitude of an xy vector
  Math.hypot(x, y)

proc angle*(x, y: SomeNumber): float =
  ## get the angle of an xy vector
  Math.atan2(y, x)

proc ratoxy*(r, a: SomeNumber): (float, float) =
  ## Convert radius and angle(rad) to x and y.
  (r * Math.cos(a), r * Math.sin(a))

proc xytora*(x, y: SomeNumber): (float, float) =
  ## convert x,y vector to an r,a vector
  (mag(x, y), angle(x, y))

func dist*(x1, y1, x2, y2: SomeNumber): float =
  ## get the distance between two x, y points
  mag(x2 - x1, y2 - y1)

func dist*[PointA, PointB](a: PointA, b: PointB): float =
  ## get the distance between two points (of potentially different types)
  ## they must each have .x and .y values of type float
  dist(a.x, a.y, b.x, b.y)

proc ballistics*[Obj](obj: var Obj) =
  ## update the given object for one tick
  obj.x = obj.x + obj.vx
  obj.y = obj.y + obj.vy
  obj.a = wrapA(obj.a + obj.va)

proc accelerate*[Obj](obj: var Obj) =
  ## acceleate an object forward
  if obj.acc != 0:
    let
      ax = obj.acc * Math.cos(obj.a)
      ay = -obj.acc * Math.sin(obj.a)
    obj.vx += ax
    obj.vy += ay

proc accelerate*[Obj](obj: var Obj, acc, a: float) =
  ## accelerate an object in an amount, acc, in a direction a
  let
    (ax, ay) = ratoxy(acc, a)
  obj.vx += ax
  obj.vy += ay

func cirCollide*(x1, y1, r1, x2, y2, r2: SomeNumber): bool =
  ## given circles defined by x,y,r determine if they are colliding
  square(x2 - x1) + square(y2 - y1) < square(r2 + r1)

func cirCollide*[CircleA, CircleB](a: CircleA, b: CircleB): bool =
  ## returns true if the two circles overlap
  ## objects must have .x .y and .r values of type float
  cirCollide(a.x, a.y, a.r, b.x, b.y, b.r)

func cirEdges*(x, y, r: SomeNumber, w, h: SomeNumber): seq[array[2, float]] =
  ## Given x,y,r of a circle, and w,h of a rect,
  ## get a sequence of points that will wrap the circle
  ## around the edges and corners of the rect.
  ## This is for drawing purposes, ie: if a circle is half off the bottom,
  ## then it should also be drawn half off the top.
  result = @[]
  # remember to use floats, otherwise we'll get type mismatches when
  # we try to produce the corner point
  var xedge = 0.0
  var yedge = 0.0
  # handle sides
  if x - r < 0:
    result.add [x + w, y]
    xedge = 1
  elif x + r > w:
    result.add [x - w, y]
    xedge = -1
  # handle top and bottom
  if y - r < 0:
    result.add [x, y + h]
    yedge = 1
  elif y + r > h:
    result.add [x, y - h]
    yedge = -1
  # handle corners
  if xedge != 0 and yedge != 0:
    result.add [x + xedge * w, y + yedge * h]

func cirEdges*[Circle](a: Circle, w, h: SomeNumber): seq[array[2, float]] =
  ## Circle a must have x, y, and r numerical values
  cirEdges(a.x, a.y, a.r, w, h)
