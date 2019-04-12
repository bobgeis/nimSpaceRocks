
import ../scene

import ../objs/boom
import ../objs/shiptimer

# interact

proc interactShipTimer*(scene: var Scene) =
  ## update the ShipTimer, and add any ship or flash that is ready
  if scene.shipTimer.ticks == 0:
    scene.ships.add(scene.shipTimer.ship)
    scene.shipTimer.prepShip(0)
  else:
    scene.shipTimer.ticks -= 1
  if scene.shipTimer.ticks == xkIn.lifetime:
    scene.booms.add(newBoom(scene.shipTimer.ship, xkIn, xeClamp))
