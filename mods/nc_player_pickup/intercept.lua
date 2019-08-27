-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, setmetatable
    = ipairs, minetest, nodecore, setmetatable
-- LUALOCALS > ---------------------------------------------------------

local function wrapinv(inv, player)
	if not inv then return inv end
	local t = {}
	setmetatable(t, {__index = inv})
	function t:add_item(list, stack)
		return nodecore.give_item(player, stack, list, inv)
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

local oldstackgive = nodecore.stack_giveto
nodecore.stack_giveto = function(a, whom, ...)
	return oldstackgive(a, wrapplayer(whom), ...)
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

for _, cmd in ipairs({"give", "giveme"}) do
	local give = minetest.registered_chatcommands[cmd] or {}
	local oldfunc = give.func or function() end
	give.func = function(...)
		local oldgpbn = minetest.get_player_by_name
		local function helper(...)
			minetest.get_player_by_name = oldgpbn
			return ...
		end
		minetest.get_player_by_name = function(...)
			local function helper(p, ...)
				p = wrapplayer(p)
				return p, ...
			end
			return helper(oldgpbn(...))
		end
		return helper(oldfunc(...))
	end
end
