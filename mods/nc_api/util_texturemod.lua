-- LUALOCALS < ---------------------------------------------------------
local nodecore, pairs, setmetatable, string, tostring
    = nodecore, pairs, setmetatable, string, tostring
local string_find, string_gsub
    = string.find, string.gsub
-- LUALOCALS > ---------------------------------------------------------

local tmod = {}
local tmeta = {}
setmetatable(tmod, tmeta)
nodecore.tmod = tmod

function tmod:new(img)
	local obj = {img = img}
	local ometa = {}
	for k, v in pairs(tmeta) do ometa[k] = v end
	ometa.__index = self
	setmetatable(obj, ometa)
	return obj
end
tmeta.__call = tmod.new

function tmeta:__tostring()
	return self.img
end

function tmod:add(img)
	if not self.img then return tmod:new(img) end
	img = tostring(img)
	if string_find(img, "%^") then
		return tmod:new(self.img .. "^(" .. img .. ")")
	else
		return tmod:new(self.img .. "^" .. img)
	end
end

local function esc(s)
	return string_gsub(string_gsub(tostring(s),
			"%^", "\\^"), ":", "\\:")
end

local function addmod(self, name)
	if self.img then
		return self.img .. "^[" .. name
	end
	return "[" .. name
end

local function simplemod(name, ...)
	local delims = {...}
	local lastdelim = delims[#delims]
	return function(self, ...)
		local s = addmod(self, name)
		local args = {...}
		for i = 1, #args do
			s = s .. (delims[i] or lastdelim) .. esc(args[i])
		end
		return tmod:new(s)
	end
end

for k in pairs({
		crack = true,
		cracko = true,
		opacity = true,
		invert = true,
		brighten = true,
		noalpha = true,
		lowpart = true,
		verticalframe = true,
		mask = true,
		colorize = true,
		multiply = true
	}) do
	tmod[k] = simplemod(k, ":")
end

tmod.resize = simplemod("resize", ":", "x")
tmod.makealpha = simplemod("makealpha", ":", ",")
tmod.transform = simplemod("transform", "")
tmod.sheet = simplemod("sheet", ":", "x", ":", ",")

function tmod:inventorycube(...)
	local s = addmod(self, "inventorycube")
	for _, arg in pairs({...}) do
		s = s .. "{" .. string_gsub(tostring(arg), "%^", "&")
	end
	return tmod:new(s)
end

tmod.combine = simplemod("combine", ":", "x")
function tmod:layer(x, y, img)
	return tmod:new((self.img or "") .. ":" .. esc(x) .. ","
		.. esc(y) .. "=" .. esc(img))
end
