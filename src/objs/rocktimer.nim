
import math

import ../helper/jsrand

import ./rock

type
  RockTimer* = ref object
    rock*: Rock
    ticks*: int

const
  initMaxRoll = 200
  initMinRoll = 50
  lowMaxRoll = 100
  lowMinRoll = 25
  numRolls = 3
  speedUp = 0.5

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
    maxRoll = max(floor(initMaxRoll - shipScore.float * speedUp), lowMaxRoll)
    minRoll = max(floor(initMinRoll - shipScore.float * speedUp), lowMinRoll)
  var
    ticks = 0
  for i in 0..numRolls:
    ticks += randi(minRoll, maxRoll)
  timer.rock = spawnRock()
  timer.ticks = ticks
