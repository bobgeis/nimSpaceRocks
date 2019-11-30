## this has types and some simple functions for Scene objects
## many important procs using this will be in other files

# import math

import helper/canvas2d

import objs/base
import objs/boom
import objs/bullet
import objs/hooligan
import objs/hooligantimer
import objs/loot
import objs/particle
import objs/player
import objs/rock
import objs/rocktimer
import objs/ship
import objs/shiptimer

type
  Scene* = ref object
    tick*: int
    player*: Player
    bases*: seq[Base]
    booms*: seq[Boom]
    bullets*: seq[Bullet]
    bulletsEvil*: seq[Bullet]
    hooligans*: seq[Hooligan]
    hooliganTimer*: HooliganTimer
    loots*: seq[Loot]
    particles*: seq[Particle]
    rocks*: seq[Rock]
    rockTimer*: RockTimer
    ships*: seq[Ship]
    shipTimer*: ShipTimer
    cargo*: array[LootKind, int]
    delivered*: array[LootKind, int]
    rockScore*: int
    shipScore*: int

# creation

proc newScene*(): Scene =
  ## get a new starting scene
  result = Scene(
    tick: 0,
    player: newPlayer(),
    bases: @[newHospitalBase(), newRefineryBase()],
    booms: @[],
    bullets: @[],
    bulletsEvil: @[],
    hooligans: @[],
    hooliganTimer: newHooliganTimer(),
    particles: @[],
    rocks: @[spawnRock(),spawnRock()],
    rockTimer: newRockTimer(),
    ships: @[newRandShip(0.0),newRandShip(0.0)],
    shipTimer: newShipTimer(),
    cargo: [0, 0],
    delivered: [0, 0],
    rockScore: 0,
    shipScore: 0,
  )

# query

proc sum*(arr:array[LootKind,int]): int =
  ## sum the kinds of loot collected
  result = 0
  for loot in arr: result += loot

proc getCargo*(scene: Scene): seq[Loot] =
  ## Get a seq of all the loot currently in the cargo hold.
  result = @[]
  result.add scene.player.newLoot(lkPod)
  for i in 0..<scene.cargo[lkPod]:
    result.add scene.player.newLoot(lkPod)
  for i in 0..<scene.cargo[lkGem]:
    result.add scene.player.newLoot(lkGem)

# draw

proc draw[Obj](ctx: Context, objs: seq[Obj]) =
  ## draw each of a sequence of objects
  for obj in objs:
    ctx.draw(obj)

proc draw*(ctx: Context, scene: Scene) =
  ## draw the scene onto the canvas
  ctx.save()
  ctx.draw(scene.bases)
  ctx.draw(scene.loots)
  ctx.draw(scene.ships)
  ctx.draw(scene.bullets)
  ctx.draw(scene.bulletsEvil)
  ctx.draw(scene.hooligans)
  ctx.draw(scene.player)
  ctx.draw(scene.rocks)
  ctx.draw(scene.booms)
  ctx.draw(scene.particles)
  ctx.restore()

proc drawPast*(ctx: Context, scene: Scene) =
  ctx.save()
  for obj in scene.rocks:
    ctx.drawPast(obj)
  for obj in scene.ships:
    ctx.drawPast(obj)
  for obj in scene.hooligans:
    ctx.drawPast(obj)
  ctx.drawPast(scene.player)
  ctx.restore()

proc drawFuture*(ctx: Context, scene: Scene) =
  ctx.save()
  for obj in scene.rocks:
    ctx.drawFuture(obj)
  for obj in scene.ships:
    ctx.drawFuture(obj)
  for obj in scene.hooligans:
    ctx.drawFuture(obj)
  ctx.drawFuture(scene.player)
  ctx.restore()
