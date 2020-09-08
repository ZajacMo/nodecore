-- LUALOCALS < ---------------------------------------------------------
local getmetatable, minetest, nodecore, setmetatable
    = getmetatable, minetest, nodecore, setmetatable
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

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
			return helper(nodecore.give_item(found, stack, listname, self))
		else
			return helper(oldadd(self, listname, stack, ...))
		end
	end
	nodecore.log("action", modname .. " inventory:add_item hooked")
	wrapinv = function(i, p)
		invplayer[i] = p
		return i
	end
	return wrapinv(inv, player)
end

local function patchplayers()
	local player = (minetest.get_connected_players())[1]
	if not player then
		return minetest.after(0, patchplayers)
	end

	local meta = getmetatable(player)
	meta = meta and meta.__index or meta
	if not meta.get_inventory then return end

	local getraw = meta.get_inventory
	function meta:get_inventory(...)
		return wrapinv(getraw(self, ...), self)
	end
	nodecore.log("action", modname .. " player:get_inventory hooked")
end
minetest.after(0, patchplayers)
