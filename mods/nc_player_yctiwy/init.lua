-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, next, nodecore, pairs, string, table,
      vector
    = ItemStack, math, minetest, next, nodecore, pairs, string, table,
      vector
local math_floor, math_pi, math_random, string_format, table_concat
    = math.floor, math.pi, math.random, string.format, table.concat
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

local disabled = nodecore.setting_bool(
	"nc_yctiwy_disable",
	false,
	"Disable offline player inventory database",
	[[By default, players' offline position and inventory is saved
	for displaying offline "ghost" entities, which can be hidden
	by a different setting, but even when hidden the database is
	still kept up to date. Enabling this setting will completely
	disable that database and purge all data, saving server
	resources, but making ghosts not display when reenabled until
	each player has joined again at least once.]]
)

local hidden = nodecore.setting_bool(
	"nc_yctiwy_hide",
	false,
	"Do not display offline player entities",
	[[By default, players' offline "ghosts" and inventories are
	displayed as entities. Enabling this option hides
	those, reducing resource impact on both client and server,
	but also preventing players from accessing offline player
	inventories. The offline database is still maintained, in
	case the entities are later reenabled.]]
) or disabled

local halflife = nodecore.setting_float(
	"nc_yctiwy_halflife",
	30,
	"Half-life of marker decay",
	[[YCTIWY markers show visible "decay" as players are
	continuously offline for long periods of time. This is
	the number of days that it takes for half of the
	remaining color to bleed out of the marker.]]
) * 86400

------------------------------------------------------------------------
-- DATABASE

local modname = minetest.get_current_modname()
local modstore = minetest.get_mod_storage()

local db = modstore:get_string("db")
if db == "" then db = nil end
db = db and minetest.deserialize(db)
db = db or {}

local drop = modstore:get_string("drop")
if drop == "" then drop = nil end
drop = drop and minetest.deserialize(drop)
drop = drop or {}

local function savedb()
	modstore:set_string("db", next(db) and minetest.serialize(db) or "")
	return modstore:set_string("drop", next(drop) and minetest.serialize(drop) or "")
end

if disabled then
	for k, v in pairs(db) do
		if not v.taken then
			db[k] = nil
		end
	end
	savedb()
elseif not (next(db) or next(drop)) then
	function nodecore.yctiwy_import(newdb, newdrop)
		db = newdb
		drop = newdrop
		savedb()
		nodecore.yctiwy_import = nil
	end
end

local function savestate(player)
	if disabled or not nodecore.player_visible(player) then
		db[player:get_player_name()] = nil
		return
	end
	local ent = {
		pos = player:get_pos(),
		inv = {}
	}
	ent.pos.y = ent.pos.y + 1
	local inv = player:get_inventory()
	for i = 1, inv:get_size("main") do
		local stack = inv:get_stack("main", i)
		ent.inv[i] = stack:to_string()
	end
	ent.seen = minetest.get_gametime()
	db[player:get_player_name()] = ent
end

------------------------------------------------------------------------
-- TELEPORT COMMAND

local teleport = minetest.registered_chatcommands.teleport
if teleport and teleport.func then
	local cannot = nodecore.translate("Cannot teleport an offline player.")
	local oldfunc = teleport.func
	teleport.func = function(caller, ...)
		local oldget = minetest.get_player_by_name
		local function helper(...)
			minetest.get_player_by_name = oldget
			return ...
		end
		function minetest.get_player_by_name(name, ...)
			local player = oldget(name, ...)
			if player then return player end
			local s = db[name]
			if s and s.pos then
				return {
					get_pos = function() return s.pos end,
					set_pos = function()
						minetest.after(0, function()
								return minetest.chat_send_player(caller, cannot)
							end)
					end,
					get_attach = function() end,
				}
			end
		end
		return helper(oldfunc(caller, ...))
	end
end

------------------------------------------------------------------------
-- MISC/UTILITY/COMMON

local function areaunloaded(pos)
	local basepos = vector.floor(pos)
	if minetest.get_node(pos).name == "ignore" then return true end
	for dx = -1, 1, 2 do
		for dy = -1, 1, 2 do
			for dz = -1, 1, 2 do
				if minetest.get_node({
						x = basepos.x + dx,
						y = basepos.y + dy,
						z = basepos.z + dz
					}).name == "ignore" then return true end
			end
		end
	end
end

local function box(n) return {-n, -n, -n, n, n, n} end

local desctitle = nodecore.translate("Offline Player")
local function getdesc(pname, stack)
	local d = desctitle .. "\n" .. nodecore.notranslate(pname)
	if stack then return d .. "\n" .. nodecore.touchtip_stack(stack) end
	return d
end

