## handle player-rock interactions
## when the player and the rock collide:
## * player is removed
## * rock is fine
## * game goes to gameover mode
## * loot is dropped

import ../helper/geom

import ../scene

import ../objs/boom
import ../objs/loot
import ../objs/particle
import ../objs/player
import ../objs/rock

proc getPlayerLoot(scene: Scene): seq[Loot] =
  ## get a sequence of loot to disperse on player death
  result = @[]
  result.add scene.player.newLoot(lkPod)
  for i in 0..<scene.cargo[lkPod]:
    result.add scene.player.newLoot(lkPod)
  for i in 0..<scene.cargo[lkGem]:
    result.add scene.player.newLoot(lkGem)

proc interactplayerrock*(scene: var Scene) =
  ## handle player/rock interactions
  if not scene.player.alive: return
  for rock in scene.rocks:
    if scene.player.cirCollide(rock):
      # the player has struck a rock
      scene.player.kill()
      # add an explosion
      scene.booms.add(newBoom(scene.player, xkEx, xeWrap))
      scene.particles.addParticlesOn scene.player
      # add loot
      for loot in scene.getPlayerLoot():
        scene.loots.add loot
