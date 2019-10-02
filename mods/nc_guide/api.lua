-- LUALOCALS < ---------------------------------------------------------
local nodecore, type
    = nodecore, type
-- LUALOCALS > ---------------------------------------------------------

nodecore.hints = {}

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

function nodecore.addhint(text, goal, reqs)
	local hints = nodecore.hints
	local t = nodecore.translate(text)
	local h = {
		text = nodecore.translate("- @1", t),
		done = nodecore.translate("- DONE: @1", t),
		goal = conv(goal),
		reqs = conv(reqs)
	}
	hints[#hints + 1] = h
	return h
end
