
import ../scene

import ../objs/boom
import ../objs/rockTimer

# interact

proc interactRockTimer*(scene: var Scene) =
  ## update the RockTimer, and add any rock or flash that is ready
  if scene.rockTimer.ticks == 0:
    scene.rocks.add(scene.rockTimer.rock)
    scene.rockTimer.newRock(0)
  else:
    scene.rockTimer.ticks -= 1
  if scene.rockTimer.ticks == xkIn.lifetime:
    scene.booms.add(newBoom(scene.rockTimer.rock, xkIn, xeWrap))
