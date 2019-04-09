
import dom

import canvas

when isMainModule:
  echo("Hello, World!")

proc drawRect(ctx: CanvasContext2d) =
  ctx.beginPath()
  ctx.fillStyle = ("rgb(" & $100 & "," & $200 & "," & $50 & ")")
  ctx.fillRect(10,20,30,40)
  ctx.closePath()

dom.window.onload = proc (e: dom.Event) =
  echo "onload"
  let c = dom.document.getElementById("canvas").Canvas
  let ctx = c.getContext2d()
  ctx.drawRect()

