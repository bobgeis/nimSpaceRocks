## this contains procs to draw cargo/score/powerups/etc

import strformat

import ../helper/canvas2d

import ../common
import ../scene

import ../objs/base
import ../objs/loot

proc roundRectPath(ctx:Context, x,y,w,h:float, r: float = 8.0) =
  ## Use this to make a rect with rounded corners, then fill or stroke as you wish.
  let
    a = x + w
    b = y + h
  ctx.beginPath()
  ctx.moveTo(x+r, y)
  ctx.lineTo(a-r, y)
  ctx.quadraticCurveTo(a, y, a, y+r)
  ctx.lineTo(a, y+h-r)
  ctx.quadraticCurveTo(a, b, a-r, b)
  ctx.lineTo(x+r, b)
  ctx.quadraticCurveTo(x, b, x, b-r)
  ctx.lineTo(x, y+r)
  ctx.quadraticCurveTo(x, y, x+r, y)

proc drawTextCentered(ctx:Context,x,y:float,str:string, minW=0.0, minH=0.0) =
  ## draw the line of text centered on x,y
  let
    w = max(str.len.float * textCharPxWidth + 8.0,minW)
    h = max(textCharPxheight + 8.0,minH)
  ctx.beginPath()
  ctx.fillStyle = "rgba(0,0,50,0.5)"
  ctx.roundRectPath(x - 0.5*w, y - 0.5*h, w, h)
  ctx.fill
  ctx.fillStyle = "#FFFFFF"
  ctx.fillText str, x, y

proc drawFPS*(ctx:Context,dt:float) =
  ## Draw a frames per second counter
  ctx.drawTextCentered(50.0,yMax-50.0,&"fps: {1000/dt:>3.0f}")

proc drawScore*(ctx: Context, scene: Scene) =
  ## draw the ui for the given scene
  var strs = @[""]
  strs.add "  Score  "
  strs.add &"Pods:  {scene.delivered[lkPod]:>4}"
  strs.add &"Gems:  {scene.delivered[lkGem]:>4}"
  strs.add &"Rocks: {scene.rockScore:>4}"
  strs.add &"Ships: {scene.shipScore:>4}"
  if scene.cargo[lkPod] > 0 or scene.cargo[lkGem] > 0:
    strs.add ""
    strs.add "  Cargo  "
  if scene.cargo[lkPod] > 0:
    strs.add &"Pods:  {scene.cargo[lkPod]:>4}"
  if scene.cargo[lkGem] > 0:
    strs.add &"Gems:  {scene.cargo[lkGem]:>4}"
  if scene.player.ringShots > 0 or scene.player.multiShots > 0:
    strs.add ""
    strs.add " Powerup "
  if scene.player.ringShots > 0:
    strs.add &"Ring:  {scene.player.ringShots:>4}"
  if scene.player.multiShots > 0:
    strs.add &"Multi: {scene.player.multiShots:>4}"
  const
    ix = 15.0 + textCharPxWidth * 9.0 * 0.5
    dx = 0.0
    iy = textCharPxHeight * 0.5
    xRect = 5.0
    yRect = 5.0
    wRect = 10.0 + textCharPxWidth * 9.0 + 10.0
  var
    dy = 0.0
    hRect = yRect + textCharPxHeight * strs.len.float
  ctx.beginPath()
  ctx.fillStyle = "rgba(0,0,50,0.5)"
  ctx.roundRectPath(xRect,yRect,wRect, hRect)
  ctx.fill()
  ctx.closePath()
  ctx.font = commonFontStyle
  ctx.fillStyle = "#FFFFFF"
  for s in strs:
    ctx.fillText s, ix + dx, iy + dy
    dy += 10.0

proc drawHiScore*(ctx:Context, hiscores = [0,0,0,0]) =
  ## draw the four high scores, in order: Pods Rescued, Gems Delivered, Rocks Busted, Ships Protected
  var strs = @[""]
  strs.add " HiScore "
  strs.add &"Pods:  {hiscores[0]:>4}"
  strs.add &"Gems:  {hiscores[1]:>4}"
  strs.add &"Rocks: {hiscores[2]:>4}"
  strs.add &"Ships: {hiscores[3]:>4}"
  const
    ix = 15.0 + textCharPxWidth * 9.0 * 2.0
    dx = 0.0
    iy = textCharPxheight * 0.5
    xRect = 5.0 + textCharPxWidth * 9.0 * 1.5
    yRect = 5.0
    wRect = 10.0 + textCharPxWidth * 9.0 + 10.0
  var
    dy = 0.0
    hRect = yRect + textCharPxHeight * strs.len.float
  ctx.beginPath()
  ctx.fillStyle = "rgba(0,0,50,0.5)"
  ctx.roundRectPath(xRect,yRect,wRect, hRect)
  ctx.fill()
  ctx.font = commonFontStyle
  ctx.fillStyle = "#FFFFFF"
  for s in strs:
    ctx.fillText s, ix + dx, iy + dy
    dy += 10.0

proc drawInstructions*(ctx:Context) =
  ## Draw directions UI elements. Might take up large parts of the screen, should only show while paused.
  const
    gemStr = "Bring gems to the station in the lower left."
    podStr = "Bring lifepods to the station in the upper right."
    omegaStr = "This is your Omega-13 charge.  You can use it to go back in time."
    timetravelStr = "While paused, press left and right to travel back in time."
    keysStr = "Arrow keys move, Space shoots, Enter pauses, Escape restarts."
    saveStr = "While paused, press down to save the game."
    titleStr = "Look out! Space Rocks!"
    objective1 = "Bust the rocks so ships can travel safely."
  # near the sations
  ctx.drawTextCentered(refinery_pos[0],refinery_pos[1] + 30.0,gemStr)
  ctx.drawTextCentered(hospital_pos[0],hospital_pos[1] + 30.0,podStr)
  # near the omega symbol
  ctx.drawTextCentered(xCtr,yMax - 35.0,omegaStr)
  # above the center
  ctx.drawTextCentered(xCtr,yCtr - 30.0,objective1)
  ctx.font = titleFontStyle
  ctx.drawTextCentered(xCtr,yCtr - 60.0,titleStr, 200.0, 30.0)
  ctx.font = commonFontStyle
  # below the center
  ctx.drawTextCentered(xCtr,yCtr + 30.0,keysStr)
  ctx.drawTextCentered(xCtr,yCtr + 50.0,saveStr)
  ctx.drawTextCentered(xCtr,yCtr + 70.0,timetravelStr)

proc init*(ctx:Context) =
  ## Initialize font values
  ctx.font = commonFontStyle
  ctx.textAlign = "center"
  ctx.textBaseline = "middle"
