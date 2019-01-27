-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore, vector
    = ipairs, math, minetest, nodecore, vector
local math_floor, math_random
    = math.floor, math.random
-- LUALOCALS > ---------------------------------------------------------

local pummeling = {}

local function fxcore(pname, pointed, img)
	img = img .. "^[mask:[combine\\:16x16\\:"
	.. math_floor(math_random() * 12) .. ","
	.. math_floor(math_random() * 12) .. "=nc_api_pummel.png"
	
	local a = pointed.above
	local b = pointed.under
	local vel = vector.subtract(a, b)
	local mid = vector.multiply(vector.add(a, b), 0.5)
	local p1 = {x = vel.y, y = vel.z, z = vel.x}
	local p2 = {x = vel.z, y = vel.x, z = vel.y}
	local s1 = vector.add(vector.add(mid, vector.multiply(p1, 0.5)), vector.multiply(p2, 0.5))
	local s2 = vector.add(vector.add(mid, vector.multiply(p1, -0.5)), vector.multiply(p2, -0.5))
	vel = vector.multiply(vel, 0.5)

	return minetest.add_particlespawner({
			amount = 3,
			time = 1.5,
			minpos = s1,
			maxpos = s2,
			minvel = vel,
			maxvel = vel,
			minexptime = 0.4,
			maxexptime = 0.9,
			minsize = 1,
			maxsize = 5,
			texture = img,
			playername = pname
		})
end

local function particlefx(pname, pointed, def)
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
	for i = 1, 4 do fxcore(pname, pointed, img) end
end

minetest.register_on_punchnode(function(pos, node, puncher, pointed)
		if not puncher:is_player() then return end
		local pname = puncher:get_player_name()

		node = node or minetest.get_node(pos)
		local def = minetest.registered_nodes[node.name]
		if not def.pummeldefs then return end

		local now = minetest.get_us_time() / 1000000
		local pum = {
			puncher = puncher,
			pname = pname,
			pos = pos,
			pointed = pointed,
			node = node,
			def = def,
			start = now,
			wield = puncher:get_wielded_item():to_string(),
			count = 0
		}

		local old = pummeling[pname]
		local hash = minetest.hash_node_position
		if old and hash(old.pos) == hash(pum.pos)
		and hash(old.pointed.above) == hash(pum.pointed.above)
		and hash(old.pointed.under) == hash(pum.pointed.under)
		and pum.wield == old.wield
		and old.last >= (now - 2)
		then pum = old end

		pum.count = pum.count + 1
		pum.last = now
		pum.duration = now - pum.start
		pummeling[pname] = pum

		local resolve
		for i, v in ipairs(def.pummeldefs) do
			if not resolve then
				local ok = v.check(pos, node, pum)
				if ok then
					resolve = v.resolve
					pum.check = ok
				end
			end
		end
		if not resolve then
			pummeling[pname] = nil
			return
		end

		if pum.count > 1 then
			if pum.particles then minetest.delete_particlespawner(pum.particles) end
			pum.particles = particlefx(pname, pointed, def)
		end

		if resolve(pos, node, pum) then
			if pum.particles then minetest.delete_particlespawner(pum.particles) end
			nodecore.player_knowledge_add(puncher, "pummel:" .. node.name)
			pummeling[pname] = nil
		end
	end)

function nodecore.add_pummel(nodedef, check, resolve)
	nodedef.pummeldefs = nodedef.pummeldefs or {}
	nodedef.pummeldefs[#nodedef.pummeldefs + 1] = {
		check = check,
		resolve = resolve
	}
end
function nodecore.extend_pummel(name, check, resolve)
	nodecore.extend_item(name, function(copy)
			return nodecore.add_pummel(copy, check, resolve)
		end)
end

function nodecore.pummel_toolspeed(pos, node, stats)
	return nodecore.toolspeed(
		stats.puncher:get_wielded_item(),
		stats.def.groups
	)
end
