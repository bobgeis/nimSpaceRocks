## file to handle bullet & rock interactions
## when a bullet hits a rock:
## * the rock should be removed
## * the bullet should be removed
## * an explosion should be added
## * any resulting calves should be added
## * any resulting loot should be added

import algorithm
import sequtils

import ../helper/geom
import ../helper/jsrand
import ../helper/utils

import ../scene

import ../objs/boom
import ../objs/bullet
import ../objs/loot
import ../objs/particle
import ../objs/rock

proc interactbulletrock*(scene: var Scene) =
  ## collide bullets and rocks and handle consequences
  var
    collidedRocks: seq[Rock] = @[]
    cullRocks: seq[Natural] = @[]
    cullBullets: seq[Natural] = @[]
    cullBulletsEvil: seq[Natural] = @[]
  # check collisions
  for i, rock in scene.rocks:
    for j, bullet in scene.bullets:
      if cirCollide(rock, bullet):
        cullRocks.add i
        collidedRocks.add rock
        if not bullet.ring:
          cullBullets.add j
    # repeat for evil bullets
    for j, bullet in scene.bulletsEvil:
      if cirCollide(rock, bullet):
        cullRocks.add i
        collidedRocks.add rock
        if not bullet.ring:
          cullBulletsEvil.add j
  # cull rocks and bullets
  scene.rocks.deleteIndices cullRocks.sorted.deduplicate(true)
  scene.bullets.deleteIndices cullBullets.sorted.deduplicate(true)
  scene.bulletsEvil.deleteIndices cullBulletsEvil.sorted.deduplicate(true)
  # make calves & explosions & loot
  for rock in collidedRocks:
    scene.rocks.addCalves rock
    scene.booms.add(newBoom(rock, xkEx, xeWrap))
    scene.particles.addParticlesOn rock
    if randf() < rock.mat.gemChance:
      scene.loots.add(newLoot(rock, lkGem))
  # update rock score
  scene.rockScore += collidedRocks.len
