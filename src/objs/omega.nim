## this contains procs and data types handling time travel

import deques
import math

import ../helper/canvas2d
import ../helper/flatted

import ../common
import ../scene



type
  Timeline* = Deque[cstring]

const
  maxSecs = 13                ## maximum seconds to go back
  fps = 60.0                  ## ticks per second
  speedup = 5.0               ## going back in time is this much faster
  scenesPerSec = floor(fps / speedup).int ##!
  ## how many scenes should be saved each second
  maxScenes = maxSecs * scenesPerSec ## max number of scenes to save
  pow2 = pow(2.0,ceil(log2(maxScenes.float))).int

var
  timetarget = 0 ##!
    ## the current index of the timeline

proc isNow*():bool = timetarget == 0
proc goToNow*() = timetarget = 0

func omegaCount*(timeline: Timeline): int =
  ## get the time saved in the timeline in seconds
  timeline.len div scenesPerSec

proc omegaCountLeft*(timeline: Timeline): int =
  ## get the time remaining if jumped right now
  (timeline.len - timetarget) div scenesPerSec

# creation

func newTimeline*(): Timeline =
  ## get a new timeline object
  initDeque[cstring](pow2)

# manipulation

proc push*(timeline: var Timeline, scene: Scene) =
    ## save the given scene to the timeline
    timeline.addFirst Flatted.stringify(scene)
    if timeline.len > maxScenes:
      discard timeline.popLast

proc update*(timeline: var Timeline, scene: Scene) =
  ## maybe save the current scene to the timeline
  if scene.tick mod speedup.int == 0:
    timeline.push scene

proc goBack*(timeline: Timeline) =
  timetarget = min(timetarget+1, timeline.len-1)

proc goForward*(timeline: Timeline) =
  timetarget = max(0, timetarget-1)


proc getTimeTargetString*(timeline: var Timeline): cstring =
  timeline[timetarget]

proc getTimeTarget*(timeline: var Timeline): Scene =
  parse[Scene](Flatted, timeline.getTimeTargetString)

proc getTimeTargets*(timeline: var Timeline): tuple[past: seq[Scene], future: seq[Scene]] =
  let
    minT = max(0, timetarget - 5 )
    maxT = min(timetarget + 5, timeline.len - 1)
  var
    past:seq[Scene] = @[]
    future:seq[Scene] = @[]
  for i in timeTarget .. maxT:
    past.add parse[Scene](Flatted, timeline[i])
  for i in minT .. timeTarget:
    future.add parse[Scene](Flatted, timeline[i])
  (past:past,future:future)

proc stopTimeTraveling*(timeline: var Timeline) =
  timeline.shrink timetarget
  timetarget = 0

# draw

proc draw*(ctx: Context, timeline: Timeline) =
  ## draw the omega symbol and it's count at the x/y coords
  ctx.font = titleFontStyle
  let oc = omegaCount(timeline)
  ctx.fillStyle = if oc > 12: "#00FF99"
    elif oc > 10: "#00FF55"
    elif oc > 8: "#00FF00"
    elif oc > 6: "#55FF00"
    elif oc > 4: "#AAFF00"
    elif oc > 2: "#FFFF00"
    elif oc > 0: "#FFAA00"
    else: "#FF5555"
  if isNow():
    ctx.fillText "\u03A9-" & $oc, xCtr, (yMax - 15)
  else:
    ctx.fillText "\u03A9-" & $oc & " -> " & $omegaCountLeft(timeline),
      xCtr, (yMax - 15)
  ctx.font = commonFontStyle

