switch("path", "src")
switch("threads", "on")
switch("outdir", ".out")

when fileExists("nimble.paths"):
  include "nimble.paths"
# begin Nimble config (version 2)
when withDir(thisDir(), system.fileExists("nimble.paths")):
  include "nimble.paths"
# end Nimble config
