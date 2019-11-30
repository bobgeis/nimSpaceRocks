## This has typs and procs to help deal handle spawning new hooligans.  It needs to be in a separate file from the interact/hooligan


import ./hooligan

type
  HooliganTimer* = ref object
    threshold*: int
    spawnCount*: int
    hooligan*: Hooligan
    incoming*: bool
    ticks*: int

const
  delay = 300

func nextThreshold(spawnCount:int):int =
  ## Get the next threshold
  100 + spawnCount * 50

proc newHooliganTimer*(): HooliganTimer =
  ## Create a new hooligan timer object
  result = HooliganTimer(
    threshold: nextThreshold(0),
    spawnCount: 0,
    hooligan: newHooligan(),
    incoming: false,
    ticks: delay,
  )

proc prepHooligan*(timer:var HooliganTimer, rockScore: int) =
  ## A hooligan was just released, prep a new one.
  let
    difficulty = rockScore/100
  timer.hooligan = newHooligan(difficulty)
  timer.spawnCount += 1
  timer.incoming = false
  timer.threshold = timer.spawnCount.nextThreshold()
  timer.ticks = delay
