## We need to have objs/shiptimer.nim with the types
## so that it can be imported by scene.nim.

import math

import ../helper/jsrand

import ./ship

type
  ShipTimer* = object
    ship*: Ship
    ticks*: int

const
  initMaxRoll = 200
  initMinRoll = 50
  lowMaxRoll = 100
  lowMinRoll = 25
  numRolls = 3
  speedUp = 0.5

# creation

proc newShipTimer*(): ShipTimer =
  result = ShipTimer(
    ship: newRandShip(),
    ticks: 0,
  )

# manipulation

proc prepShip*(timer: var ShipTimer, shipScore: int) =
  ## put a new ship with a new countdown into the timer
  let
    maxRoll = max(floor(initMaxRoll - shipScore.float * speedUp), lowMaxRoll)
    minRoll = max(floor(initMinRoll - shipScore.float * speedUp), lowMinRoll)
  var
    ticks = 0
  for i in 0..numRolls:
    ticks += randi(minRoll, maxRoll)
  timer.ship = newRandShip(0.0)
  timer.ticks = ticks
