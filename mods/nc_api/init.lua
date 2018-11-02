local nodecore = {}
rawset(_G, "nodecore", nodecore)

local minetest = minetest
for k, v in pairs(minetest) do
	if type(v) == "function" then
		-- Late-bind in case minetest methods overridden.
		nodecore[k] = function(...) return minetest[k](...) end
	else
		nodecore[k] = v
	end
end
local modname = minetest.get_current_modname()
local path = minetest.get_modpath(modname)

dofile(path .. "/regnode.lua")