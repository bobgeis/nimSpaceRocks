## wrapper for flatted.js
## see: https://github.com/WebReflection/flatted

type
  FlattedLib* = ref object


var
  Flatted* {.importc, nodecl.}: FlattedLib


proc stringify*[T](lib: FlattedLib, obj: T): cstring {.importcpp.}

proc parse*[T](lib: FlattedLib, s: cstring): T {.importcpp.}

