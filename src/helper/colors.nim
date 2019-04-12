## create rgb & hsl color strings for browser APIs

func rgb*(r, g, b: int or float or string): string =
  ## r,g,b should be 0-255
  ## returns string "rgb(...)"
  "rgb(" & $r & "," & $g & "," & $b & ")"

func rgb*(r, g, b, a: int or float or string): string =
  ## r,g,b should be 0-255
  ## a should be 0-1
  ## returns string "rgba(...)"
  "rgba(" & $r & "," & $g & "," & $b & "," & $a & ")"

func hsl*(h, s, l: int or float or string): string =
  ## h should be 0-360, s,l should be 0-100
  ## returns string "hsl(...)"
  "hsl(" & $h & "," & $s & "%," & $l & "%)"

func hsl*(h, s, l, a: int or float or string): string =
  ## h should be 0-360, s,l should be 0-100
  ## a should be 0-1
  ## returns string "hsla(...)"
  "hsla(" & $h & "," & $s & "%," & $l & "%," & $a & ")"
