## handle base-player interactions
## when the player and bases overlap:
## * a cargo type is removed
## * score is updated
## * player weapon can change

import ../helper/geom
import ../helper/utils

import ../scene

import ../objs/base
import ../objs/loot
import ../objs/player

const
  ticksPerLoot = 180 ##!
    ## the number of ticks a bonus lasts per loot item delivered

proc interactbaseplayer*(scene: var Scene) =
  ## interact the player with the bases
  if not scene.player.alive: return
  for base in scene.bases:
    if scene.player.cirCollide(base):
      let lootkind =
        case base.kind
        of bkHospital:
          scene.player.spreadTime += scene.cargo[lkPod] * ticksPerLoot
          lkPod
        of bkRefinery:
          scene.player.burstTime += scene.cargo[lkGem] * ticksPerLoot
          lkGem
      base.glow = baseMaxGlow
      scene.delivered[lootkind] += scene.cargo[lootkind]
      scene.cargo[lootkind] = 0
