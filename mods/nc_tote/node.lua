-- LUALOCALS < ---------------------------------------------------------
local ItemStack, ipairs, minetest, nodecore, pairs, type
    = ItemStack, ipairs, minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local metadescs = {
	"Tote (1 Slot)",
	"Tote (2 Slots)",
	"Tote (3 Slots)",
	"Tote (4 Slots)",
	"Tote (5 Slots)",
	"Tote (6 Slots)",
	"Tote (7 Slots)",
	"Tote (8 Slots)",
}

local function protected(pos, whom)
	return whom and whom:is_player()
	and minetest.is_protected(pos, whom:get_player_name())
end

local function totedug(pos, _, _, digger)
	local drop = ItemStack(modname .. ":handle")
	if not digger:get_player_control().sneak then
		local dump
		for dx = -1, 1 do
			for dz = -1, 1 do
				local p = {x = pos.x + dx, y = pos.y, z = pos.z + dz}
				local n = minetest.get_node(p)
				local d = minetest.registered_items[n.name] or {}
				if d and d.groups and d.groups.totable
				and not protected(p, digger) then
					local m = minetest.get_meta(p):to_table()
					for _, v1 in pairs(m.inventory or {}) do
						for k2, v2 in pairs(v1) do
							if type(v2) == "userdata" then
								v1[k2] = v2:to_string()
							end
						end
					end
					dump = dump or {}
					dump[#dump + 1] = {
						x = dx,
						z = dz,
						n = n,
						m = m
					}
					minetest.remove_node(p)
				end
			end
		end
		if dump then
			local meta = drop:get_meta()
			meta:set_string("carrying", minetest.serialize(dump))
			meta:set_string("description", metadescs[#dump])
			drop:set_name(modname .. ":handle_full")
		end
	end
	minetest.handle_node_drops(pos, {drop}, digger)
end

local function toteplace(stack, placer, pointed)
	local pos = nodecore.buildable_to(pointed.under) and pointed.under
	or nodecore.buildable_to(pointed.above) and pointed.above
	if nodecore.protection_test(pos, placer) then return end

	stack = ItemStack(stack)
	local inv = stack:get_meta():get_string("carrying")
	inv = inv and (inv ~= "") and minetest.deserialize(inv)
	if not inv then
		minetest.set_node(pos, {name = stack:get_name()})
		stack:set_count(stack:get_count() - 1)
		return stack
	end

	local commit = {{pos, {name = modname .. ":handle"}, {}}}
	for _, v in ipairs(inv) do
		if commit then
			local p = {x = pos.x + v.x, y = pos.y, z = pos.z + v.z}
			if (not nodecore.buildable_to(p)) or nodecore.obstructed(p)
			or protected(p, placer) then
				commit = nil
			else
				commit[#commit + 1] = {p, v.n, v.m}
			end
		end
	end
	if commit then
		for _, v in ipairs(commit) do
			nodecore.set_loud(v[1], v[2])
			minetest.get_meta(v[1]):from_table(v[3])
		end
		stack:set_count(stack:get_count() - 1)
	end
	return stack
end

local function tote_ignite(pos)
	local stack = nodecore.stack_get(pos)
	if minetest.get_item_group(stack:get_name(), "tote") < 1 then return true end

	local stackmeta = stack:get_meta()
	local raw = stackmeta:get_string("carrying")
	local inv = raw and (raw ~= "") and minetest.deserialize(raw)
	if not inv then return true end

	local newinv = {}
	for _, slot in pairs(inv) do
		local nn = slot and slot.n and slot.n.name
		local flam = minetest.get_item_group(nn, "flammable")
		if flam > 0 then
			nodecore.item_eject(pos, nn)
			for _, list in pairs(slot and slot.m and slot.m.inventory or {}) do
				for _, item in pairs(list) do
					local istack = ItemStack(item)
					if not istack:is_empty() then
						nodecore.item_eject(pos, istack)
					end
				end
			end
		else
			newinv[#newinv + 1] = slot
		end
	end
	local newraw = minetest.serialize(newinv)
	if newraw == raw then return true end

	stackmeta:set_string("carrying", newraw)
	stackmeta:set_string("description", metadescs[#newinv])
	stack:set_name(modname .. ":handle" .. ((#newinv > 0) and "_full" or ""))
	nodecore.stack_set(pos, stack)
	return true
end

local txr_bot = "nc_lode_annealed.png"
local txr_sides = "(" .. txr_bot .. "^[mask:nc_tote_sides.png)"
local txr_top = "nc_tree_tree_side.png^[mask:nc_tote_top.png^[transformR90^" .. txr_sides
local txr_handle = "nc_tree_tree_side.png^[transformR90"

local function reg(suff, inner, pred)
	return minetest.register_node(modname .. ":handle" .. suff, {
			description = "Tote Handle",
			meta_descriptions = metadescs,
			drawtype = "mesh",
			visual_scale = nodecore.z_fight_ratio,
			mesh = "nc_tote_handle.obj",
			selection_box = nodecore.fixedbox(),
			paramtype = "light",
			tiles = {
				{name = txr_sides, backface_culling = true},
				{name = txr_bot, backface_culling = true},
				{name = txr_top, backface_culling = true},
				{name = txr_handle, backface_culling = true},
				{name = inner, backface_culling = true}
			},
			use_texture_alpha = "clip",
			groups = {
				snappy = 1,
				container = 100,
				flammable = 5,
				tote = 1,
				scaling_time = 50
			},
			on_ignite = tote_ignite,
			stack_max = 1,
			after_dig_node = totedug,
			on_place = toteplace,
			drop = "",
			node_placement_prediction = pred,
			sounds = nodecore.sounds("nc_lode_annealed")
		})
end
reg("", "[combine:1x1")
reg("_full", modname .. "_fill.png", "")
