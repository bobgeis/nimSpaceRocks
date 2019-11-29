
# nimSpaceRocks

An asteroids game written to learn nim.  Written targeting the js backend.

[**Play it here**](https://bobgeis.github.io/nimSpaceRocks)

## Controls

* Arrow Keys or WASD move the player ship.
* Spacebar fires the disruptor and unpauses the game.
* Escape starts a new game.
* Enter unpauses and pauses the game.
* While paused, press Left and Right to time travel.
* While paused, press Down to save to browser local storage.

## Objectives

Oh no! Some hooligans are dumping space rocks into Subspace Locus 1457 again!

Luckily, a dedicated rescue and rock-buster ship is already prepped and on site.  That's you!

* Try to keep Subspace Locus 1457 safe for travelers by busting rocks.
* Bring any escape pods you rescue to the hospital station in the upper right.  You will be rewarded with a temporary enhancement to your weapon.
* Bring any valuable minerals you happen to collect to the refinery base in the lower left.  You will be rewarded with a temporary enhancement to your weapon.
* If you get into a jam or if you have to abandon ship, use the Omega-13.  It will let you go back in time up to 13 seconds. "Enough time to undo one mistake." ~Commander Taggart
* Good luck!

## Attributions

* [Image of the Carina Nebula](https://commons.wikimedia.org/wiki/File:Carina_Nebula.jpg) as a background.  Used under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).  Credit to [ESO/T. Preibisch](http://www.eso.org/public/images/eso1208a/).

* [flatted](https://github.com/WebReflection/flatted) for serializing.  Used under [ISC license](https://github.com/WebReflection/flatted/blob/master/LICENSE). Credit to Andrea Giammarchi, @WebReflection.

* [terser](https://github.com/terser-js/terser) for shrinking the release script.  Used under [BSD license](https://github.com/terser-js/terser/blob/master/LICENSE).

## Developers

### Prerequisites

* [The Nim programming language](https://nim-lang.org/) - We're using nim's javascript backend.  We're also using some of the tools that come with it, such as nimble.

* [flatted.js](https://github.com/WebReflection/flatted) - We're using this to serialize nim-in-js datastructures so we can put them in localStorage.  This was mostly an exercise in typing a javascript library.  Surprisingly straightforward!

* [terser](https://github.com/terser-js/terser) - We're using this to minify the produced javascript after nim is done producing it.

### Developing

With the above requirements met, cd into this folder.

To build a dev version: `nimble dev`
To build a release version: `nimble prod`
To start a [local server](http://localhost:8000/): `nimble serve`

I used vscode with the [nim extension](https://marketplace.visualstudio.com/items?itemName=kosz78.nim) with build on save.  I also recommend using [indent-rainbow](https://marketplace.visualstudio.com/items?itemName=oderwat.indent-rainbow).

While playing, you can press the "l" key to log the current game state to the console.

### Notes on Code Layout

* src/nimSpaceRocks.nim is the main entry point.  It does some very basic set up.

* src/game.nim does most of the actual work in its procs.  A "Game" object represents the total game state.

* src/scene.nim contains the type def for a game "Scene".  However, most of the procs that manipulate it are in game.nim.  Note that while a Scene is what you see on the screen at any given moment, there's more to the game that one Scene (such as the previous Scenes stored in the timeline!).

* Utility/helper functions/procs that are not specific to this game, are in src/helper.  This includes typings for browser APIs that are not part of the standard lib (such as HTML5 canvas wrappers).

* Utility/helper functions/procs that *are* specific to this game, are in src/common.

* For the game entities, I'm putting their types and basic functions in the src/objs.  A function/proc is basic if it depends on no other types of game entities.

* For procs/systems that require multiple kinds of interacting game entities, I'm putting those procs into src/interact.  This is to avoid circular dependencies.  Each interaction is named for the two kinds of things that are interacting (alphabetically), so code that collides bullets with rocks is in "bulletrock.nim".
