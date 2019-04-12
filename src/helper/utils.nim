## misc utility functions

import algorithm
import dom
import jscore
import jsconsole
import macros
import math
import sugar


func square*(a: float): float = a * a

# console procs
# note that import jsconsole gets the javascripts console object

# proc warn*[T](a: T) =
#   ## call console.warn with the argument
#   console.warn(a)

proc log*[T](a: T) =
  ## console.log the argument
  ## this is to be used to get objects and arrays to display
  ## interactively in the console
  ## if you want to display simple messages or numbers,
  ## then use echo
  console.log(a)


proc mlog*[T](a: T, m: string or cstring) =
  ## log the argument with an optional message
  ## example: state.mlog("state is")  -> "state is :"  {...}
  console.log(m, ":", a)

proc log*[T](m: string or cstring, a: T) =
  ## log the argument with an optional message
  ## example: clog "state is", state  -> "state is :"  {...}
  console.log(m, ":", a)

proc spy*[T](a: T): T =
  ## log a thing and get it back
  ## example: let w = x.spy.y.spy.z.spy
  log a
  a

proc spy*[T](a: T, m: string or cstring): T =
  ## log a thing and get it back with optional message m
  ## example: x.add(y).spy("after add").pow(z).spy("after pow")
  log(m, a)
  a

proc trace*() =
  ## call the js console trace function
  {.emit: "console.trace()".}


proc deleteIndices*[T](s: var seq[T], indices: seq[int] or seq[Natural]) =
  ## Delete from s every index in a seq of indices.
  ## Indices is assumed to be sorted ascending!
  ## Each index in indices is assumed to be within s!
  ## All indices must be of the same type!
  ## O(n) as opposed to O(mn) for deleting in a loop.
  if indices.len == 0: return
  assert(indices.isSorted(cmp), "Indices were out of order: " & $indices)
  assert(s.len > indices[^1], "Index out of bounds! s.len: " & $s.len &
      " indices[^1]: " & $indices[^1])
  let
    newlen = s.len - indices.len
  assert(newlen <= s.len and newlen >= 0,
      "Newlength invalid! newlen: " & $newlen & " s.len: " & $s.len)
  var
    i = indices[0]
    j = i+1
    k = 1
  while i < newlen:
    while k < indices.len and j == indices[k]:
      inc(j)
      inc(k)
    assert(i < s.len, "i was out of bounds! i: " & $i & " s.len: " & $s.len)
    assert(j < s.len, "j was out of bounds! j: " & $j & " s.len: " & $s.len)
    s[i].shallowCopy(s[j])
    inc(i)
    inc(j)
  setLen(s, newlen)