local function spawnentity(pos, subname, values)
	if areaunloaded(pos) then return end
	local o = minetest.add_entity(pos, modname .. ":" .. subname)
	o = o and o:get_luaentity()
	if not o then return end
	nodecore.log("info", modname .. ": spawned " .. subname .. " at "
		.. minetest.pos_to_string(pos, 2) .. (values.pname
			and (" for " .. values.pname) or ""))
	for k, v in pairs(values) do o[k] = v end
	return o:yctiwy_check()
end

local function entrystack(entry, slot)
	if not entry then return end
	if entry.taken and entry.taken[slot] then return end
	local stack = entry.inv and entry.inv[slot]
	if (not stack) or (stack == "") then return end
	stack = ItemStack(stack)
	local def = minetest.registered_items[stack:get_name()]
	if (not def) or def.virtual_item then return end
	return stack
end

------------------------------------------------------------------------
-- INVENTORY ENTITIES

local thiefdata = {}

minetest.register_entity(modname .. ":slotent", {
		initial_properties = nodecore.stackentprops(),
		is_yctiwy = true,
		slot = 1,
		loose = 0,
		yctiwy_check = function(self)
			local ent = db[self.pname]
			if minetest.get_player_by_name(self.pname) then
				return self.object:remove()
			end
			local stack = entrystack(ent, self.slot)
			if not stack then return self.object:remove() end
			local props = nodecore.stackentprops(stack)
			props.visual_size.x = props.visual_size.x / 2
			props.visual_size.y = props.visual_size.y / 2
			if props.is_visible then
				props.collisionbox = box(0.2)
			end
			if not self.yawed then
				self.yawed = true
				self.object:set_yaw(math_random() * math_pi * 2)
			end
			self.rotating = self.rotating or (math_random(1, 2) == 1) and 0.1 or -0.1
			props.automatic_rotate = self.rotating
			self.object:set_properties(props)
			self.description = getdesc(self.pname, stack)
		end,
		on_punch = function(self, puncher)
			local ent = db[self.pname]

			local punchname = puncher and puncher:get_player_name()
			if not punchname then return end
			local state = thiefdata[punchname]
			if state and (state.target ~= self.pname or state.slot ~= self.slot
				or state.exp < nodecore.gametime) then state = nil end
			state = state or {
				target = self.pname,
				slot = self.slot,
				final = nodecore.gametime + 2
			}
			state.exp = nodecore.gametime + 2
			thiefdata[punchname] = state
			if nodecore.gametime < state.final then return end

			local stack = entrystack(ent, self.slot)
			if not stack then return end

			local function steallog(desc)
				nodecore.log("action", string_format(
						"%s: %q %s %q slot %d item %q at %s",
						modname, puncher:get_player_name(), desc,
						self.pname, self.slot, stack:to_string(),
						minetest.pos_to_string(ent.pos, 0)))
			end
			local rp = vector.round(ent.pos)
			if minetest.is_protected(rp, punchname) and
			not minetest.is_protected(rp, self.pname) then
				steallog("attempts to steal")
				minetest.record_protection_violation(rp, punchname)
				return
			end
			steallog("steals")

			ent.taken = ent.taken or {}
			ent.taken[self.slot] = true
			savedb()
			stack = puncher:get_inventory():add_item("main", stack)
			if not stack:is_empty() then
				nodecore.item_eject(self.object:get_pos(), stack)
			end
			return self.object:remove()
		end
	})

local s = 0.25
local offsets = {
	{x = -s, y = -s, z = -s},
	{x = s, y = -s, z = -s},
	{x = -s, y = s, z = -s},
	{x = s, y = s, z = -s},
	{x = -s, y = -s, z = s},
	{x = s, y = s, z = s},
	{x = -s, y = s, z = s},
	{x = s, y = -s, z = s}
}

local function spawninv(name, entry, existdb)
	entry = entry or db[name]
	if not entry then return end

	for i = 1, #offsets do
		if not existdb[name .. ":" .. i] and entrystack(entry, i) then
			local p = vector.add(offsets[i], entry.pos)
			spawnentity(p, "slotent", {
					pname = name,
					slot = i
				})
		end
	end
end

------------------------------------------------------------------------
-- MARKER ENTITY

local function markertexture(pname)
	local colors = {nodecore.player_model_colors(pname)}
	while #colors > 3 do colors[#colors] = nil end
	for i = 1, #colors do
		colors[i] = string_format("(%s_marker_%d.png^[multiply:%s)",
			modname, i, colors[i])
	end
	local age = minetest.get_gametime() - (db[pname] or {seen = 0}).seen
	local decay = math_floor(240 * (1 - 0.5 ^ (age / halflife)))
	return string_format("%s^(%s_marker_1.png^%s_marker_2.png^%s_marker_3.png"
		.. "^[multiply:#a0a0a0^[opacity:%d)",
		table_concat(colors, "^"), modname, modname, modname, decay)
end

