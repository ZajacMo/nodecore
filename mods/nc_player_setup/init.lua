-- LUALOCALS < ---------------------------------------------------------
local include, nodecore
    = include, nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

include("setup")
include("step_autorun")
include("step_fallspeed")
include("step_footsteps")
include("step_hotpotato")
include("step_interactinv")
include("step_invulnbreath")
include("step_stepheight")
include("step_zoomfocus")
