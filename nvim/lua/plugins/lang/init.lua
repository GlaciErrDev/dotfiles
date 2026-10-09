-- Language-specific specs.
--
-- lazy.nvim's directory import does not recurse into subdirectories
-- without an init.lua, so the spec tree is assembled explicitly here.
return {
  require("plugins.lang.rust"),
  require("plugins.lang.lua"),
  require("plugins.lang.markdown"),
}
