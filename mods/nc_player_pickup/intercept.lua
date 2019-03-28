-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, setmetatable
    = ItemStack, minetest, setmetatable
-- LUALOCALS > ---------------------------------------------------------

local function additem(player, inv, list, stack)
	stack = ItemStack(stack)
	if stack:is_empty() then return stack end
	local wield = player:get_wielded_item()
	stack = wield:add_item(stack)
	player:set_wielded_item(wield)
	return (inv or player:get_inventory()):add_item(list, stack)
end

local function wrapinv(inv, player)
	if not inv then return inv end
	local t = {}
	setmetatable(t, {__index = inv})
	function t:add_item(list, stack)
		return additem(player, inv, list, stack)
	end
	return t
end

local function wrapplayer(player)
	if not player then return player end
	local t = {}
	setmetatable(t, {__index = player})
	function t:get_inventory()
		return wrapinv(player:get_inventory(), player)
	end
	return t
end

local olddrops = minetest.handle_node_drops
function minetest.handle_node_drops(a, b, whom, ...)
	return olddrops(a, b, wrapplayer(whom), ...)
end

local oldeat = minetest.do_item_eat 
function minetest.do_item_eat(a, b, c, whom, ...)
	return oldeat(a, b, c, wrapplayer(whom), ...)
end

local bii = minetest.registered_entities["__builtin:item"]
local item = {
	on_punch = function(self, whom, ...)
		return bii.on_punch(self, wrapplayer(whom), ...)
	end
}
setmetatable(item, bii)
minetest.register_entity(":__builtin:item", item)
