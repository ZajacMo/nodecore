-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

local modname = minetest.get_current_modname()

local xyz = function(n) return {x = n, y = n, z = n} end
local size_w_item = xyz(0.2)
local size_w_tool = xyz(0.3)
local size_slot = xyz(0.075)
local size_item = xyz(0.1)

local hidden = {is_visible = false}
local selslot = {is_visible = true, visual_size = size_slot, textures = {"nc_player_wield:sel"}}
local emptyslot = {is_visible = true, visual_size = size_slot, textures = {"nc_player_wield:slot"}}

local function calcprops(itemname, iswield)
	local def = minetest.registered_items[itemname]
	if def and def.virtual_item then return hidden end
	if itemname == "" then return iswield and hidden or emptyslot end
	return {
		is_visible = true,
		visual_size = iswield and (def and def.type == "tool" and size_w_tool
			or size_w_item) or (itemname == "" and size_slot) or size_item,
		textures = {itemname},
		glow = def and (def.light_source or def.glow or 0)
	}
end

local propcache_item = {}
local propcache_wield = {}
local function itemprops(itemname, iswield)
	local cache = iswield and propcache_wield or propcache_item
	local found = cache[itemname]
	if found then return found end
	found = calcprops(itemname, iswield)
	cache[itemname] = found
	return found
end

local entname = modname .. ":wv"

local entdef
entdef = {
	initial_properties = {
		hp_max = 1,
		physical = false,
		collide_with_objects = false,
		collisionbox = {0, 0, 0, 0, 0, 0},
		visual = "wielditem",
		textures = {""},
		is_visible = false,
		static_save = false,
		glow = 0
	},
	on_activate = function(self)
		self.on_step = entdef.on_step
	end,
	on_step = function(self)
		local conf = self.conf
		if not conf then return self.object:remove() end

		local pdata = self.conf.ent.data.wield
		if pdata == nil then return self.object:remove() end
		if not pdata then return self.object:set_properties(hidden) end

		if not self.att then
			self.att = true
			return self.object:set_attach(self.conf.ent.object,
				conf.bone, conf.apos, conf.arot)
		end

		local widx = pdata.widx
		if conf.slot == widx then
			return self.object:set_properties(selslot)
		end

		return self.object:set_properties(itemprops(
				pdata.inv[conf.slot or widx],
				not conf.slot))
	end
}
minetest.register_entity(entname, entdef)

function nodecore.mock_player_wieldview(ent)
	local pos = ent.object:get_pos()
	if not pos then return end

	for _, wv in pairs(minetest.luaentities) do
		if wv.name == entname and wv.conf.ent == ent then
			wv.object:remove()
		end
	end

	local function addslot(n, b, x, y, z, rx, ry, rz)
		local obj = minetest.add_entity(pos, entname)
		obj:get_luaentity().conf = {
			ent = ent,
			slot = n,
			pos = pos,
			bone = b,
			apos = {
				x = x,
				y = y,
				z = z
			},
			arot = {
				x = rx or 0,
				y = ry or 180,
				z = rz or 0
			}
		}
	end

	addslot(nil, "Arm_Right", 0, 7, 2, -90, 200, 90)

	local function cslot(n, x, y, z)
		return addslot(n, "Bandolier", x * 0.8,
			0.75 + y * 1.6,
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
end
