
import math

import ../helper/jsrand

import ./rock

type
  RockTimer* = ref object
    rock*: Rock
    ticks*: int

const
  initMaxRoll = 150
  initMinRoll = 50
  lowMaxRoll = 50
  lowMinRoll = 10
  numRolls = 4
  speedUp = 1.0

# creation

proc newRockTimer*(): RockTimer =
  result = RockTimer(
    rock: spawnRock(),
    ticks: 0,
  )

# manipulation

proc newRock*(timer: var RockTimer, shipScore: int) =
  ## put a new rock with a new countdown into the timer
  let
    difficulty = shipScore/100
    maxRoll = max(floor(initMaxRoll - difficulty * speedUp), lowMaxRoll)
    minRoll = max(floor(initMinRoll - difficulty * speedUp), lowMinRoll)
  var
    ticks = 0
  for i in 0..numRolls:
    ticks += randi(minRoll, maxRoll)
  timer.rock = spawnRock(difficulty)
  timer.ticks = ticks
