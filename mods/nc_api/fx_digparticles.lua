-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_ceil, math_random
    = math.ceil, math.random
-- LUALOCALS > ---------------------------------------------------------

local getcoord
do
	local coords = {}
	for x = 0, 12, 4 do
		for y = 0, 12, 4 do
			coords[#coords + 1] = x .. "," .. y
		end
	end
	local size = #coords
	local pos = size + 1
	getcoord = function()
		if pos > size then
			for i = size, 2, -1 do
				local j = math_random(1, i)
				local x = coords[i]
				coords[i] = coords[j]
				coords[j] = x
			end
			pos = 1
		end
		pos = pos + 1
		return coords[pos - 1]
	end
end

function nodecore.digparticles(nodedef, partdef)
	if partdef.forcetexture then
		partdef.texture = partdef.forcetexture
		local id = minetest.add_particlespawner(partdef)
		return function() minetest.delete_particlespawner(id) end
	end

	local img = {}
	if nodedef.tiles then
		for i = 1, 6 do
			img[#img + 1] = nodedef.tiles[i > #nodedef.tiles and #nodedef.tiles or i]
		end
	elseif nodedef.inventory_image then
		img[1] = nodedef.inventory_image
	end
	if #img < 1 then return nodecore.log("warning", "no pummel tile images found!") end
	img = nodecore.pickrand(img)
	if img.name then img = img.name end

	partdef.amount = partdef.amount and math_ceil(partdef.amount / 4) or 4

	local t = {}
	for _ = 1, 4 do
		partdef.texture = img .. "^[resize:16x16^[mask:[combine\\:16x16\\:"
		.. getcoord() .. "=nc_api_pummel.png"
		t[#t + 1] = minetest.add_particlespawner(partdef)
	end
	return function()
		for _, v in pairs(t) do
			minetest.delete_particlespawner(v)
		end
	end
end
