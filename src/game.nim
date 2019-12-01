
import jsconsole
import jsffi
import tables

import helper/browser
import helper/canvas2d
import helper/flatted
import helper/utils

import common
import scene

import objs/base
import objs/boom
import objs/bullet
import objs/hooligan
import objs/loot
import objs/omega
import objs/particle
import objs/player
import objs/rock
import objs/ship

import interact/baseplayer
import interact/bulletplayer
import interact/bullethooligan
import interact/bulletrock
import interact/bulletship
import interact/edgeship
import interact/hooliganplayer
import interact/hooligantimertime
import interact/lootplayer
import interact/playerrock
import interact/rockship
import interact/rocktimertime
import interact/shiptimertime
import interact/ui


type
  Mode* = enum
    modePlay, modePause
  KeyState* = enum
    ksDown, ksOn, ksUp, ksOff
  TimeTravelDirection* = enum
    ttdBack, ttdFor, ttdStop,
  Game* = ref object
    ctx*: Context
    mode*: Mode
    scene*: Scene
    timeline*: Timeline
    timetraveldir*: TimeTravelDirection
    timetarget*: Scene
    inputs*: Table[string, KeyState]
    hiscore*: array[4,int]
    drawHelp*: bool
    dt*: float


proc newGame*(ctx: Context): Game =
  ## create and return a new Game object
  let scene = newScene()
  result = Game(
    ctx: ctx,
    mode: modePause,
    scene: scene,
    timeline: newTimeline(),
    timetraveldir: ttdStop,
    timetarget: scene,
    inputs: initTable[string, KeyState](),
    hiscore: [0,0,0,0],
    drawHelp: true,
    dt: 16,
  )

proc saveHiScore(game: Game) =
  ## Save the current hiscore to localstorage
  localStorage.setItem("nimSpaceRocks-hiscore",stringify(Flatted, game.hiscore))

proc saveCurrentScene(game: Game) =
  ## Save the current scene and rock shapes to localstorage
  let sceneString = if isNow(): stringify(Flatted, game.scene)
    else: game.timeline.getTimeTargetString()
  localStorage.setItem("nimSpaceRocks-scene",sceneString)
  localStorage.setItem("nimSpaceRocks-rockPoints",stringify[RockPoints](Flatted, rockPoints))

proc loadHiScore(): array[0..3,int] =
  ## load any previously saved hiscore
  parse[array[4,int]](Flatted, localStorage.getItem("nimSpaceRocks-hiscore"))

proc loadSavedScene(): (Scene,RockPoints,) =
  ## Load data from local storage if possible.
  (
    parse[Scene](Flatted, localStorage.getItem("nimSpaceRocks-scene")),
    parse[RockPoints](Flatted, localStorage.getItem("nimSpaceRocks-rockPoints")),
  )

proc update[Obj](objs: var seq[Obj]) =
  ## update each of a sequence of objects
  var cull: seq[int] = @[]
  for i, obj in objs.mpairs:
    if not obj.update(): cull.add i
  objs.deleteIndices cull

proc update(scene: var Scene) =
  ## update the scene for one tick
  scene.tick = scene.tick + 1
  # self updates
  scene.booms.update()
  scene.bases.update()
  scene.particles.update()
  scene.bullets.update()
  scene.bulletsEvil.update()
  scene.hooligans.update()
  scene.loots.update()
  scene.rocks.update()
  scene.ships.update()
  scene.player.update()
  # interactions
  scene.interactBulletRock()
  scene.interactBulletHooligan()
  scene.interactBulletShip()
  scene.interactHooliganPlayer()
  scene.interactHooliganTimer()
  scene.interactRockTimer()
  scene.interactShipTimer()
  scene.interactEdgeShip()
  scene.interactLootPlayer()
  scene.interactBasePlayer()
  scene.interactRockShip()
  scene.interactBulletPlayer()
  scene.interactPlayerRock()

proc update(game: Game, dt:float) =
  ## update the game state one tick
  game.dt = dt
  case game.mode       # no change for ticks in pause mode
  of modePlay:
    game.scene.update()
    if game.scene.player.alive: # only update timeline if player is alive
      game.timeline.update(game.scene)
  of modePause:
    case game.timetraveldir
    of ttdBack:
      game.timeline.goback()
      game.timetarget = game.timeline.getTimeTarget()
    of ttdFor:
      game.timeline.goForward()
      game.timetarget = game.timeline.getTimeTarget()
    else:
      return

proc updateHiScore(game: var Game) =
  ## Update the hiscore using the values from the current scene.
  game.hiscore[0] = max(game.hiscore[0], game.scene.delivered[lkPod])
  game.hiscore[1] = max(game.hiscore[1], game.scene.delivered[lkGem])
  game.hiscore[2] = max(game.hiscore[2], game.scene.rockScore)
  game.hiscore[3] = max(game.hiscore[3], game.scene.shipScore)
  try:
    echo "Saving hiscore"
    game.saveHiScore()
  except:
    echo "Local storage could not be accessed."


