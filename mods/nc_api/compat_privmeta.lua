-- LUALOCALS < ---------------------------------------------------------
local core, getmetatable, nc, pairs
    = core, getmetatable, nc, pairs
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

-- It was suggested to do this universally in
-- https://github.com/minetest/minetest/issues/10127
-- but abandoned due to compat concerns, which
-- don't apply to NodeCore.

local publicfields = {
	formspec = true,
	infotext = true
}
nc.public_meta_fields = publicfields

local function hook(meta)
	for k, v in pairs(meta) do
		if k:sub(1, 4) == "set_" then
			meta[k] = function(data, name, val, ...)
				if val ~= "" and not publicfields[name] then
					data:mark_as_private(name)
				end
				return v(data, name, val, ...)
			end
			nc.log("info", modname .. " auto-privatized meta " .. k)
		end
	end
end

local rawmeta = core.get_meta
function core.get_meta(...)
	local raw = rawmeta(...)
	if raw then
		local meta = getmetatable(raw)
		if meta then
			hook(meta)
			core.get_meta = rawmeta
		end
	end
	return raw
end
