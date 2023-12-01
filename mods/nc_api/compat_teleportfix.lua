-- LUALOCALS < ---------------------------------------------------------
local getmetatable, minetest, nodecore, pairs, string, type, vector
    = getmetatable, minetest, nodecore, pairs, string, type, vector
local string_format
    = string.format
-- LUALOCALS > ---------------------------------------------------------

local playerdata = {}

local function now() return minetest.get_us_time() / 1000000 end
local pstr = function(v) return minetest.pos_to_string(v, 0) end

local raw_set_pos

local function check(player, pname, pdata)
	if now() >= pdata.stamp + pdata.exp then
		minetest.log("action", string_format("teleport tracking for %s expired",
				pname))
		playerdata[pname] = nil
		return
	end
	local age = now() - pdata.stamp
	if age < 0.5 then return end -- limit retry rate
	local pos = player:get_pos()
	local odist = vector.distance(pos, pdata.old)
	local ndist = vector.distance(pos, pdata.pos)
	if odist < ndist then
		minetest.log("warning", string_format("correcting teleport regression of %s"
				.. " found at %s, teleported from %s (%d m) to %s (%d m)"
				.. " %.3f s ago",
				pname, pstr(pos), pstr(pdata.old), odist, pstr(pdata.pos),
				ndist, now() - pdata.stamp))
		pdata.stamp = now()
		return raw_set_pos(player, pdata.pos)
	end
end

minetest.register_globalstep(function()
		for _, player in pairs(minetest.get_connected_players()) do
			local pname = player:get_player_name()
			local pdata = playerdata[pname]
			if pdata then check(player, pname, pdata) end
		end
	end)

local function patchplayers()
	local anyplayer = (minetest.get_connected_players())[1]
	if not anyplayer then
		return minetest.after(0, patchplayers)
	end

	local meta = getmetatable(anyplayer)
	meta = meta and meta.__index or meta
	if not meta.set_pos then return end

	raw_set_pos = meta.set_pos
	function meta:set_pos(pos, ...)
		if (not self) or (not self.is_player) or (not self:is_player())
		or (not pos) or type(pos) ~= "table" or (not pos.x) or (not pos.y)
		or (not pos.z) then
			return raw_set_pos(self, pos, ...)
		end
		local pname = self:get_player_name()
		local old = self:get_pos()
		local dist = vector.distance(old, pos)
		if dist <= 2 then
			-- ignore trivial corrections
			return raw_set_pos(self, pos, ...)
		end
		-- Expire in the time a player could legit run from A to B
		-- given a max speed of ~50m/s, reasonable NodeCore falling
		-- terminal velocity.
		local exp = dist / 50
		if exp > 60 then exp = 60 end
		minetest.log("action", string_format("teleport tracking for %s"
				.. " from %s to %s, for %.3f s",
				pname, pstr(old), pstr(pos), exp))
		playerdata[pname] = {
			old = old,
			pos = pos,
			stamp = now(),
			exp = exp
		}
		return raw_set_pos(self, pos, ...)
	end
	nodecore.log("info", "teleport regression detection player:set_pos hooked")
end
minetest.after(0, patchplayers)
