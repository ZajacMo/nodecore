-- LUALOCALS < ---------------------------------------------------------
local ItemStack, ipairs, math, minetest, nodecore, pairs, type
    = ItemStack, ipairs, math, minetest, nodecore, pairs, type
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local metadesc = "Tote (@1 / @2)"
nodecore.translate_inform(metadesc)

local function protected(pos, whom)
	return whom and whom:is_player()
	and minetest.is_protected(pos, whom:get_player_name())
end

local function totefill(stack, meta, data, ser)
	meta = meta or stack:get_meta()
	if data and #data then
		stack:set_name(modname .. ":handle_full")
		meta:set_string("carrying", ser or minetest.serialize(data))
		local slots = #data
		local full = 0
		for _, s in ipairs(data) do
			local ss = s.m and nodecore.stack_get_serial(s.m)
			if ss and not ss:is_empty() then
				full = full + 1
			end
		end
		meta:set_string("description", nodecore.translate(metadesc, full, slots))
	else
		stack:set_name(modname .. ":handle")
		meta:set_string("carrying", "")
		meta:set_string("description", "")
	end
	return stack
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
					local m = nodecore.meta_serializable(minetest.get_meta(p))
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
		totefill(drop, nil, dump)
	end
	minetest.handle_node_drops(pos, {drop}, digger)
end

local function toteplace(stack, placer, pointed, ...)
	local pos = nodecore.buildable_to(pointed.under) and pointed.under
	or nodecore.buildable_to(pointed.above) and pointed.above
	if (not pos) or nodecore.protection_test(pos, placer) then return end

	stack = ItemStack(stack)
	local inv = stack:get_meta():get_string("carrying")
	inv = inv and (inv ~= "") and minetest.deserialize(inv)
	if not inv then return minetest.item_place(stack, placer, pointed, ...) end

	local commit = {{pos, {
				name = modname .. ":handle",
				param2 = placer and minetest.dir_to_facedir(placer:get_look_dir())
				or math_random(0, 3)
	}, {}}}
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
			nodecore.fallcheck(v[1])
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
			local ss = slot and slot.m and nodecore.stack_get_serial(slot.m)
			if ss and not ss:is_empty() then
				nodecore.item_eject(pos, ss)
			end
		else
			newinv[#newinv + 1] = slot
		end
	end
	local newraw = minetest.serialize(newinv)
	if newraw == raw then return true end

	totefill(stack, stackmeta, newinv, newraw)
	nodecore.stack_set(pos, stack)
	return true
end

local txr_bot = "nc_lode_annealed.png"
local txr_sides = "(" .. txr_bot .. "^[mask:nc_tote_sides.png)"
local txr_handle = txr_bot .. "^nc_tote_knurl.png"
local txr_top = txr_handle .. "^[transformFX^[mask:nc_tote_top.png^[transformR90^" .. txr_sides

local function reg(suff, inner, def)
	return minetest.register_node(modname .. ":handle" .. suff, nodecore.underride(def, {
				description = "Tote Handle",
				drawtype = "mesh",
				visual_scale = nodecore.z_fight_ratio,
				mesh = "nc_tote_handle.obj",
				selection_box = nodecore.fixedbox(),
				paramtype = "light",
				paramtype2 = "facedir",
				tiles = {
					txr_sides,
					txr_bot,
					txr_top,
					txr_handle,
					inner
				},
				backface_culling = true,
				use_texture_alpha = "clip",
				groups = {
					snappy = 1,
					flammable = 5,
					tote = 1,
					scaling_time = 50
				},
				on_ignite = tote_ignite,
				after_dig_node = totedug,
				on_place = toteplace,
				on_place_node = toteplace,
				drop = "",
				sounds = nodecore.sounds("nc_lode_annealed")
			}))
end
reg("", "[combine:1x1", {
		stack_max = 8,
		groups = {container = 1}
	})
reg("_full", modname .. "_fill.png", {
		stack_max = 1,
		node_placement_prediction = "",
		groups = {container = 100}
	})
