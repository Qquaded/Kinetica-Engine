local Vector3 = require("./Vector3")

local CFrame = {}
CFrame.__index = CFrame

local function mulRotation(a, b)
	local r = {}
	for i = 1, 3 do
		r[i] = {}
		for j = 1, 3 do
			r[i][j] = a[i][1] * b[1][j] + a[i][2] * b[2][j] + a[i][3] * b[3][j]
		end
	end
	return r
end

function CFrame.new(...)
	local args = { ... }
	local self = setmetatable({}, CFrame)

	self.Rotation = {
		{ 1, 0, 0 },
		{ 0, 1, 0 },
		{ 0, 0, 1 },
	}

	if #args == 1 then
		self.Position = args[1]
	elseif #args == 3 then
		self.Position = Vector3.new(args[1], args[2], args[3])
	elseif #args == 2 then
		local pos, target = args[1], args[2]
		local z = (pos - target)
		local zmag = math.sqrt(z.X ^ 2 + z.Y ^ 2 + z.Z ^ 2)
		z = Vector3.new(z.X / zmag, z.Y / zmag, z.Z / zmag)
		local up = Vector3.new(0, 1, 0)
		local x = up:Cross(z)
		local xmag = math.sqrt(x.X ^ 2 + x.Y ^ 2 + x.Z ^ 2)
		x = Vector3.new(x.X / xmag, x.Y / xmag, x.Z / xmag)
		local y = z:Cross(x)
		self.Position = pos
		self.Rotation = {
			{ x.X, y.X, z.X },
			{ x.Y, y.Y, z.Y },
			{ x.Z, y.Z, z.Z },
		}
	elseif #args == 12 then
		self.Position = Vector3.new(args[1], args[2], args[3])
		self.Rotation = {
			{ args[4], args[5], args[6] },
			{ args[7], args[8], args[9] },
			{ args[10], args[11], args[12] },
		}
	else
		error("Invalid CFrame.new arguments")
	end

	return self
end

function CFrame.__mul(a, b)
	local pos = a.Position
		+ Vector3.new(
			a.Rotation[1][1] * b.Position.X + a.Rotation[1][2] * b.Position.Y + a.Rotation[1][3] * b.Position.Z,
			a.Rotation[2][1] * b.Position.X + a.Rotation[2][2] * b.Position.Y + a.Rotation[2][3] * b.Position.Z,
			a.Rotation[3][1] * b.Position.X + a.Rotation[3][2] * b.Position.Y + a.Rotation[3][3] * b.Position.Z
		)
	local rot = mulRotation(a.Rotation, b.Rotation)
	local cf = CFrame.new(pos)
	cf.Rotation = rot
	return cf
end

function CFrame:Inverse()
	local rT = {}
	for i = 1, 3 do
		rT[i] = {}
		for j = 1, 3 do
			rT[i][j] = self.Rotation[j][i]
		end
	end
	local invPos = Vector3.new(
		-(rT[1][1] * self.Position.X + rT[1][2] * self.Position.Y + rT[1][3] * self.Position.Z),
		-(rT[2][1] * self.Position.X + rT[2][2] * self.Position.Y + rT[2][3] * self.Position.Z),
		-(rT[3][1] * self.Position.X + rT[3][2] * self.Position.Y + rT[3][3] * self.Position.Z)
	)
	local cf = CFrame.new(invPos)
	cf.Rotation = rT
	return cf
end

function CFrame:Lerp(target, alpha)
	local pos = Vector3.new(
		self.Position.X + (target.Position.X - self.Position.X) * alpha,
		self.Position.Y + (target.Position.Y - self.Position.Y) * alpha,
		self.Position.Z + (target.Position.Z - self.Position.Z) * alpha
	)
	local rot = {}
	for i = 1, 3 do
		rot[i] = {}
		for j = 1, 3 do
			rot[i][j] = self.Rotation[i][j] + (target.Rotation[i][j] - self.Rotation[i][j]) * alpha
		end
	end
	local cf = CFrame.new(pos)
	cf.Rotation = rot
	return cf
end

function CFrame:PointToWorldSpace(point)
	return self.Position
		+ Vector3.new(
			self.Rotation[1][1] * point.X + self.Rotation[1][2] * point.Y + self.Rotation[1][3] * point.Z,
			self.Rotation[2][1] * point.X + self.Rotation[2][2] * point.Y + self.Rotation[2][3] * point.Z,
			self.Rotation[3][1] * point.X + self.Rotation[3][2] * point.Y + self.Rotation[3][3] * point.Z
		)
end

function CFrame:ToWorldSpace(cf)
	return self * cf
end

function CFrame.lookAt(pos, target, up)
	up = up or Vector3.new(0, 1, 0)
	local z = (pos - target)
	local zmag = math.sqrt(z.X ^ 2 + z.Y ^ 2 + z.Z ^ 2)
	z = Vector3.new(z.X / zmag, z.Y / zmag, z.Z / zmag)
	local x = up:Cross(z)
	local xmag = math.sqrt(x.X ^ 2 + x.Y ^ 2 + x.Z ^ 2)
	x = Vector3.new(x.X / xmag, x.Y / xmag, x.Z / xmag)
	local y = z:Cross(x)
	local cf = CFrame.new(pos)
	cf.Rotation = {
		{ x.X, y.X, z.X },
		{ x.Y, y.Y, z.Y },
		{ x.Z, y.Z, z.Z },
	}
	return cf
end

function CFrame.Angles(x, y, z)
	local cx, sx = math.cos(x), math.sin(x)
	local cy, sy = math.cos(y), math.sin(y)
	local cz, sz = math.cos(z), math.sin(z)

	local rotX = {
		{ 1, 0, 0 },
		{ 0, cx, -sx },
		{ 0, sx, cx },
	}

	local rotY = {
		{ cy, 0, sy },
		{ 0, 1, 0 },
		{ -sy, 0, cy },
	}

	local rotZ = {
		{ cz, -sz, 0 },
		{ sz, cz, 0 },
		{ 0, 0, 1 },
	}

	local rot = mulRotation(rotZ, mulRotation(rotY, rotX))
	local cf = CFrame.new(Vector3.new(0, 0, 0))
	cf.Rotation = rot
	return cf
end

function CFrame:__tostring()
	return ("CFrame.new(%s, %s, %s)"):format(self.Position.X, self.Position.Y, self.Position.Z)
end

return CFrame
