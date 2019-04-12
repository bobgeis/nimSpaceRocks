## file to handle bullet & rock interactions
## when a bullet hits a rock:
## * the rock should be removed
## * the bullet should be removed
## * an explosion should be added
## * any resulting calves should be added
## * any resulting loot should be added
## * any resulting shrapnel should be added

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
    collidedBullets: seq[Bullet] = @[]
    collidedRocks: seq[Rock] = @[]
    cullBullets: seq[Natural] = @[]
    cullRocks: seq[Natural] = @[]
  # check collisions
  for i, rock in scene.rocks:
    for j, bullet in scene.bullets:
      if cirCollide(rock, bullet):
        cullRocks.add i
        collidedRocks.add rock
        cullBullets.add j
        collidedBullets.add bullet
  # cull rocks and bullets
  scene.rocks.deleteIndices cullRocks.sorted.deduplicate(true)
  scene.bullets.deleteIndices cullBullets.sorted.deduplicate(true)
  # make calves
  for rock in collidedRocks:
    for calf in rock.makeCalves:
      scene.rocks.add calf
  # explosions
  for rock in collidedRocks:
    scene.booms.add(newBoom(rock, xkEx, xeWrap))
    scene.particles.addParticlesOn rock
  # loot
  for rock in collidedRocks:
    if randf() < rock.mat.gemChance:
      scene.loots.add(newLoot(rock, lkGem))
  # update rock score
  scene.rocksBusted += collidedRocks.len
  # shrapnel
  for bullet in collidedBullets:
    if bullet.shatter:
      scene.bullets.addShrapnel(bullet)
      scene.booms.add(newBoom(bullet,xkOut))
