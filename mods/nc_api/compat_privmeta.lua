-- LUALOCALS < ---------------------------------------------------------
local getmetatable, minetest, nodecore, pairs
    = getmetatable, minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

-- It was suggested to do this universally in
-- https://github.com/minetest/minetest/issues/10127
-- but abandoned due to compat concerns, which
-- don't apply to NodeCore.

local publicfields = {
	formspec = true,
	infotext = true
}
nodecore.public_meta_fields = publicfields

local function hook(meta)
	for k, v in pairs(meta) do
		if k:sub(1, 4) == "set_" then
			meta[k] = function(data, name, ...)
				if not publicfields[name] then
					data:mark_as_private(name)
				end
				return v(data, name, ...)
			end
			nodecore.log("info", modname .. " auto-privatized meta " .. k)
		end
	end
end

local rawmeta = minetest.get_meta
function minetest.get_meta(...)
	local raw = rawmeta(...)
	if raw then
		local meta = getmetatable(raw)
		if meta then
			hook(meta)
			minetest.get_meta = rawmeta
		end
	end
	return raw
end
