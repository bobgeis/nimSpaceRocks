## This file handles player-bullet interactions.
## This means handle if the player is firing and
## create bullets as necessary

import ../scene

import ../objs/bullet
import ../objs/player

proc interactBulletPlayer*(scene: var Scene) =
  ## interact fire new bullets
  if not scene.player.alive: return
  if scene.player.firing and scene.player.cd == 0:
    scene.bullets.createBullets(scene.player, scene.player.multiShots > 0,
        scene.player.ringShots > 0)
