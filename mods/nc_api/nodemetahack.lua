-- LUALOCALS < ---------------------------------------------------------
local getmetatable, minetest, pairs
    = getmetatable, minetest, pairs
-- LUALOCALS > ---------------------------------------------------------

local publicfields = {
	formspec = true,
	infotext = true
}

local function hook(meta)
	for k, v in pairs(meta) do
		if k:sub(1, 4) == "set_" then
			meta[k] = function(data, name, ...)
				if not publicfields[name] then
					data:mark_as_private(name)
				end
				return v(data, name, ...)
			end
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
