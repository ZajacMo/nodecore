-- LUALOCALS < ---------------------------------------------------------
local nc, pairs, type
    = nc, pairs, type
-- LUALOCALS > ---------------------------------------------------------

nc.hints = {}

local function conv(spec)
	if not spec then
		return function() return true end
	end
	if type(spec) == "function" then return spec end
	if type(spec) == "table" then
		local f = spec[1]
		if f == true then
			return function(db)
				for i = 2, #spec do
					if db[spec[i]] then return true end
				end
			end
		end
		return function(db)
			for i = 1, #spec do
				if not db[spec[i]] then return end
			end
			return true
		end
	end
	return function(db) return db[spec] end
end

function nc.register_hint(text, goal, reqs, ext)
	local hints = nc.hints
	if type(text) == "table" then
		hints[#hints + 1] = text
		return text
	end
	local t = nc.translate(text)
	local h = {
		text = t,
		goal = conv(goal),
		reqs = conv(reqs)
	}
	if ext then
		for k, v in pairs(ext) do
			h[k] = v
		end
	end
	hints[#hints + 1] = h
	return h
end
