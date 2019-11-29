## Interact rocks with ships
## * rocks should destroy ships
## * destroyed ships should explode
## * and drop loot

import sequtils

import ../helper/geom
import ../helper/jsrand
import ../helper/utils

import ../scene

import ../objs/boom
import ../objs/loot
import ../objs/particle
import ../objs/rock
import ../objs/ship

proc getLoot(obj: Ship): seq[Loot] =
  ## get a seq of loot objects for the ship
  let
    loots = case obj.kind
      of skLiner: @[lkPod, lkPod, lkPod, lkPod]
      of skMiner: @[lkPod, lkPod, lkGem, lkGem]
      of skMedic: @[lkPod, lkPod, lkPod, lkPod, lkPod]
      of skGuild: @[lkPod, lkPod, lkGem, lkGem, lkGem]
      of skScience: @[lkPod, lkPod, lkGem, lkPod, lkGem, lkGem]
      of skPolice: @[lkPod, lkPod, lkPod, lkGem, lkPod, lkPod]
    i = randi(1, loots.len)
  loots[0..<i].mapIt(obj.newLoot(it))

proc interactRockShip*(scene: var Scene) =
  ## interact rocks with ships
  var
    cull: seq[Natural] = @[]
  for i, obj in scene.ships:
    for rock in scene.rocks:
      if cirCollide(obj, rock):
        cull.add i
        scene.booms.add obj.newBoom(xkEx, xeClamp)
        scene.particles.addParticlesOn obj
        for loot in obj.getLoot():
          scene.loots.add loot
        break
  scene.ships.deleteIndices cull
