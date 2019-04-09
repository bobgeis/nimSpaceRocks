# Package

version       = "0.1.0"
author        = "Bob Geis"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
bin           = @["script.js"]

binDir = "public"
backend = "js"


# Dependencies

requires "nim >= 0.19.4"


# Tasks

task web, "compilte to js":
  exec("nim js -o:public/script.js src/nimSpaceRocks.nim")

task webdoc, "generate doc":
  exec("nim doc -o:docs/ --project src/nimSpaceRocks.nim")

task webrel, "release version":
  exec("nim js -d:release -o:public/script.js src/nimSpaceRocks.nim")
