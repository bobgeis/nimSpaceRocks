## This interacts NPC ships with good and evil bullets

import algorithm
import sequtils

import ../helper/geom
import ../helper/jsrand
import ../helper/utils

import ../scene

import ../objs/boom
import ../objs/bullet
import ../objs/particle
import ../objs/ship

proc interactBulletShip*(scene: var Scene) =
  ## Interact NPC ships with good and evil bullets
  # collide ships with evil bullets and destroy them
  var
    cullShips: seq[Natural] = @[]
    cullBulletsEvil: seq[Natural] = @[]
  for i, obj in scene.ships:
    for j, bullet in scene.bulletsEvil:
      if obj.cirCollide(bullet):
        cullShips.add i
        scene.booms.add obj.newBoom(xkEx, xeClamp)
        scene.particles.addParticlesOn obj
        scene.loots.addLoot(obj)
        if bullet.ring != bkRing:
          cullBulletsEvil.add j
        break
  scene.ships.deleteIndices cullShips.sorted.deduplicate(true)
  scene.bulletsEvil.deleteIndices cullBulletsEvil.sorted.deduplicate(true)
