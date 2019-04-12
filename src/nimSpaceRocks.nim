
import dom
import sugar

import helper/browser
import helper/canvas2d
import helper/sprite

import game
import common

dom.window.onload = proc (e: dom.Event) =
  let
    c = dom.document.getElementById("canvas").Canvas
    loading = dom.document.getElementById("loading")
    ctx = c.getContext()
    pixelRatio = window.devicePixelRatio
  # ctx.imageSmoothingEnabled = false
  pixelRatio.setPixelRatio()
  c.adjustForPixelratio(CANVAS_WIDTH,CANVAS_HEIGHT)

  c.style.background =
    "center center / cover no-repeat url(\"img/stars.jpg\")".cstring
  c.style.borderStyle = "solid".cstring

  var gameRef = newGame(ctx)
  gameRef.init()
  loading.style.width = "0px"
  loading.style.height = "0px"
  addDocEventListener "keydown", (e: Event) => gameRef.keydown(e.KeyEvent)
  addDocEventListener "keyup", (e: Event) => gameRef.keyup(e.KeyEvent)
  rafDt((dt: float) => gameRef.tick(dt))

