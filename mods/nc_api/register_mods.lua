-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, table
    = ipairs, minetest, nodecore, pairs, table
local table_concat, table_sort
    = table.concat, table.sort
-- LUALOCALS > ---------------------------------------------------------

nodecore.coremods = {}

function nodecore.amcoremod(v)
	nodecore.coremods[minetest.get_current_modname()] = (v == nil) or v
end
nodecore.amcoremod()

local function idx2str(idx, key)
	local parts = {}
	if idx[true] then
		parts[#parts + 1] = key
	end
	local keys = {}
	for k in pairs(idx) do
		if k ~= true then
			keys[#keys + 1] = k
		end
	end
	if #keys == 1 then
		local k = keys[1]
		parts[#parts + 1] = (key and (key .. "_") or "")
		.. idx2str(idx[k], k)
	elseif #keys > 1 then
		table_sort(keys)
		for i = 1, #keys do
			local k = keys[i]
			keys[i] = idx2str(idx[k], k)
		end
		parts[#parts + 1] = (key and key .. "_{" or "")
		.. table_concat(keys, ", ")
		.. (key and "}" or "")
	end
	return table_concat(parts, ", "), #parts > 1
end

minetest.register_on_mods_loaded(function()
		local idx = {}
		for _, n in pairs(minetest.get_modnames()) do
			if not nodecore.coremods[n] then
				local parts = n:split("_")
				local nav = idx
				for _, p in ipairs(parts) do
					nav[p] = nav[p] or {}
					nav = nav[p]
				end
				nav[true] = true
			end
		end
		nodecore.added_mods_list = idx2str(idx)
	end)
