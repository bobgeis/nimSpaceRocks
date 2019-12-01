## This file handles interactions between the hooligan ships and the player.
## The hooligans should turn to face the player, and fire shots.
## The hooligans' bullets should destroy the player.

import ../helper/geom
import ../helper/jsrand

import ../scene

import ../objs/boom
import ../objs/bullet
import ../objs/hooligan
import ../objs/particle
import ../objs/player

const
  deathChance = 0.3 ## chance for a hooligan shot to kill player

proc interactHooliganPlayer*(scene: var Scene) =
  ## Interact hooligans and the player in this scene.
  if not scene.player.alive: return
  # Fire bullets at the player
  for hool in scene.hooligans:
    hool.a = -hool.angleTo(scene.player)
    if hool.burstShots > 0 and hool.cd == 0:
      scene.bulletsEvil.createBullets(hool, spread=false,
        ring=bkNormal, evil=baEvil)
  # collide evil bullets with the player
  for bullet in scene.bulletsEvil:
    if scene.player.cirCollide(bullet) and randf() < deathChance:
      scene.player.kill()
      # add an explosion
      scene.booms.add(newBoom(scene.player, xkEx, xeWrap))
      scene.particles.addParticlesOn scene.player
      # add loot
      for loot in scene.getCargo():
        scene.loots.add loot


