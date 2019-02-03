-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_ceil, math_floor, math_random
    = math.ceil, math.floor, math.random
-- LUALOCALS > ---------------------------------------------------------

function nodecore.digparticles(pointed, def)
	local img = {}
	if def.tiles then
		for i = 1, 6 do
			img[#img + 1] = def.tiles[i > #def.tiles and #def.tiles or i]
		end
	elseif def.inventory_image then
		img[1] = def.inventory_image
	end
	if #img < 1 then return minetest.log("no pummel tile images found!") end
	img = nodecore.pickrand(img)
	if img.name then img = img.name end

	def.amount = def.amount and math_ceil(def.amount / 4) or 4

	local t = {}
	for i = 1, 4 do
		def.texture = img .. "^[mask:[combine\\:16x16\\:"
		.. math_floor(math_random() * 12) .. ","
		.. math_floor(math_random() * 12) .. "=nc_api_pummel.png"
		t[#t + 1] =  minetest.add_particlespawner(def)
	end
	return function()
		for k, v in pairs(t) do
			minetest.delete_particlespawner(v)
		end
	end
end
