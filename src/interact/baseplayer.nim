## handle base-player interactions
## when the player and bases overlap:
## * a cargo type is removed
## * score is updated
## * player weapon can change

import ../helper/geom
import ../helper/utils

import ../scene

import ../objs/base
import ../objs/boom
import ../objs/loot
import ../objs/player

const
  shotsPerLoot = 10

proc interactbaseplayer*(scene: var Scene) =
  ## interact the player with the bases
  if not scene.player.alive: return
  for base in scene.bases:
    if scene.player.cirCollide(base):
      let lootkind =
        case base.kind
        of bkHospital:
          scene.player.multiShots += scene.cargo[lkPod] * shotsPerLoot
          lkPod
        of bkRefinery:
          scene.player.ringShots += scene.cargo[lkGem] * shotsPerLoot
          lkGem
      if scene.cargo[lootkind] > 0:
        base.glow = baseMaxGlow
        scene.booms.add(newBoom(base, xkTl, xeWrap))
        scene.delivered[lootkind] += scene.cargo[lootkind]
        scene.cargo[lootkind] = 0
