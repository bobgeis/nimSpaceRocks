## Interact the hooligan timer with time!  This is what actually gets the hooligans spawned into the game scene.

import ../scene

import ../objs/boom
import ../objs/hooliganTimer

# interact

proc interactHooliganTimer*(scene: var Scene) =
  ## update the RockTimer, and add any rock or flash that is ready
  if scene.hooliganTimer.ticks == 0:
    scene.hooligans.add(scene.hooliganTimer.hooligan)
    scene.hooliganTimer.prepHooligan(scene.rockScore)
  elif scene.hooliganTimer.incoming:
    scene.hooliganTimer.ticks -= 1
    if scene.hooliganTimer.ticks == xkEvil.lifetime:
      scene.booms.add(newBoom(scene.hooliganTimer.hooligan, xkEvil, xeWrap))
  elif scene.hooliganTimer.threshold < scene.rockScore:
    scene.hooliganTimer.incoming = true


