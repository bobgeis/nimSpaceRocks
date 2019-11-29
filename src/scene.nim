## this has types and some simple functions for Scene objects
## many important procs using this will be in other files

# import math

import helper/canvas2d

import objs/base
import objs/boom
import objs/bullet
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
    loots*: seq[Loot]
    particles*: seq[Particle]
    rocks*: seq[Rock]
    rockTimer*: RockTimer
    ships*: seq[Ship]
    shipTimer*: ShipTimer
    cargo*: array[LootKind, int]
    delivered*: array[LootKind, int]
    rocksBusted*: int
    shipsSafe*: int

proc sum*(arr:array[LootKind,int]): int =
  ## sum the kinds of loot collected
  result = 0
  for loot in arr: result += loot

proc newScene*(): Scene =
  ## get a new starting scene
  result = Scene(
    tick: 0,
    player: newPlayer(),
    bases: @[newHospitalBase(), newRefineryBase()],
    booms: @[],
    bullets: @[],
    particles: @[],
    rocks: @[spawnRock(),spawnRock()],
    rockTimer: newRockTimer(),
    ships: @[newRandShip(0.0),newRandShip(0.0)],
    shipTimer: newShipTimer(),
    cargo: [0, 0],
    delivered: [0, 0],
    rocksBusted: 0,
    shipsSafe: 0,
  )

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
  ctx.drawPast(scene.player)
  ctx.restore()

proc drawFuture*(ctx: Context, scene: Scene) =
  ctx.save()
  for obj in scene.rocks:
    ctx.drawFuture(obj)
  for obj in scene.ships:
    ctx.drawFuture(obj)
  ctx.drawFuture(scene.player)
  ctx.restore()
