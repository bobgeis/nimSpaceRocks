## Interact ships with the edge of the game scene.
## When they hit the edge, they should warp out

import algorithm

import ../helper/utils

import ../common
import ../scene

import ../objs/boom
import ../objs/ship

proc interactEdgeShip*(scene: var Scene) =
  ## interact the ships with the edges of the game scene
  var
    cull: seq[Natural] = @[]
  for i, obj in scene.ships:
    if obj.isOffEdge:
      cull.add i
      scene.booms.add newBoom(obj, xkOut, xeClamp)
      scene.shipsSafe += 1
  scene.ships.deleteIndices cull