minetest.register_entity(modname .. ":marker", {
		initial_properties = {
			visual = "sprite",
			textures = {"nc_player_wield_slot.png"},
			collisionbox = box(0.1),
			visual_size = {x = 0.2, y = 0.2},
			is_visible = true,
			static_save = false
		},
		is_yctiwy = true,
		yctiwy_check = function(self)
			if (not self.pname) or minetest.get_player_by_name(self.pname)
			or (not minetest.player_exists(self.pname)) or (not db[self.pname]) then
				return self.object:remove()
			end
			self.object:set_properties({textures = {markertexture(self.pname)}})
		end,
		on_punch = function(self)
			self.object:set_properties({pointable = false})
			self.pointtime = 2
			self.on_step = function(me, dtime)
				local pt = me.pointtime or 0
				pt = pt - dtime
				if pt > 0 then
					me.pointtime = pt
				else
					me.object:set_properties({pointable = true})
					me.pointtime = nil
					me.on_step = nil
				end
			end
		end
	})

local function spawnmarker(name, entry, existdb)
	if existdb[name .. ":"] then return end

	entry = entry or db[name]
	if not entry then return end

	spawnentity(entry.pos, "marker", {
			description = getdesc(name),
			pname = name
		})
end

------------------------------------------------------------------------
-- STOLEN ITEMS

local takenitem = modname .. ":taken"
nodecore.register_virtual_item(takenitem, {
		description = "",
		inventory_image = "[combine:1x1",
		hotbar_type = "yctiwy_taken",
	})

nodecore.register_aism({
		itemnames = takenitem,
		interval = 1,
		chance = 1,
		action = function(stack)
			local exp = stack:get_meta():get_float("exp") or 0
			if exp < nodecore.gametime then return "" end
		end
	})

------------------------------------------------------------------------
-- PLAYER HOOKS

local recheck_timer = 0

minetest.register_on_leaveplayer(function(player)
		recheck_timer = 0
		savestate(player)
		return savedb()
	end)

minetest.register_on_shutdown(function()
		for _, pl in pairs(minetest.get_connected_players()) do
			savestate(pl)
		end
		return savedb()
	end)

minetest.register_on_joinplayer(function(player)
		recheck_timer = 0
		local name = player:get_player_name()
		local ent = db[name]
		if (not ent) or (not ent.taken) then return end
		local inv = player:get_inventory()
		local takestack = ItemStack(takenitem)
		takestack:get_meta():set_float("exp", nodecore.gametime + 4)
		for k in pairs(ent.taken) do
			inv:set_stack("main", k, takestack)
		end
		for _, o in pairs(minetest.luaentities) do
			if o and o.is_yctiwy and o.pname == name then
				o.object:remove()
			end
		end
	end)

------------------------------------------------------------------------
-- TIMER

local function dumpinv(ent)
	if areaunloaded(ent.pos) then return end
	for k, v in pairs(ent.inv) do
		if not (ent.taken and ent.taken[k]) then
			local stack = ItemStack(v)
			if not stack:is_empty() then
				if minetest.add_item(ent.pos, stack) then
					minetest.log(string_format("%s: deleted player %q"
							.. " drops slot %d item %q at %s",
							modname, ent.pname, k, stack:to_string(), minetest.pos_to_string(ent.pos, 0)))
					ent.inv[k] = ""
				else
					return
				end
			end
		end
	end
	return true
end

local function dropplayer(name, ent, skipsave)
	ent = ent or db[name]
	if not ent then return end
	ent.pname = name
	drop[#drop + 1] = ent
	db[name] = nil
	return skipsave or savedb()
end

local oldremove = minetest.remove_player
function minetest.remove_player(name, ...)
	local function helper(...)
		dropplayer(name)
		return ...
	end
	return helper(oldremove(name, ...))
end

minetest.register_globalstep(function(dtime)
		recheck_timer = recheck_timer - dtime
		if recheck_timer > 0 then return end
		recheck_timer = 3 + math_random() * 2

		if not hidden then
			for _, ent in pairs(minetest.luaentities) do
				if ent.yctiwy_check then
					ent:yctiwy_check()
				end
			end
		end

		local rollcall = {}
		for _, pl in pairs(minetest.get_connected_players()) do
			rollcall[pl:get_player_name()] = true
			savestate(pl)
		end

		local existdb = {}
		if not hidden then

			for _, ent in pairs(minetest.luaentities) do
				if ent.is_yctiwy then
					existdb[(ent.pname or "") .. ":" .. (ent.slot or "")] = true
				end
			end
		end
		for name, ent in pairs(db) do
			if not minetest.player_exists(name) then
				dropplayer(name, ent, true)
			elseif not (hidden or rollcall[name]) then
				spawnmarker(name, ent, existdb)
				spawninv(name, ent, existdb)
			end
		end

		local batch = drop
		drop = {}
		for _, ent in pairs(batch) do
			if areaunloaded(ent.pos) then
				drop[#drop + 1] = ent
			else
				if not dumpinv(ent) then drop[#drop + 1] = ent end
			end
		end

		return savedb()
	end)
