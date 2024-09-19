-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, table, vector
    = math, minetest, nodecore, pairs, table, vector
local math_ceil, table_shuffle
    = math.ceil, table.shuffle
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
			table_shuffle(coords)
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

function nodecore.toolbreakparticles(player, wielddef, amount)
	local pos = player:get_pos()
	if not pos then return end
	wielddef = wielddef or minetest.registered_items[player:get_wielded_item():get_name()]
	if not wielddef then return end
	pos.y = pos.y + player:get_properties().eye_height - 0.1
	local look = player:get_look_dir()
	pos = vector.add(pos, vector.multiply(look, 0.5))
	local look2 = vector.multiply(look, 2)
	return nodecore.digparticles(wielddef, {
			time = 0.05,
			amount = amount,
			minpos = pos,
			maxpos = pos,
			minvel = vector.add(look2, {x = -2, y = -2, z = -2}),
			maxvel = vector.add(look2, {x = 2, y = 2, z = 2}),
			minacc = {x = 0, y = -8, z = 0},
			maxacc = {x = 0, y = -8, z = 0},
			minexptime = 0.25,
			maxexptime = 1,
			minsize = 2,
			maxsize = 4
		})
end
