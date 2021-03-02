-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, type
    = minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

local modname = minetest.get_current_modname()

local function doplace(stack, clicker, pointed_thing, ...)
	local function helper(left, ok, ...)
		if ok then nodecore.node_sound(pointed_thing.above, "place") end
		return left, ok, ...
	end
	return helper(minetest.item_place_node(stack, clicker, pointed_thing, ...))
end

function nodecore.storebox_on_rightclick(pos, node, clicker, stack, pointed_thing)
	if not nodecore.interact(clicker) then return end
	if (not stack) or stack:is_empty() then return end
	node = node or minetest.get_node(pos)
	local def = minetest.registered_items[node.name]
	if not def then return end
	if nodecore.protection_test(pos, clicker) then return stack end
	if def.storebox_access and (not def.storebox_access(
			pointed_thing, pos, node)) then
		return doplace(stack, clicker, pointed_thing)
	end
	if def.stack_allow and def.stack_allow(pos, node, stack) == false then
		return doplace(stack, clicker, pointed_thing)
	end
	return nodecore.stack_add(pos, stack, clicker)
end

function nodecore.storebox_on_punch(pos, node, puncher, pointed_thing, ...)
	minetest.node_punch(pos, node, puncher, pointed_thing, ...)
	if not nodecore.interact(puncher) then return end
	if puncher:get_player_control().sneak then return end
	node = node or minetest.get_node(pos)
	local def = minetest.registered_items[node.name]
	if nodecore.protection_test(pos, puncher) then return end
	if def.storebox_access and (not def.storebox_access(
			pointed_thing, pos, node)) then return end
	if pointed_thing.above.y < pointed_thing.under.y then return end
	return nodecore.stack_giveto(pos, puncher)
end

function nodecore.storebox_stack_allow(pos, node, stack)
	node = node or minetest.get_node(pos)
	local def = minetest.registered_items[node.name]
	local idef = minetest.registered_items[stack:get_name()] or {}
	if idef.groups and idef.groups.container
	and idef.groups.container >= def.groups.storebox then return false end
end

nodecore.register_on_register_item(function(_, def)
		if def.type ~= "node" or (not def.groups) or (not def.groups.storebox) then return end

		if not def.drawtype then
			def.drawtype = "mesh"
			def.visual_scale = nodecore.z_fight_ratio
			def.mesh = def.mesh or modname .. "_box.obj"
			local t = def.tiles or {}
			for k, v in pairs(t) do
				if type(v) == "string" then
					t[k] = {name = v, backface_culling = true}
				end
			end
			def.use_texture_alpha = def.use_texture_alpha or "clip"
		end

		def.groups.visinv = def.groups.visinv or 1
		def.groups.always_scalable = def.groups.always_scalable or 1
		def.groups.container = def.groups.container or def.groups.storebox

		def.on_construct = def.on_construct or nodecore.visinv_on_construct
		def.after_destruct = def.after_destruct or nodecore.visinv_after_destruct

		def.on_rightclick = def.on_rightclick or nodecore.storebox_on_rightclick
		def.on_punch = def.on_punch or nodecore.storebox_on_punch
		def.stack_allow = def.stack_allow or nodecore.storebox_stack_allow
	end)
