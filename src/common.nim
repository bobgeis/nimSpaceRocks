## this contains constants and common utility functions
## that are specific to the spacerocks game
## that is, if they were more generalizeable
## they would be in one of the helper modules
## but they are still needed in multiple places

import jscore, math

import ./helper/colors
import ./helper/geom
import ./helper/jsrand

type
  Side* = enum
    sideNorth, sideEast, sideSouth, sideWest,

when not defined small:
  const CANVAS_WIDTH* = 800.0
else:
  const CANVAS_WIDTH* = 400.0

const
  # commonFontStyle* = "10px Lucida Console"
  commonFontStyle* = "10px Andale Mono"
  titleFontStyle* = "16px Arial"
  textCharPxWidth* = 6.0
  textCharPxheight* = 10.0
  CANVAS_HEIGHT* = CANVAS_WIDTH * 1080.0 / 1584.0
  xCtr* = CANVAS_WIDTH / 2
  yCtr* = CANVAS_HEIGHT / 2
  xMax* = CANVAS_WIDTH
  yMax* = CANVAS_HEIGHT
  pastColors* = (rgb("250","0","175","0.25"),rgb("250","0","175","0.25"))
  futureColors* = (rgb("20","190","250","0.25"),rgb("20","190","250","0.25"))

func wrapX*(x: float): float = wrap(x, CANVAS_WIDTH)
func wrapY*(y: float): float = wrap(y, CANVAS_HEIGHT)
proc wrapObj*[Obj](obj: var Obj) =
  ## wrap an obj with x,y coords to within the canvas
  obj.x = wrapX(obj.x)
  obj.y = wrapY(obj.y)

func clampX*(x: float): float = clamp(x, CANVAS_WIDTH)
func clampY*(y: float): float = clamp(y, CANVAS_HEIGHT)
proc clampObj*[Obj](obj: var Obj) =
  ## clamp an obj with x,y coords to within the canvas
  obj.x = clampX(obj.x)
  obj.y = clampY(obj.y)

proc edgesObj*[Obj](obj: Obj): seq[array[2, float]] =
  ## if an object is near the edges or corners of the area
  ## get the wrapped positions of that object
  ## obj needs x,y, and r fields
  ## example use case: an object is near the edge or corner
  ## and it needs to be drawn at the opposite side or
  ## all four corners
  cirEdges(obj, CANVAS_WIDTH, CANVAS_HEIGHT)

func isOffEdge*[Obj](obj: Obj): bool =
  # is the given object off the view edge?
  if obj.x < 0.0: true
  elif obj.x > CANVAS_WIDTH: true
  elif obj.y < 0.0: true
  elif obj.y > CANVAS_HEIGHT: true
  else: false

proc randSide*(): Side =
  ## choose a random side
  randEnum(Side)

proc randEdgePt*(side: Side = randSide()): (float, float) =
  ## get a random point on the edge of the game area
  ## offset by one px into the game area to avoid edge effects
  case side
  of sideNorth: (randf(CANVAS_WIDTH), 1.0)
  of sideSouth: (randf(CANVAS_WIDTH), CANVAS_HEIGHT - 1.0)
  of sideWest: (1.0, randf(CANVAS_HEIGHT))
  of sideEast: (CANVAS_WIDTH - 1.0, randf(CANVAS_HEIGHT))

proc randAngleIn*(side: Side = randSide(), da: float = TAU * 0.15): float =
  ## get a random angle pointing from the given side into the play area
  case side
  of sideNorth: randctr(TAU * 0.75, da)
  of sideSouth: randctr(TAU * 0.25, da)
  of sideEast: randctr(TAU * 0.5, da)
  of sideWest: randctr(TAU * 0.0, da)

# drawing

func getGlowColors*(ratio: float, hue: float = 180.0): (string, string) =
  ## get glow colors
  (
    hsl(
      hue,
      60 + 40 * ratio,
      55 + 45 * ratio,
  ),
    hsl(
      hue - 20 + 20 * ratio,
      30 + 40 * ratio,
      45 + 35 * ratio,
  ))

const
  numGlowColors* = 16
  step:float = 1 / (numGlowColors-1)
  hueOfEvil* = 300.0

proc makeDiscreteGlowColors(hue: float = 180.0): array[numGlowColors,(string,string)] =
  ## make and return the array of discrete glow colors
  for i in 0..<numGlowColors:
    result[i] = getGlowColors(step * i.float,hue)

let
  discreteGlowColors* = makeDiscreteGlowColors()
  discreteEvilColors* = makeDiscreteGlowColors(hueOfEvil)

proc ratioToGlowOffset*(ratio:float): int =
  ## get the offset of discreteGlowColor array for the given ratio
  if ratio >= 1.0:
    discreteGlowColors.high
  elif ratio <= 0.0:
    discreteGlowColors.low
  else:
    Math.floor(ratio * numGlowColors.float)
