## helper procs for using Math.random() in the js backend

import jscore
import math

proc randf*(): float =
  ## get a random float [0,1)
  Math.random()

proc randf*(max: SomeNumber): float =
  ## get a random float [0,max)
  max.float * randf()

proc randf*(min, max: SomeNumber): float =
  ## get a random float [min,max)
  min.float + randf(max - min)

proc randi*(max: SomeNumber): int =
  ## get a random int [0,max)
  Math.floor(randf(max))

proc randi*(min, max: int): int =
  ## get a random int [min,max]
  min + randi(max - min + 1)

proc randi*(min, max: float): int =
  ## get a random int [min,max]
  Math.floor(min) + randi(max - min + 1)

proc randEnum*(T: typedesc): T =
  ## get a random instance of an enum type
  T(randi(T.low.ord, T.high.ord))

proc randictr*(ctr, spread: int): int =
  ## get a random int [min,max]
  randi(ctr - spread, ctr + spread)

proc randctr*(): float =
  ## get a random float [-1,1)
  randf(-1.0, 1.0)

proc randctr*(spread: SomeNumber): float =
  ## get a random float [-spread,+spread)
  spread * randctr()

proc randctr*(start, spread: SomeNumber): float =
  ## get a random float in the range: start +/- spread
  start + randctr(spread)

proc randang*(): float =
  ## get a random angle: [0,2pi)
  randf(TAU)

proc randnth*[T](s: openArray[T]): T =
  ## get a random element from a seq or array
  s[randi(s.len)]
