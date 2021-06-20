-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, string, tonumber, vector
    = math, minetest, nodecore, string, tonumber, vector
local math_ceil, math_floor, math_random, string_format
    = math.ceil, math.floor, math.random, string.format
-- LUALOCALS > ---------------------------------------------------------

local exptime = 2
local msgtime = 5
local finishtime = tonumber(minetest.settings:get(nodecore.product:lower()
		.. "_escape_time")) or (60 + msgtime)

local dist = tonumber(minetest.settings:get(nodecore.product:lower()
		.. "_escape_distance")) or 256
local bias = dist / 16

local message = "----- EMERGENCY ESCAPE: @1 -----"
nodecore.translate_inform(message)

local sneakonly = 64

nodecore.register_playerstep({
		label = "player escape",
		action = function(player, data)
			local state = data.escapestate
			local control = player:get_player_control_bits()
			local now = nodecore.gametime
			local pos = player:get_pos()

			if not (state and state.exp > now and vector.equals(pos, state.pos)) then
				state = nil
			end

			if state and state.sneak then
				if control == 0 then
					state.sneak = nil
					state.exp = now + exptime
				elseif control ~= sneakonly then
					state = nil
				end
			elseif control == sneakonly then
				state = {
					sneak = true,
					pos = pos,
					exp = now + exptime,
					finish = state and state.finish or (now + finishtime)
				}
			elseif control ~= 0 then
				state = nil
			end

			data.escapestate = state
			if not state then return end

			local remain = data.escapestate.finish - now
			if remain > finishtime - msgtime then return end

			if remain <= 0 then
				data.escapestate = nil
				nodecore.show_touchtip(player, "", 0)
				nodecore.setphealth(player, 0, "player_escape")
				pos.y = pos.y + dist
				if pos.y > dist then
					pos.y = pos.y - (dist / 2) + math_random() * dist
				end
				local function xz(n)
					n = n - (dist / 2) + math_random() * dist
					if n > dist then return n - bias end
					if n < -dist then return n + bias end
					return n
				end
				pos.x = xz(pos.x)
				pos.z = xz(pos.z)
				return player:set_pos(pos)
			end

			remain = math_ceil(remain)
			if remain > 60 then
				remain = string_format("%d:%02d",
					math_floor(remain / 60), remain % 60)
			end
			nodecore.show_touchtip(player, nodecore.translate(message, remain), 1)
		end
	})
