-- LUALOCALS < ---------------------------------------------------------
local core, getmetatable, nc, setmetatable
    = core, getmetatable, nc, setmetatable
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local invplayer = {}
setmetatable(invplayer, {__mode = "k"})

local invgiving = {}
setmetatable(invgiving, {__mode = "k"})

local function wrapinv(inv, player)
	local meta = getmetatable(inv)
	meta = meta and meta.__index or meta
	local oldadd = meta.add_item
	function meta:add_item(listname, stack, ...)
		if invgiving[self] then return oldadd(self, listname, stack, ...) end
		invgiving[self] = true
		local function helper(...)
			invgiving[self] = nil
			return ...
		end
		local found = invplayer[self]
		if found then
			return helper(nc.give_item(found, stack, listname, self))
		else
			return helper(oldadd(self, listname, stack, ...))
		end
	end
	nc.log("info", modname .. " inventory:add_item hooked")
	wrapinv = function(i, p)
		if i then invplayer[i] = p end
		return i
	end
	return wrapinv(inv, player)
end

local function patchplayers()
	local player = (core.get_connected_players())[1]
	if not player then
		return core.after(0, patchplayers)
	end

	local meta = getmetatable(player)
	meta = meta and meta.__index or meta
	if not meta.get_inventory then return end

	local getraw = meta.get_inventory
	function meta:get_inventory(...)
		return wrapinv(getraw(self, ...), self)
	end
	nc.log("info", modname .. " player:get_inventory hooked")
end
core.after(0, patchplayers)
