## some miscellaneous browser functions

import dom


## raf functions

var
  rafToken* = 0               ## the raf cancellation token
  rafTime* = 0.0              ## for tracking delta time between rafs

proc rafDt*(p: proc(dt: float)) =
  ## request animation frame wrapper:
  ## wrap a proc so it gets passed dt (delta time)
  ## otherwise it would just get passed the timestamp
  ## also saves the raf token for later cancellation
  proc cb(time: float) =
    let dt = time - rafTime
    rafTime = time
    p(dt)
    rafToken = window.requestAnimationFrame(cb)
  cb(0)

proc cancelRaf*() =
  ## cancel the raf
  window.cancelAnimationFrame(rafToken)


## input


type
  KeyEvent* = ref object of Event ##!
  ## the default event doesn't have all the fields present in keyboard events
    # altKey: bool
    # ctrlKey: bool
    metaKey*: bool
    # shiftKey: bool
    key*: cstring
    code*: cstring
    repeat*: bool


proc addDocEventListener*(event: cstring, callback: proc(e: Event),
    useCapture: bool = false) =
  ## add an event listener to the document itself
  ## this is good for top level events such as key input or window resizing
  document.addEventListener(event, callback, useCapture)

## local storage

type
  Storage* = ref object

var
  localStorage* {.importc, nodecl.}: Storage

proc key*(ls: Storage, n: SomeNumber): cstring {.importcpp.}
proc getItem*(ls: Storage, k: cstring): cstring {.importcpp.}
proc setItem*(ls: Storage, k,v: cstring) {.importcpp.}
proc removeItem*(ls: Storage, k: cstring) {.importcpp.}
