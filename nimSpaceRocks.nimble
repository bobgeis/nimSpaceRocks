# Package

version = "0.1.0"
author = "Bob Geis"
description = "An asteroids clone written in nim for html canvas"
license = "MIT"
srcDir = "src"
bin = @["script.js"]

binDir = "public"


# Dependencies

requires "nim >= 0.20.0"


# Tasks

import os

task prettyall, "run nimpretty over all source code":
  ## this is hacky, but there doesn't seem to be a nimpretty all command,
  ## and for some reason `import re` doesn't run in nimble/nimscript
  echo "prettifying: "
  for file in walkDirRec ".":
    let (_, _, ext) = file.splitFile()
    if ext == ".nim" or ext == ".nims":
      # autodetect indent is the default, but we always want 2
      exec "nimpretty --indent:2 " & file

task dev, "compile debug version to js":
  exec "nimble js -o:public/script.js src/nimSpaceRocks.nim --verbose --hint[Processing]=off --hint[Conf]=off"

task devSmall, "compile debug version to js with a small canvas size":
  exec "nimble js -o:public/script.js src/nimSpaceRocks.nim --verbose --hint[Processing]=off --hint[Conf]=off -d:small"

task prod, "compile release version to js":
  exec "nimble js -d:release -d:danger --opt:speed -o:public/script.webrel.js src/nimSpaceRocks.nim"
  exec "terser public/script.webrel.js -o public/script.js -c -m"
  exec "rm public/script.webrel.js"

task fileff, "open the game in firefox":
  exec "firefox --new-tab file://" & projectDir() & "/public/index.html & "

task filech, "open the game in chrome":
  exec "\"Google Chrome\" -new-tab -url public/index.html"

task serve, "start simple python server":
  exec "(cd public && python -m SimpleHTTPServer)"

task lhff, "open localhost in firefox":
  exec "firefox --new-tab http://localhost:8000/ & "

task lhch, "open localhost in chrome":
  exec "\"Google Chrome\" -new-tab -url http://localhost:8000/"

task servech, "serve and open in chrome":
  selfExec "serve"
  selfExec "lhch"

task serveff, "serve and open in firefox":
  selfExec "serve"
  selfExec "lhff"

task ghpages, "compile prod and push to github pages":
  exec "git checkout gh-pages"
  exec "git merge master"
  exec "nimble prod"
  exec "git add -f public/script.js"
  exec "git commit -m 'add script.js'"
  exec "git subtree push --prefix public"
  exec "git checkout -"