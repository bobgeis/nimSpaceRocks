
## Wrapper for html5 canvas API
## * We do need to make our own canvas wrapper, the dom lib doesn't have it.
## * We are only concerned with 2D rendering contexts in this module.
## * For usage, see: https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D
## * For typings, see: https://github.com/Microsoft/TypeScript/blob/master/lib/lib.dom.d.ts
## * It is possible to make a more thorough binding, but this is be good enough for our present use case.

import dom, math

type
  Canvas* = ref CanvasObj
  CanvasObj {.importc.} = object of dom.Element
    width*: float
    height*: float
  CanvasGradient* = ref CanvasGradientObj
  CanvasGradientObj {.importc.} = object
  Context* = ref ContextObj   ## ref of CanvasRenderingContext2D
  ContextObj {.importc.} = object
    canvas*: Canvas           ## ref to the canvas this was taken from
    fillStyle*: cstring       ## default "#000000
    filter*: cstring          ## default "none"
    font*: cstring            ## default "10px sans-serif"
    globalAlpha*: float       ## default 1
    globalCompositeOperation*: cstring ## default "source-over"
    imageSmoothingEnabled*: bool ## default true
    imageSmoothingQuality*: cstring ## default "low"
    lineCap*: cstring         ## default "butt"
    lineJoin*: cstring        ## default "miter"
    lineWidth*: float         ## default 1
    miterLimit*: float        ## default 1
    strokeStyle*: cstring     ## default "#000000"
    textAlign*: cstring       ## default "start"
    textBaseline*: cstring    ## default "alphabetic"
    backingStorePixelRatio*: cstring
    webkitBackingStorePixelRatio*: cstring
    mozBackingStorePixelRatio*: cstring
    msBackingStorePixelRatio*: cstring
    oBackingStorePixelRatio*: cstring


proc getContext*(c: Canvas): Context =
  {.emit: "`result` = `c`.getContext('2d');".}

proc width*(ctx: Context): SomeNumber = ctx.canvas.width ##!
## get the canvas width in px
proc height*(ctx: Context): SomeNumber = ctx.canvas.height ##!
## get the canvas height in px

proc beginPath*(c: Context) {.importcpp.}
proc closePath*(ctx: Context) {.importcpp.}

proc restore*(ctx: Context) {.importcpp.}
proc save*(ctx: Context) {.importcpp.}

proc rotate*(ctx: Context, angle: SomeNumber) {.importcpp.}
proc scale*(ctx: Context, x, y: SomeNumber) {.importcpp.}
proc transform*(ctx: Context, a, b, c, d, e, f: SomeNumber) {.importcpp.}
proc translate*(ctx: Context, x, y: SomeNumber) {.importcpp.}
proc setTransform*(ctx: Context, m11,m12,m21,m22,dx,dy: SomeNumber) {.importcpp.} ## Set current ctx transform to the given values.
  ## * m11 is horizontal scale
  ## * m12 is horizontal skew
  ## * m21 is vertical skew
  ## * m22 is vertical scale
  ## * dx is horizontal translation
  ## * dy is vertical translation

proc moveTo*(ctx: Context, x, y: SomeNumber) {.importcpp.}
proc lineTo*(ctx: Context, x, y: SomeNumber) {.importcpp.}

proc setStrokeStyle*(ctx:Context,style:cstring or CanvasGradient) {.inline.} =
  {.emit: "`ctx`.strokeStyle = `style`;".}
proc setFillStyle*(ctx:Context,style:cstring or CanvasGradient) {.inline.} =
  {.emit: "`ctx`.fillStyle = `style`;".}
proc stroke*(ctx: Context) {.importcpp.}
proc fill*(ctx: Context) {.importcpp.}
proc strokeText*(ctx: Context, txt: cstring, x, y: SomeNumber) {.importcpp.}
proc fillText*(ctx: Context, txt: cstring, x, y: SomeNumber) {.importcpp.}
proc measureText*(ctx: Context, txt: cstring or string):float =
  ## Get the width of the current text string
  {.emit: "`result` = `ctx`.measureText(`txt`).width;".}

proc rect*(ctx: Context, x, y, w, h: SomeNumber) {.importcpp.}
proc clearRect*(ctx: Context, x, y, w, h: SomeNumber) {.importcpp.}
proc strokeRect*(ctx: Context, x, y, w, h: SomeNumber) {.importcpp.}
proc fillRect*(ctx: Context, x, y, w, h: SomeNumber) {.importcpp.}

proc arc*(ctx: Context, x, y, radius, startAngle, endAngle: float,
    anticlockwise = false) {.importcpp.}
proc circle*(ctx: Context, x, y, radius:float) {.inline.} =
  ## Use ctx.arc to make a circle centered on x,y with radius r
  ctx.arc x, y, radius, 0.0, TAU
proc arcTo*(ctx: Context, x1, y1, x2, y2, radius: SomeNumber) {.importcpp.}
proc bezierCurveTo*(ctx: Context, cp1x, cp1y, cp2x, cp2y, x, y: SomeNumber) {.
  importcpp.}
proc ellipse*(ctx: Context, x, y, radiusX, radiusY, rotation, startAngle,
    endAngle: SomeNumber, anticlockwise: bool = false) {.importcpp.}
proc quadraticCurveTo*(ctx: Context, cpx, cpy, x, y: SomeNumber) {.importcpp.}


proc newImageElement*(): ImageElement =
  ## Seems to be necessary to correctly create an ImageElement
  {.emit: "return new Image();".}

proc createCanvas*(): Canvas =
  ## Create and return a new Canvas
  {.emit: "return document.createElement('canvas');".}

proc drawImage*(ctx: Context, image: ImageElement or Canvas, dx, dy: SomeNumber) {.importcpp.}
proc drawImage*(ctx: Context, image: ImageElement or Canvas, dx, dy, dw, dh: SomeNumber) {.importcpp.}
proc drawImage*(ctx: Context, image: ImageElement or Canvas, sx, sy, sw, sh, dx, dy, dw, dh: SomeNumber) {.importcpp.}

## Gradient functions
proc createLinearGradient*(ctx: Context, x0, y0, x1, y1: SomeNumber): CanvasGradient {.importcpp.}
proc createRadialGradient*(ctx: Context, x0, y0, r0, x1, y1, r1: SomeNumber): CanvasGradient {.importcpp.}
proc addColorStop*(grad: CanvasGradient, offset: SomeNumber, color: cstring) {.importcpp.}
