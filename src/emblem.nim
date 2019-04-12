
import math

import helper/canvas2d


proc emblemTeeBar*(ctx: Context, d: float, color: string) =
  ## draw the tee-bar emblem
  ctx.beginPath()
  ctx.lineWidth = 0.2*d
  ctx.strokeStyle = color
  ctx.moveTo(0.375*d, -0.400*d)
  ctx.lineTo(0.375*d, 0.400*d)
  ctx.moveTo(0.075*d, -0.400*d)
  ctx.lineTo(0.075*d, 0.400*d)
  ctx.moveTo(0.075*d, 0.0)
  ctx.lineTo(-0.475*d, 0.0)
  ctx.stroke()
  ctx.closePath()

proc emblemFatCross*(ctx: Context, d:float, color:string) =
  ## draw the fat-cross emblem
  ctx.beginPath()
  ctx.lineWidth = 0.325 * d
  ctx.strokeStyle = color
  ctx.moveTo -0.475*d, 0.0
  ctx.lineTo 0.475*d, 0.0
  ctx.moveTo 0.0, -0.475*d
  ctx.lineTo 0.0, 0.475*d
  ctx.stroke()
  ctx.closePath()

proc emblemPipeTriangle*(ctx: Context, d:float, color:string) =
  ## draw the pipe-triangle emblem
  ctx.beginPath()
  ctx.lineWidth = 0.125 * d
  ctx.strokeStyle = color
  ctx.moveTo -0.1*d, 0.0
  ctx.lineTo -0.1*d, 0.350*d
  ctx.lineTo 0.375*d, 0.0
  ctx.lineTo -0.1*d, -0.350*d
  ctx.lineTo -0.1*d, 0.0
  ctx.moveTo 0.150*d, 0.0
  ctx.lineTo -0.450*d, 0.0
  ctx.stroke()
  ctx.closePath()

proc emblemShield*(ctx: Context, d:float, color:string) =
  ## draw the shield emblem
  ctx.beginPath()
  ctx.fillStyle = color
  ctx.moveTo 0.4*d, 0.4*d
  ctx.lineTo 0.4*d, -0.4*d
  ctx.lineTo 0.0, -0.4*d
  ctx.lineTo -0.4*d, 0.0
  ctx.lineTo 0.0, 0.4*d
  ctx.fill()
  ctx.closePath()

proc emblemWidget*(ctx: Context, d:float, color:string) =
  ## draw the widget emblem
  ctx.beginPath()
  ctx.strokeStyle = color
  ctx.lineWidth = 0.2*d
  ctx.moveTo -0.2*d, -0.125*d
  ctx.lineTo 0.475*d, -0.125*d
  ctx.moveTo -0.2*d, 0.125*d
  ctx.lineTo 0.475*d, 0.125*d
  ctx.moveTo -0.475*d, -0.375*d
  ctx.lineTo 0.150*d, -0.375*d
  ctx.lineTo 0.150*d, 0.375*d
  ctx.lineTo -0.375*d, 0.375*d
  ctx.lineTO -0.375*d, -0.375*d
  ctx.stroke()
  ctx.closePath()

proc emblemThreeEllpises*(ctx: Context, d:float, color:string) =
  ## draw the three ellipses emblem
  ctx.strokeStyle = color
  ctx.lineWidth = 0.075*d
  ctx.beginPath()
  ctx.ellipse 0.0, 0.0, 0.45*d, 0.15*d, 0.0, 0.0, TAU
  ctx.stroke()
  ctx.closePath()
  ctx.beginPath()
  ctx.ellipse 0.0, 0.0, 0.45*d, 0.15*d, TAU / 6.0, 0.0, TAU
  ctx.stroke()
  ctx.closePath()
  ctx.beginPath()
  ctx.ellipse 0.0, 0.0, 0.45*d, 0.15*d, -TAU / 6.0, 0.0, TAU
  ctx.stroke()
  ctx.closePath()

proc emblemDiamond*(ctx: Context, d:float, color:string) =
  ## draw the diamond emblem
  ctx.strokeStyle = color
  ctx.lineWidth = 0.25*d
  ctx.beginPath()
  ctx.moveTo(-0.4*d,0.0)
  ctx.lineTo(0.0,-0.4*d)
  ctx.lineTo(0.4*d,0.0)
  ctx.lineTo(0.0,0.4*d)
  ctx.lineTo(-0.4*d,0.0)
  ctx.lineTo(0.0,-0.4*d)
  ctx.stroke()
  ctx.closePath()
