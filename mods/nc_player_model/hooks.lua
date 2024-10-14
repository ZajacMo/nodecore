-- LUALOCALS < ---------------------------------------------------------
local core, math, nc, pairs, vector
    = core, math, nc, pairs, vector
local math_abs, math_deg, math_pi
    = math.abs, math.deg, math.pi
-- LUALOCALS > ---------------------------------------------------------

local frame_blend = 0.1

local pitch_mult = 2/3
local pitch_max = 60
local pitch_min = -15
local pitch_precision = 1

local item_drop_times = {}

local olddrop = core.item_drop
function core.item_drop(item, player, ...)
	if player then item_drop_times[player:get_player_name()] = nc.gametime end
	return olddrop(item, player, ...)
end
nc.register_on_leaveplayer(function(player)
		item_drop_times[player:get_player_name()] = nil
	end)

local function boneprop(vec)
	return {vec = vec, absolute = true, interpolation = 0.5}
end
local function setbonepos(player, bone, pos, rot)
	if player.set_bone_override then
		rot = vector.multiply(rot, math_pi / 180)
		return player:set_bone_override(bone, {
				position = boneprop(pos),
				rotation = boneprop(rot),
			})
	end
	return player:set_bone_position(bone, pos, rot)
end

nc.register_playerstep({
		label = "player model visuals",
		action = function(player, data)
			if data.properties.visual_size.x <= 0 then return end

			data.item_drop_time = item_drop_times[player:get_player_name()]

			local props = nc.player_visuals_base(player, data)

			-- Skin can be set preemptively by visuals_base; if so, then will
			-- not be modified here.
			if not props.textures then
				-- Recheck skin only every couple seconds to avoid
				-- interfering with animations if skin includes continuous
				-- effects.
				local now = core.get_us_time() / 1000000
				if (not data.skincalctime) or (now >= data.skincalctime + 2) then
					data.skincalctime = now
					props.textures = {nc.player_skin(player, data)}
				end
			end

			for k, v in pairs(props) do data.properties[k] = v end

			local anim = nc.player_anim(player, data)
			if anim.name then
				nc.player_discover(player, "anim_" .. anim.name)
			end
			data.animation = {{x = anim.x, y = anim.y}, anim.speed, frame_blend}

			local pitch = -math_deg(player:get_look_vertical()) * pitch_mult
			if anim and anim.headpitch then pitch = pitch + anim.headpitch end
			if pitch < pitch_min then pitch = pitch_min end
			if pitch > pitch_max then pitch = pitch_max end
			if not (data.headpitch and math_abs(data.headpitch - pitch)
				< pitch_precision) then
				data.headpitch = pitch
				setbonepos(player, "Head",
					{x = 0, y = 5/16, z = -pitch / 45},
					{x = pitch, y = 0, z = 0}
				)
			end
		end
	})
