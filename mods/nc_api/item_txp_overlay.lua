-- LUALOCALS < ---------------------------------------------------------
local io, minetest, nodecore, pairs, table, type
    = io, minetest, nodecore, pairs, table, type
local io_open, table_concat, table_sort
    = io.open, table.concat, table.sort
-- LUALOCALS > ---------------------------------------------------------

local missing = {}

minetest.after(0, function()
		local t = {}
		for k in pairs(missing) do t[#t + 1] = k end
		if #t < 1 then return end
		table_sort(t)
		nodecore.log("warning", "WARNING: missing txp override images:\n\t"
			.. table_concat(t, "\n\t"))
	end)

local function overlay(name, img, imgtype)
	if (not img) or (img == "") or (type(img) ~= "string")
	or (not img:match("%^")) or img:match("%^txp_") then return img end

	local tpath = "txp_" .. name:gsub("^%W+", "")
	:gsub("%W+", "_") .. "_" .. imgtype .. ".png"

	local fullpath = minetest.get_modpath(minetest.get_current_modname())
	.. "/textures/" .. tpath
	local f = io_open(fullpath, "rb")
	if not f then
		missing[fullpath] = img
		return img
	end
	f:close()

	return img .. "^" .. tpath .. "^[makealpha:255,254,2"
end

nodecore.register_on_register_item(function(name, def)
		def.inventory_image = overlay(name, def.inventory_image, "inv")
		def.wield_image = overlay(name, def.wield_image, "wield")
	end)
