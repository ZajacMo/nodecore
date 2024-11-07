-- LUALOCALS < ---------------------------------------------------------
local core, nc, pairs, vector
    = core, nc, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

nc.amcoremod()

local modname = core.get_current_modname()

------------------------------------------------------------------------
-- Slot Appearance

for _, n in pairs({"slot", "sel"}) do
	core.register_craftitem(modname .. ":" .. n, {
			description = "",
			inventory_image = "nc_player_wield_" .. n .. ".png",
			virtual_item = true
		})
end

local xyz = function(n) return {x = n, y = n, z = n} end
local bbox = function(n) return {-n, -n, -n, n, n, n} end
local size_w_item = xyz(0.2)
local size_w_tool = xyz(0.3)
local size_slot = xyz(0.15)
local size_item = xyz(0.1)

local hidden = {
	is_visible = false,
	glow = 0
}
local selslot = {
	is_visible = true,
	visual = "upright_sprite",
	visual_size = size_slot,
	textures = {modname .. "_sel.png"},
	glow = 0
}
local emptyslot = {
	is_visible = true,
	visual = "upright_sprite",
	visual_size = size_slot,
	textures = {modname .. "_slot.png"},
	glow = 0
}

local function itemprops(stack, iswield)
	if not stack then return selslot end

	local itemname = stack:get_name()

	local def = core.registered_items[itemname]
	if def and def.virtual_item then return hidden end

	if itemname == "" then return iswield and hidden or emptyslot end

	local props = nc.stackentprops(stack)
	props.visual_size = iswield and (def and def.type == "tool" and size_w_tool
		or size_w_item) or (itemname == "" and size_slot) or size_item
	return props
end

------------------------------------------------------------------------
-- Entity Definition

local entname = modname .. ":ent"
core.register_entity(entname, {
		initial_properties = {
			hp_max = 1,
			physical = false,
			collide_with_objects = false,
			collisionbox = bbox(0),
			selectionbox = bbox(0),
			textures = {""},
			pointable = false,
			is_visible = false,
			static_save = false,
			glow = 0
		}
	})

------------------------------------------------------------------------
-- Attachment configuration

local attachconfig = {}
do
	local function addslot(n, b, x, y, z, rx, ry, rz)
		attachconfig[n] = {
			bone = b,
			apos = vector.new(x, y, z),
			arot = vector.new(rx or 0, ry or 180, rz or 0),
		}
	end

	local function cslot(n, x, y, z)
		return addslot(n, "Bandolier", x * 0.8,
			2 + y * 1.6,
			-0.25 + z)
	end

	cslot(1, 1.75, 0, 0)
	cslot(2, -1, 1, 0.05)
	cslot(3, 1, 2, 0.1)
	cslot(4, -1.75, 3, 0.02)
	cslot(5, 1.75, 3, 0.02)
	cslot(6, -1, 2, 0.1)
	cslot(7, 1, 1, 0.05)
	cslot(8, -1.75, 0, 0)

	addslot(0, "Arm_Right", 0, 7, 2, -90, 200, 90)
end

------------------------------------------------------------------------
-- Globalstep Sync

local function setitem(ent, slot)
	local itemstring = slot.item and slot.item:to_string()
	if ent.itemstring ~= itemstring then
		ent.object:set_properties(itemprops(slot.item, slot.i == 0))
		ent.itemstring = itemstring
	end
end

nc.register_globalstep(function()
		local slots = {}
		for _, player in pairs(core.get_connected_players()) do
			local pname = player:get_player_name()
			if nc.interact(pname) and nc.player_visible(pname) then
				local widx = player:get_wield_index()
				local inv = player:get_inventory():get_list("main")
				for i = 1, 8 do
					slots[pname .. ":" .. i] = {
						i = i,
						item = i ~= widx and inv[i],
						player = player,
					}
				end
				slots[pname .. ":0"] = {
					i = 0,
					item = inv[widx],
					player = player,
				}
			end
		end

		for _, ent in pairs(core.luaentities) do
			if ent.name == entname then
				local found = slots[ent.slotkey]
				if found then
					setitem(ent, found)
					slots[ent.slotkey] = nil
				else
					ent.object:remove()
				end
			end
		end

		for k, v in pairs(slots) do
			local obj = core.add_entity(v.player:get_pos(), entname)
			if obj then
				local ent = obj:get_luaentity()
				ent.slotkey = k
				local conf = attachconfig[v.i]
				obj:set_attach(v.player, conf.bone, conf.apos, conf.arot)
				setitem(ent, v)
			end
		end
	end)
