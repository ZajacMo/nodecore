-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_ceil, math_floor, math_random
    = math.ceil, math.floor, math.random
-- LUALOCALS > ---------------------------------------------------------

function nodecore.digparticles(nodedef, partdef)
	local img = {}
	if nodedef.tiles then
		for i = 1, 6 do
			img[#img + 1] = nodedef.tiles[i > #nodedef.tiles and #nodedef.tiles or i]
		end
	elseif nodedef.inventory_image then
		img[1] = nodedef.inventory_image
	end
	if #img < 1 then return minetest.log("no pummel tile images found!") end
	img = nodecore.pickrand(img)
	if img.name then img = img.name end

	partdef.amount = partdef.amount and math_ceil(partdef.amount / 4) or 4

	local t = {}
	for i = 1, 4 do
		partdef.texture = img .. "^[mask:[combine\\:16x16\\:"
		.. math_floor(math_random() * 12) .. ","
		.. math_floor(math_random() * 12) .. "=nc_api_pummel.png"
		t[#t + 1] =  minetest.add_particlespawner(partdef)
	end
	return function()
		for k, v in pairs(t) do
			minetest.delete_particlespawner(v)
		end
	end
end
