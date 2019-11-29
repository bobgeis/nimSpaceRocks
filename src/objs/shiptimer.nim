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
  initMaxRoll = 150
  initMinRoll = 50
  lowMaxRoll = 50
  lowMinRoll = 10
  numRolls = 4
  speedUp = 1.0

# creation

proc newShipTimer*(): ShipTimer =
  result = ShipTimer(
    ship: newRandShip(0),
    ticks: 0,
  )

# manipulation

proc prepShip*(timer: var ShipTimer, lootScore: int = 0) =
  ## put a new ship with a new countdown into the timer
  let
    difficulty = lootScore/100
    maxRoll = max(floor(initMaxRoll - difficulty * speedUp), lowMaxRoll)
    minRoll = max(floor(initMinRoll - difficulty * speedUp), lowMinRoll)
  var
    ticks = 0
  for i in 0..numRolls:
    ticks += randi(minRoll, maxRoll)
  timer.ship = newRandShip(difficulty)
  timer.ticks = ticks
