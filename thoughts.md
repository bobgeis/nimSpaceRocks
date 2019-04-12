
## Considerations


## Anticipated Questions




## Architecture Notes

* src/nimSpaceRocks.nim is the entry point for the compiler.  It does some very basic set up.

* src/game.nim does most of the actual work in its procs.

* src/scene.nim contains the type def for a game "scene".  However, most of the procs that manipulate it are in game.nim.

* Utility/helper functions/procs that are not specific to the game, are in src/helper.

* Utility/helper functions/procs that *are* specific to this game, are in src/common.

* For the game entities, I'm putting their types and basic functions in the src/objs  A function/proc is basic if it depends on no other types of game entities.

* For procs/systems that require multiple kinds of interacting game entities, I'm putting those procs into src/interact.  This is to avoid circular dependencies.


## Dependencies

* nim & nimble.  Currently uses nim v0.20.0.  This game uses the js backend.

* [flatted.js](https://github.com/WebReflection/flatted) - this is used to serialize nim-in-js data structures.  It was necessary because some circular dependencies exist internally.  It is available with the [ISC license](https://github.com/WebReflection/flatted/blob/master/LICENSE) which is permissive.

* [terser](https://github.com/terser-js/terser) - this was used to squish the js produced by nim's js backend.  It is available with a BSD license.


## Things Learned

* Math: The math std library has its own implementations, but using the js backend, if a function exists in the js Math obj, then the std library will defer to that function!  Sometimes it doesn't though... Remember nim code runs in jsland, which will almost always be slower than the native code used by jsmath functions!

* No canvas: There is no analogous wrapper for the canvas API though.  There are a number of separate non-canonical wrappers.  In my case wrapping it myself using the typescript type as a guide was pretty good.  In the future, it may be worth working with something like dts2nim to generate nim types from typescript types.

* Jscore: jscore lib wraps most of the built-in javascript libraries and functions, such as `Math`.  Note that they don't have the canvas API and neither does the dom library.

* Jsconsole: there is a _separate_ lib for jsconsole. See https://github.com/nim-lang/Nim/blob/master/lib/js/jsconsole.nim#L20  Note well that it uses a template to insert console.log calls!  This means that if jsconsole isn't imported into the file, then anything that uses it will not compile!  This means that if we have utils.nim create a spy function that calls jsconsole, then it will not work!  Need another layer of wrapping perhaps.

* Multiple Inheritance: nim does not have it.  But there might be a way to do something similar with a userland macro. See https://gist.github.com/PhilipWitte/ff8cc26d76e962591a48  Note that that does NOT work in the current versions of nim, the compiler objects to overloading the dot operator, and the suggested pragma does not appease it (though I could have been doing something wrong).

* Concepts:  Concepts are mentioned as an alternative to some of the use cases of interfaces.  Worth investigating more.  https://nim-lang.org/docs/manual.html#generics-concepts

* Generics:  Nim generics allow one to avoid some of the issues that interfaces solve, for instance `proc foo[A](a:A):int = a.x` will work for any type A that has an x field or proc defined, so long as it is known at compile time.

* SomeNumber is a pre-existing type in nim that can be "any number".  This is useful in js where the distinction between int and float mostly doesn't exist.  Note that it is a big OR of types, which means it can't be used as the type of a field in the typedef of an object (which must be concrete).

* I considered using a Struct of Arrays (SoA) architecture, but I have less experience with it and wanted to see if I could just get things done in nim, so I'm using Array of Structs (AoS) architecture instead.  Perhaps not ideal, but likely to work okay.

* To iterate over a sequence, you can usually just do `for x in xs: x.update()`, but if you want to alter the items, like with a var proc, then you need to specify that it's mutable, using `.mitems` or `.mpairs`: `for x in xs.mitems(): x.update()`.

* system.deepCopy is unsupported in js! https://github.com/nim-lang/Nim/issues/4631  Simple assignment is usually a copy, but it isn't a deep copy with objects.  JSON.stringify doesn't work because the javascript impl of nim data structures have some circular references!  Attempting to use flatted.js ( https://github.com/WebReflection/flatted ).

* Updating to nim 0.20 slightly changed the way case statements work.  Now if you have an extraneous else at the end, it will throw a compilation error.

* It's not hard to look at a typescript type definition of something and create a set of nim types for it.  See helper/canvas2d.nim and helper/flatted.nim

* Using terser on the release version of the script reduces the size by about a factor of 2.  Altogether the release version's js is about 1/4 the size of the debug.

* I was reminded that nim Tables throw exceptions if the key is not found.

* Nim macros let you do some things very simply, like adding preconditions & postconditions to your procs.  See the contra lib: https://github.com/juancarlospaco/nim-contra

* Putting a config.nims file in your users' .config/Nim/ folder let you specify a global nimscript config file!  You can put tasks in here.  Running `nim help` anywhere (note the lack of `--` before `help`) will list the config files being used and what tasks they have.  I haven't done enough development in nim yet to decide what tasks I will want everywhere.  For now I've put a task will recursively call nimpretty on every nim file in a project.  For ideas see others', eg: https://github.com/kaushalmodi/nim_config/blob/master/config.nims

* The `re` std lib for regular expressions will not run in nimscript (C lib dependency I believe).

* You might guess but it was nice to confirm: you can write the builder pattern in nim if you wish.  That is, instead of doing:
```nim
obj.move
obj.wrap
obj.glow
```
 If the procs return a `var Obj`, then you can instead do:
 ```nim
 discard obj.move.wrap.glow
 ```
 Which can be nicer in some cases.  I mostly stuck to the first method though.  If someone set up their procs to work primarily with immutable values (like eg clojure), then they would be piping values through procs.  If they later needed to make parts of the pipeline mutable (eg for performance), then they could do that in the necessary subset of procs without having to restructure their code (much...maybe).  For reference, it was easier (code-wise) to introduce transients in immutable js than it was in cljs, because all the methods were the same (no `!`, no missing `update!`).

* The nimble package manager doesn't have an obvious way to import a specific version into a vendor or local modules folder (a la npm).  Instead it appears most people just run `nimble install package`, which installs the current most recent version of that package into a global path.  This seems like a bad practice in the long run, but isn't too awful right now.  For example adding `requires "nimsvg >= 0.1.0"` ([repo](https://github.com/bluenote10/NimSvg)) in the package.nimble file, will cause that module to be downloaded and installed in the nimble path and be listed when you run `nimble list --installed` just as if you had installed it directly.

* There are a number of interesting packages on nimble, one that might be interesting for creating art assets is [nimsvg](https://github.com/bluenote10/NimSvg).  Add `requires "nimsvg >= 0.1.0"` to the .nimble file

* If we maintain the canvas drawing, then it is important to handle fuzziness due to difference between logical pixels and physical pixels.  For example some monitors have twice as many actual pixels as the canvas does.  This can be fixed by making the canvas twice as big and then using css styles to shrink it and then scaling the canvas appropriately:
```nim
  let
    c = dom.document.getElementById("canvas").Canvas
    ctx = c.getContext()
    pixelRatio = window.devicePixelRatio
  c.width = CANVAS_WIDTH * pixelRatio
  c.height = CANVAS_HEIGHT * pixelRatio
  c.style.width = $CANVAS_WIDTH & "px"
  c.style.height = $CANVAS_HEIGHT & "px"
  ctx.scale(pixelRatio,pixelRatio)
```

* Turning off processing hints with the compiler flag: `--hint[Processing]=off` actually makes the compiler process finish a little bit faster.
