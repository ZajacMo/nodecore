-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, string, type
    = minetest, nodecore, string, type
local string_format
    = string.format
-- LUALOCALS > ---------------------------------------------------------

local function createpool(poolname)
	local pool = {}

	local reused = 0
	local inserted = 0
	local removed = 0

	local function rpt()
		nodecore.log("info", string_format(
				"%s resource pool: %d inserted, %d reused, %d removed",
				poolname, inserted, reused, removed))
		inserted = 0
		reused = 0
		removed = 0
		minetest.after(60, rpt)
	end
	minetest.after(60, rpt)

	local function upsert(id, ...)
		if not id then return id, ... end
		local found = pool[id]
		if found then
			found.id = nil
			reused = reused + 1
		else
			inserted = inserted + 1
		end
		local resource = {id = id}
		pool[id] = resource
		return resource, ...
	end

	local function remove(resource)
		if type(resource) ~= "table" then return resource end
		local id = resource.id
		if not id then return end
		resource.id = nil
		local found = pool[id]
		if found == resource then
			pool[id] = nil
			removed = removed + 1
		end
		return id
	end

	local function extract(resource)
		if type(resource) ~= "table" then return resource end
		return resource.id or nil
	end

	return upsert, remove, extract
end

do
	local upsert, remove = createpool("particlespawner")

	local oldcreate = minetest.add_particlespawner
	function minetest.add_particlespawner(...)
		return upsert(oldcreate(...))
	end

	local olddelete = minetest.delete_particlespawner
	function minetest.delete_particlespawner(resource, ...)
		local id = remove(resource)
		if not id then return end
		return olddelete(id, ...)
	end
end

do
	local upsert, remove, extract = createpool("sound")

	local oldcreate = minetest.sound_play
	function minetest.sound_play(...)
		return upsert(oldcreate(...))
	end

	local oldstop = minetest.sound_stop
	function minetest.sound_stop(resource, ...)
		local id = remove(resource)
		if not id then return end
		return oldstop(id, ...)
	end

	local oldfade = minetest.sound_fade
	function minetest.sound_fade(resource, ...)
		local id = extract(resource)
		if not id then return end
		return oldfade(id, ...)
	end
end
