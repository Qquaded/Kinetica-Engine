local Color3 = {}
Color3.__index = Color3

local function clamp(v)
	if v < 0 then
		return 0
	end
	if v > 1 then
		return 1
	end
	return v
end

function Color3.new(r, g, b)
	return setmetatable({
		R = clamp(r or 0),
		G = clamp(g or 0),
		B = clamp(b or 0),
	}, Color3)
end

function Color3.fromRGB(r, g, b)
	return Color3.new(r / 255, g / 255, b / 255)
end

function Color3.fromHSV(h, s, v)
	h = h % 1
	s = math.max(0, math.min(1, s))
	v = math.max(0, math.min(1, v))

	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p = v * (1 - s)
	local q = v * (1 - f * s)
	local t = v * (1 - (1 - f) * s)

	local r, g, b
	i = i % 6
	if i == 0 then
		r, g, b = v, t, p
	elseif i == 1 then
		r, g, b = q, v, p
	elseif i == 2 then
		r, g, b = p, v, t
	elseif i == 3 then
		r, g, b = p, q, v
	elseif i == 4 then
		r, g, b = t, p, v
	elseif i == 5 then
		r, g, b = v, p, q
	end

	return Color3.new(r, g, b)
end

function Color3:ToRGB()
	return math.floor(self.R * 255 + 0.5), math.floor(self.G * 255 + 0.5), math.floor(self.B * 255 + 0.5)
end

function Color3:Lerp(other, alpha)
	return Color3.new(
		self.R + (other.R - self.R) * alpha,
		self.G + (other.G - self.G) * alpha,
		self.B + (other.B - self.B) * alpha
	)
end

function Color3:__tostring()
	return string.format("Color3(%g, %g, %g)", self.R, self.G, self.B)
end

function Color3.__add(a, b)
	return Color3.new(a.R + b.R, a.G + b.G, a.B + b.B)
end

function Color3.__sub(a, b)
	return Color3.new(a.R - b.R, a.G - b.G, a.B - b.B)
end

function Color3.__mul(a, b)
	if type(a) == "number" then
		return Color3.new(a * b.R, a * b.G, a * b.B)
	elseif type(b) == "number" then
		return Color3.new(a.R * b, a.G * b, a.B * b)
	end
	error("Color3 * Color3 is not supported (scalar only)")
end

function Color3.__div(a, b)
	if type(b) ~= "number" then
		error("Color3 division only supports scalar division")
	end
	return Color3.new(a.R / b, a.G / b, a.B / b)
end

function Color3.__unm(a)
	return Color3.new(-a.R, -a.G, -a.B)
end

return Color3
