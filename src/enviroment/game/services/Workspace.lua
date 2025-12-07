local Instance = require("@Instance")
local Vector3 = require("@Vector3")
local Workspace = Instance.new("Workspace")

local allowed_to_render = {
	["Part"] = "Part",
	["MeshPart"] = "MeshPart",
	["BasePart"] = "BasePart",
}

Workspace:SetProperties({
	Gravity = 196.2,
	GlobalWind = Vector3.new(0, 0, 0),
	FallenPartsDestroyHeight = 90,
	AirTurbulenceIntensity = 0,
	AirDensity = 0,
	StreamingEnabled = false,
})

local function loopRegister(v, renderer)
	local children = v:GetChildren()

	for _, child in pairs(children) do
		if allowed_to_render[child.ClassName] then
			renderer.AddToRegistry(function()
				return child
			end)
		end

		v.ChildAdded:Connect(function(child)
			if allowed_to_render[child.ClassName] then
				renderer.AddToRegistry(function()
					return child
				end)
			end
		end)

		if child.BaseClass and child.BaseClass == "kinetica.light" then
			renderer.AddToRegistry(function()
				return child
			end)
		end
	end

	if allowed_to_render[v.ClassName] then
		renderer.AddToRegistry(function()
			return v
		end)
	end
end

Workspace.InitRenderer = function(renderer, signal)
	signal:Connect(function(route, data) end)

	Workspace.ChildAdded:Connect(function(v)
		loopRegister(v, renderer)
	end)
end

return Workspace
