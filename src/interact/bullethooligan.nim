## This file interacts hooligan with player bullets.

import algorithm
import sequtils

import ../helper/geom
import ../helper/jsrand
import ../helper/utils

import ../scene

import ../objs/boom
import ../objs/bullet
import ../objs/hooligan
import ../objs/loot
import ../objs/particle

proc interactBulletHooligan*(scene: var Scene) =
  ## Interact hooligans and the player in this scene.
  # collide player bullets with hooligans
  var
    collidedHooligans: seq[Hooligan] = @[]
    cullHooligans: seq[Natural] = @[]
    cullBullets: seq[Natural] = @[]
  for i, hool in scene.hooligans:
    for j, bullet in scene.bullets:
      if hool.cirCollide(bullet):
        cullHooligans.add i
        collidedHooligans.add hool
        if bullet.ring != bkRing:
          cullBullets.add j
  scene.hooligans.deleteIndices cullHooligans.sorted.deduplicate(true)
  scene.bullets.deleteIndices cullBullets.sorted.deduplicate(true)
  for hool in collidedHooligans:
    scene.booms.add(newBoom(hool, xkEx, xeWrap))
    scene.particles.addParticlesOn hool
    scene.loots.add newLoot(hool,lkPod)
    scene.loots.add newLoot(hool,lkPod)
  # update ship score
  scene.shipScore += cullHooligans.len
