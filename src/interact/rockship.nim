## Interact rocks with ships
## * rocks should destroy ships
## * destroyed ships should explode
## * and drop loot

import ../helper/geom
import ../helper/utils

import ../scene

import ../objs/boom
import ../objs/particle
import ../objs/rock
import ../objs/ship

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
        scene.loots.addLoot(obj)
        break
  scene.ships.deleteIndices cull
