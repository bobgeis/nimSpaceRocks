## Utility functions for drawing sprites on a canvas 2d context.

import ./canvas2d

var
  pixelRatio* = 2.0

proc setPixelRatio*(ratio:float) =
  ## set the pixelRatio for future transforms
  pixelRatio = ratio

proc adjustForPixelratio*(c:Canvas,ctx:Context,w,h:float) {.inline.} =
  c.width = w * pixelRatio
  c.height = h * pixelRatio
  c.style.width = $w & "px"
  c.style.height = $h & "px"
  ctx.scale(pixelRatio,pixelRatio)

proc adjustForPixelratio*(c:Canvas,w,h:float) {.inline.} =
  ## adjust a canvas for the pixelRatio
  c.adjustForPixelratio(c.getContext(),w,h)

proc adjustForPixelratio*(ctx:Context,w,h:float) {.inline.} =
  ## adjust a canvas for the pixelRatio
  ctx.canvas.adjustForPixelratio(ctx,w,h)

type
  ImageDimensions* = ref object ## the size of an image on a canvas \
  ## x,y are coordinates of upper left corner, cx,cy are coodrinates of center, w,h are width and height
  ## for single image canvases, x,y=0, cx,cy= w/2,h/2
  ## for sprite sheets it's more complicated
    x*,y*,w*,h*,cx*,cy*:float

  ImageTransform* = ref object
    xScale*,xSkew*,ySkew*,yScale*:float

proc newImageDimensions*(x,y,w,h:float): ImageDimensions =
  ## Return a new ImageDimensions object with x,y,w,h,cx,cy defined. x,y are the top left corner of the sprite, w,h are the size of the sprite, cx,cy are the center of the sprite.
  ImageDimensions(x:x,y:y,w:w,h:h,cx:x+w/2.0,cy:y+h/2.0)

proc newImageDimensions*(w:float): ImageDimensions {.inline.} =
  ## Return a new ImageDimensions object with x,y,w,h,cx,cy defined. The 1 arg form assumes this is a square 1 sprite canvas, so x=y=0, w=h, and cx=cy=w/2.
  newImageDimensions(0.0,0.0,w,w)

proc newImageTransform*(xScale,xSkew,ySkew,yScale:float): ImageTransform =
  ## This defines the scale and skew for x and y when passed to setTransform
  ImageTransform(xScale:xScale,xSkew:xSkew,ySkew:ySkew,yScale:yScale)

proc newImageTransform*(xScale,yScale:float):ImageTransform {.inline.} =
  ## This defines the scale and skew for x and y when passed to setTransform. The 2 arg form is just x and y scaling.
  newImageTransform(xScale,0.0,0.0,yScale)

proc newImageTransform*(scale:float):ImageTransform {.inline.} =
  ## This defines the scale and skew for x and y when passed to setTransform. The 1 arg form scales symmetrically in x and y
  newImageTransform(scale,0.0,0.0,scale)

let defaultTransform* = newImageTransform(1.0)

proc setTransform*(ctx:Context, x,y:float, trans: ImageTransform) {.inline.}=
  ## Set the transform using an ImageTransform object and translation coordinates. Maintains pixel ratios.
  ctx.setTransform(
    trans.xScale, trans.xSkew,
    trans.ySkew, trans.yScale,
    x * pixelRatio, y * pixelRatio)

proc setTransform*(ctx:Context, x,y,sx,sy:float) {.inline.}=
  ## Context setTransform just x,y translation and x,y scaling. Maintains pixel ratios.
  ctx.setTransform(
    sx, 0.0,
    0.0, sy,
    x * pixelRatio, y * pixelRatio)

proc setTransform*(ctx:Context, x,y,scale:float) {.inline.}=
  ## Context setTransform just x,y translation and x,y scaling. Maintains pixel ratios.
  ctx.setTransform(
    scale, 0.0,
    0.0, scale,
    x * pixelRatio, y * pixelRatio)

proc setTransform*(ctx:Context, x,y:float) {.inline.}=
  ## Context setTransform just x,y translation. Maintains pixel ratios.
  ctx.setTransform(
    1.0, 0.0,
    0.0, 1.0,
    x * pixelRatio, y * pixelRatio)

proc drawSprite*(ctx: Context, img: Canvas, x,y,a:float, size: ImageDimensions, trans: ImageTransform, alpha=1.0) =
  ## Draw an img canvas onto a context
  ## ## Signatures:
  ##    * ctx,img,x,y,a,size,trans,alpha
  ## ## Arguments
  ## * ctx is the destination Context,
  ## * img is the source Canvas
  ## * x,y are the coordinates in ctx to center img onto
  ## * a is the angle in radians to rotate img by
  ## * size is an ImageDimensions specifying the image on the source canvas
  ## * trans is an ImageTransform specifying scale and skew
  ## * alpha is the alpha channel to set for this drawing
  ctx.setTransform x, y, trans
  ctx.rotate a
  ctx.globalAlpha = alpha
  ctx.drawImage img,size.x,size.y,size.w,size.h,-size.cx,-size.cy,size.w,size.h

proc drawSprite*(ctx:Context, img:Canvas, x,y,a:float, size:ImageDimensions, alpha:float) =
  ## Draw a simple sprite.  Note that this assumes that there is only one sprite on the source canvas and draws the whole thing.
  ctx.setTransform x,y
  ctx.rotate a
  ctx.globalAlpha = alpha
  ctx.drawImage img, -size.cx,- size.cy

proc drawSprite*(ctx:Context, img:Canvas, x,y,a:float, size:ImageDimensions, scale:float) =
  ## Draw a simple sprite.  Note that this assumes that there is only one sprite on the source canvas and draws the whole thing.
  ctx.setTransform x,y,scale
  ctx.rotate a
  ctx.drawImage img, -size.cx,- size.cy

proc drawSprite*(ctx:Context, img:Canvas, x,y,a:float, size:ImageDimensions) =
  ## Draw a simple sprite.  Note that this assumes that there is only one sprite on the source canvas and draws the whole thing.
  ctx.setTransform x,y
  ctx.rotate -a
  ctx.drawImage img, -size.cx,- size.cy
