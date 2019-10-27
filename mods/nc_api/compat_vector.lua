-- LUALOCALS < ---------------------------------------------------------
local math, vector
    = math, vector
local math_atan2
    = math.atan2
-- LUALOCALS > ---------------------------------------------------------

vector.dot = vector.dot or function(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z
end

vector.cross = vector.cross or function(a, b)
	return {
		x = a.y * b.z - a.z * b.y,
		y = a.z * b.x - a.x * b.z,
		z = a.x * b.y - a.y * b.x
	}
end

vector.angle = vector.angle or function(a, b)
	return math_atan2(vector.length(vector.cross(a, b)), vector.dot(a, b))
end