proc draw(game: Game) =
  ## draw the current view
  game.ctx.clearRect(0.0, 0.0, CANVAS_WIDTH, CANVAS_HEIGHT)
  case game.mode
  of modePlay:
    game.ctx.draw(game.scene)
    game.ctx.drawScore(game.scene)
  of modePause:
    if isNow():
      game.ctx.draw(game.scene)
      game.ctx.drawScore(game.scene)
      game.ctx.drawHiScore(game.hiscore)
      if game.drawHelp:
        game.ctx.drawInstructions()
    else:
      let (ps,fs) = game.timeline.getTimeTargets()
      for p in ps:
        game.ctx.drawPast(p)
      for f in fs:
        game.ctx.drawFuture(f)
      game.ctx.draw(game.timetarget)
      game.ctx.drawScore(game.timetarget)
  game.ctx.draw(game.timeline)
  when not defined(release):
    game.ctx.drawFPS(game.dt)

proc keydown*(game: var Game, k: KeyEvent) =
  ## handle a keydown event by updating the inputs table
  discard game.inputs.hasKeyOrPut($k.key, ksDown)

proc keyup*(game: var Game, k: KeyEvent) =
  ## handle keyup event by updating the inputs table
  game.inputs[$k.key] = ksUp

proc applyKeyDown(game: var Game, key: string) =
  ## handle a keydown event
  case game.mode
  of modePlay:
    case key
    of "p", "Enter":
      game.mode = modePause
      game.updateHiScore
    of " ":
      if game.scene.player.alive:
        game.scene.player.command(WpnOn)
      else:
        game.mode = modePause
        game.updateHiScore
    of "a", "ArrowLeft":
      game.scene.player.command(TurnLeft)
    of "d", "ArrowRight":
      game.scene.player.command(TurnRight)
    of "w", "ArrowUp":
      game.scene.player.command(AccThrust)
    of "s", "ArrowDown":
      game.scene.player.command(AccRetro)
    of "q":
      game.scene.player.command(StrafeLeft)
    of "e":
      game.scene.player.command(StrafeRight)
    else: return
  of modePause:
    case key
    of "p", "Enter", " ":
      game.mode = modePlay
      game.drawHelp = false
      if not isNow():
        game.scene = game.timeline.getTimeTarget()
      game.scene.player.stop()  # prevent the player from spinning in place
      game.timeline.stopTimeTraveling()
      if key == " " and game.scene.player.alive:
        game.scene.player.command(WpnOn)
    of "a", "ArrowLeft":
      game.timetraveldir = ttdBack
    of "d", "ArrowRight":
      game.timetraveldir = ttdFor
    of "s", "ArrowDown":
      try:
        echo "Saving current scene"
        game.saveCurrentScene()
      except:
        echo "Local storage could not be accessed."
    else: return

proc applyKeyUp(game: var Game, key: string) =
  ## handle a keyup event
  case game.mode
  of modePlay:
    case key
    of "l":
      game.mlog("game state")
    of " ":
      game.scene.player.command(WpnOff)
    of "d", "a", "ArrowLeft", "ArrowRight":
      game.scene.player.command(TurnStop)
    of "w", "s", "ArrowDown", "ArrowUp":
      game.scene.player.command(AccStop)
    of "q", "e":
      game.scene.player.command(StrafeStop)
    of "Escape":
      goToNow()
      rock.init()
      let newg = newGame(game.ctx)
      newg.timeline.push newg.scene
      newg.mode = modePause
      # prevent changing the size of the input table during iteration
      newg.inputs = game.inputs
      newg.hiscore = game.hiscore
      game = newg
    else: return
  of modePause:
    case key
    of "l":
      game.mlog("game state")
    of "d", "a", "ArrowLeft", "ArrowRight":
      game.timetraveldir = ttdStop
    of "Escape":
      goToNow()
      let newg = newGame(game.ctx)
      rock.init()
      newg.timeline.push newg.scene
      newg.mode = modePause
      # prevent changing the size of the input table during iteration
      newg.inputs = game.inputs
      newg.hiscore = game.hiscore
      game = newg

proc applyInputs(game: var Game) =
  ## apply key inputs to the game state
  var cull: seq[string] = @[]
  for key, value in game.inputs.mpairs():
    case value
    of ksDown:
      game.applyKeyDown(key)
      value = ksOn
    of ksUp:
      game.applyKeyUp(key)
      cull.add key
    else: continue
  for key in cull:
    game.inputs.del key

proc tick*(game: var Game, dt: float) =
  ## update game state by one tick
  game.applyInputs()
  game.update(dt)
  game.draw()

proc init*(game: var Game) =
  ## Call initialization functions
  try:
    let restoredHiScore = loadHiScore()
    game.hiscore = restoredHiScore
    echo "Loaded saved hiscores from localStorage."
  except:
    echo "Could not load hiscores from localStorage."
  try:
    let (restoredScene,restoredRockPoints) = loadSavedScene()
    game.scene = restoredScene
    game.timetarget = restoredScene
    game.timeline.push restoredScene
    game.mode = modePause
    rock.init(restoredRockPoints)
    echo "Loaded saved scene from localStorage."
  except:
    echo "Could not load saved scene from localStorage."
    rock.init()
  base.init()
  boom.init()
  bullet.init()
  hooligan.init()
  loot.init()
  particle.init()
  player.init()
  ship.init()
  ui.init(game.ctx)
