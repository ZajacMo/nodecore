-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore, pairs, type
    = ipairs, math, minetest, nodecore, pairs, type
local math_floor, math_random
    = math.floor, math.random
-- LUALOCALS > ---------------------------------------------------------

local smoke_add, smoke_flush = nodecore.fairlimit(50)

local smoking = {}

nodecore.interval(60, function()
		local del = {}
		local now = minetest.get_us_time() / 1000000
		for k, v in pairs(smoking) do
			if v.expo < now then
				del[#del + 1] = k
			end
		end
		for i = 1, #del do smoking[del[i]] = nil end
	end)

nodecore.register_globalstep("smoke queue", function()
		for _, item in ipairs(smoke_flush()) do
			local pos, qty, time, scale = item.pos, item.qty, item.time, item.scale
			local now = minetest.get_us_time() / 1000000
			local key = minetest.hash_node_position(pos)
			local old = smoking[key]
			if old and now < old.exp then minetest.delete_particlespawner(old.id) end
			if qty <= 0 then
				smoking[key] = nil
				return
			end
			smoking[key] = {
				id = minetest.add_particlespawner({
						texture = "nc_api_craft_smoke.png",
						collisiondetection = true,
						amount = qty,
						time = time,
						minpos = {x = pos.x - 0.4, y = pos.y - 0.4, z = pos.z - 0.4},
						maxpos = {x = pos.x + 0.4, y = pos.y + 0.4, z = pos.z + 0.4},
						minvel = {x = -0.1, y = 0.3, z = -0.1},
						maxvel = {x = 0.1, y = 0.7, z = 0.1},
						minexptime = 1,
						maxexptime = 5,
						minsize = 1 * scale,
						maxsize = 3 * scale
					}),
				exp = now + time
			}
		end
	end)

local function smokefx(pos, opts, rate)
	if type(opts) == "number" then
		opts = {time = opts, rate = rate}
	end
	opts = nodecore.underride(opts or {}, {
			time = 0,
			rate = 0,
			scale = 1
		})
	opts.pos = pos
	if opts.time < 0.05 then opts.time = 0.05 end

	local qty = opts.qty or (opts.rate * opts.time)
	local intqty = math_floor(qty)
	if (qty ~= intqty) and (math_random() <= (qty - intqty)) then
		intqty = intqty + 1
	end
	opts.qty = intqty

	return smoke_add(opts)
end
nodecore.smokefx = smokefx

function nodecore.smokeburst(pos, qty)
	return smokefx(pos, {qty = qty or 8})
end

function nodecore.smokeclear(pos)
	local old = smoking[minetest.hash_node_position(pos)]
	if not old then return end
	local now = minetest.get_us_time() / 1000000
	if now < old.exp then return minetest.delete_particlespawner(old.id) end
end
