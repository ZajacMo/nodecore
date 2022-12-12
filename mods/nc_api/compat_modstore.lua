-- LUALOCALS < ---------------------------------------------------------
local error, minetest
    = error, minetest
-- LUALOCALS > ---------------------------------------------------------

-- Workaround for broken get_mod_storage pre-5.6
-- https://github.com/minetest/minetest/pull/12572

local modstores = {}

local old_get_mod_storage = minetest.get_mod_storage
function minetest.get_mod_storage()
	local modname = minetest.get_current_modname()
	if not modname then return error("must be called at load time only") end
	local found = modstores[modname]
	if found then return found end
	found = old_get_mod_storage()
	modstores[modname] = found
	return found
end
