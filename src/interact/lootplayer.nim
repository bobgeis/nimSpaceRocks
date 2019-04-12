## handle player-loot interactions
## when the player and loot collide:
## * loot is removed
## * player is fine
## * player cargo is increased

import algorithm

import ../helper/geom
import ../helper/utils

import ../scene

import ../objs/loot
import ../objs/player

proc interactlootplayer*(scene: var Scene) =
  ## Interact player with loot: pick up the loot into cargo.
  if not scene.player.alive: return
  var
    cull: seq[Natural] = @[]
  for i, loot in scene.loots:
    if scene.player.cirCollide(loot):
      cull.add i
      scene.cargo[loot.kind] += 1
  scene.loots.deleteIndices cull
  return
