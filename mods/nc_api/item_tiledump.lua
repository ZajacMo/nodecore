-- LUALOCALS < ---------------------------------------------------------
local io, ipairs, minetest, nodecore, pairs, table, tostring, type
    = io, ipairs, minetest, nodecore, pairs, table, tostring, type
local io_open, table_concat, table_insert, table_sort
    = io.open, table.concat, table.insert, table.sort
-- LUALOCALS > ---------------------------------------------------------

if not nodecore.infodump() then return end

local faces = {
	"top",
	"bottom",
	"right",
	"left",
	"back",
	"front"
}

local function tilize(tiles, max)
	if not tiles then return end
	tiles = minetest.deserialize(minetest.serialize(tiles))
	if not tiles then return end
	for k2, v2 in pairs(tiles) do
		tiles[k2] = (type(v2) == "table" and v2.name or v2.image) or v2
	end
	while max and #tiles > max do tiles[#tiles] = nil end
	while (#tiles > 1) and (tiles[#tiles] == tiles[#tiles - 1]) do
		tiles[#tiles] = nil
	end
	return tiles
end

minetest.after(0, function()
		local function noblank(s) return s and tostring(s):match("%S") and tostring(s) or nil end

		local data = {}
		for k, v in pairs(minetest.registered_items) do
			local key = noblank(v.description) or k
			key = key:gsub("%W+", "_"):lower()
			data[key] = data[key] or {}
			data[key][#data[key] + 1] = {
				technical_name = k,
				drawtype = v.drawtype,
				description = v.description,
				tiles = tilize(v.tiles, #faces),
				inventory_image = noblank(v.inventory_image),
				wield_image = noblank(v.wield_image),
				special_tiles = tilize(v.special_tiles),
			}
		end

		local ents = {}
		for _, v in pairs(data) do
			local curent = {}
			local function writeln(s) curent[#curent + 1] = s end
			table_sort(v, function(a, b) return a.technical_name < b.technical_name end)
			local mesh
			for _, t in ipairs(v) do
				mesh = mesh or t.drawtype == "mesh"
				local tn = t.technical_name
				if t.tiles then
					local tt = t.tiles
					for i = #tt, 1, -1 do
						if i == #tt and i ~= #faces then
							writeln(tn .. " * " .. tt[i])
						else
							writeln(tn .. " " .. faces[i] .. " " .. tt[i])
						end
					end
				end
				if t.special_tiles then
					for i, st in pairs(t.special_tiles) do
						writeln(tn .. " special_" .. i .. " " .. st)
					end
				end
				if noblank(t.inventory_image) then
					writeln(tn .. " inventory " .. t.inventory_image)
				end
				if noblank(t.wield_image) then
					writeln(tn .. " wield " .. t.wield_image)
				end
			end
			if #curent > 0 then
				if mesh then
					table_insert(curent, 1, "# <!> MESH DRAWTYPE; FACES MAY"
						.. " MISMATCH NAMES")
				end
				if noblank(v[1].description) then
					table_insert(curent, 1, "# " .. v[1].description)
				end
				ents[#ents + 1] = table_concat(curent, "\n")
			end
		end
		table_sort(ents)

		local f = io_open(minetest.get_worldpath() .. "/texturepack_override.template.txt", "wb")
		f:write(table_concat(ents, "\n\n"))
		f:close()
	end)
