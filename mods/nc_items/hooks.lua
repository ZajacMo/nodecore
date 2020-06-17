-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, setmetatable, vector
    = minetest, nodecore, pairs, setmetatable, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local nevermatch = {}
nodecore.register_limited_abm({
		label = "Item Stack Cooking/Cooling",
		nodenames = {modname .. ":stack"},
		interval = 1,
		chance = 1,
		action = function(pos, node)
			local str = nodecore.stack_get(pos):get_name()
			if nevermatch[str] then return end
			local matched
			local data = nodecore.craft_cooking_data()
			data.rootmatch = function() matched = true end
			nodecore.craft_check(pos, node, data)
			if not matched then
				nevermatch[str] = true
				return
			end
			if not data.progressing then
				minetest.get_meta(pos):set_string(modname, "")
			end
		end
	})

for name, def in pairs(minetest.registered_items) do
	if name ~= "" and def.type ~= "node" and def.node_placement_prediction == nil then
		minetest.override_item(name, {node_placement_prediction = modname .. ":stack"})
	end
end
nodecore.register_on_register_item(function(_, def)
		if def.type ~= "node" and def.node_placement_prediction == nil then
			def.node_placement_prediction = modname .. ":stack"
		end
	end)

function minetest.item_place(itemstack, placer, pointed_thing, param2)
	if not nodecore.interact(placer) then return end
	if pointed_thing.type == "node" and placer and
	not placer:get_player_control().sneak then
		local n = minetest.get_node(pointed_thing.under)
		local nn = n.name
		local nd = minetest.registered_items[nn]
		if nd and nd.on_rightclick then
			return nd.on_rightclick(pointed_thing.under, n,
				placer, itemstack, pointed_thing) or itemstack, false
		end
	end
	local def = itemstack:get_definition()
	if def.type == "node" and not def.place_as_item then
		return minetest.item_place_node(itemstack, placer, pointed_thing, param2)
	end
	if not itemstack:is_empty() then
		local above = minetest.get_pointed_thing_position(pointed_thing, true)
		if above and nodecore.buildable_to(above) then
			nodecore.stack_node_sounds_except[minetest.hash_node_position(above)] = placer:get_player_name()
			nodecore.place_stack(above, itemstack:take_item(), placer, pointed_thing)
		end
	end
	return itemstack
end

local olddrop = minetest.item_drop
function minetest.item_drop(item, player, ...)
	local oldadd = minetest.add_item
	function minetest.add_item(pos, stack, ...)
		local start = player:get_pos()
		local eyeheight = player:get_properties().eye_height or 1.625
		start.y = start.y + eyeheight
		local target = vector.add(start, vector.multiply(player:get_look_dir(), 4))
		local pointed = minetest.raycast(start, target, false)()
		if (not pointed) or pointed.type ~= "node" then
			return oldadd(pos, stack, ...)
		end

		local dummyent = {}
		setmetatable(dummyent, {
				__index = function()
					return function() return {} end
				end
			})

		local name = stack:get_name()
		local function tryplace(p)
			if nodecore.match(p, {name = name, count = false}) then
				stack = nodecore.stack_add(p, stack)
				if stack:is_empty() then return dummyent end
			end
			if nodecore.buildable_to(p) then
				nodecore.place_stack(p, stack, player)
				return dummyent
			end
		end

		return tryplace(pointed.under)
		or tryplace(pointed.above)
		or oldadd(pos, stack, ...)
	end
	local function helper(...)
		minetest.add_item = oldadd
		return ...
	end
	return helper(olddrop(item, player, ...))
end
