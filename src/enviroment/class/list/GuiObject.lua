local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")
local UDim2 = require("@UDim2")
local UDim = require("@UDim")
local signal = require("@kinetica.signal")
local Vector2 = require("@Vector2")

local segments = 16

local function GetAbsoluteSize(object, lib)
	if object:IsA("ScreenGui") then
		return Vector2.new(lib.GetRenderWidth(), lib.GetRenderHeight())
	else
		return object.Size:ToPixels(GetAbsoluteSize(object.Parent, lib))
	end
end

local function getAbsoluteDrawPos(object, lib)
	if object:IsA("ScreenGui") then
		return Vector2.new(0, 0)
	end
	local parent = object.Parent
	local parentAbsPos = getAbsoluteDrawPos(parent, lib)
	local parentSize = GetAbsoluteSize(parent, lib)
	local pos = object.Position:ToPixels(parentSize)
	local size = object.Size:ToPixels(parentSize)
	local anchor = object.AnchorPoint or Vector2.new(0, 0)
	return Vector2.new(parentAbsPos.X + pos.X - size.X * anchor.X, parentAbsPos.Y + pos.Y - size.Y * anchor.Y)
end

local function IsMouseInGuiRecursive(object, mousePos, lib)
	local function isMouseInside(obj)
		local size = obj.Size:ToPixels(GetAbsoluteSize(obj.Parent, lib))
		local drawPos = getAbsoluteDrawPos(obj, lib)

		return mousePos.X >= drawPos.X
			and mousePos.X <= drawPos.X + size.X
			and mousePos.Y >= drawPos.Y
			and mousePos.Y <= drawPos.Y + size.Y
	end

	if isMouseInside(object) then
		return true
	end

	if object.GetChildren then
		for _, child in ipairs(object:GetChildren()) do
			if not child.Position then
				continue
			end
			if IsMouseInGuiRecursive(child, mousePos, lib) then
				return true
			end
		end
	end

	return false
end

local propTable = {
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(0, 100, 0, 100),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0,
	Visible = true,
	BorderSize = 0,
	BorderColor = Color3.new(0, 0, 0),
	BorderTransparency = 0,
	Rotation = 0,
	ClipsDescendants = false,
	ZIndex = 1,
	AnchorPoint = Vector2.new(0, 0),
	Name = "KineticaGui",
	MouseIsInObject = false,

	render = function(lib, object, dt, structs, renderer)
		if not object.Visible then
			return
		end
		local function Color3ToRaylib(c, transparency)
			local r, g, b = c:ToRGB()
			return structs.Color:new({
				r = r,
				g = g,
				b = b,
				a = math.floor(255 * (1 - transparency)),
			})
		end

		local mousePos = Vector2.new(lib.GetMouseX(), lib.GetMouseY())
		object.MouseIsInObject = IsMouseInGuiRecursive(object, mousePos, lib)
		object.MouseEnter:FireOncePerPress("MouseEnter", object.MouseIsInObject)
		object.MouseLeave:FireOncePerPress("MouseLeave", not object.MouseIsInObject)

		local parent = object.Parent

		local color = Color3ToRaylib(object.BackgroundColor3, object.BackgroundTransparency)

		local parentSize = GetAbsoluteSize(object.Parent, lib)
		local size, anchor, drawPos

		if object._LayoutControlled and object._LayoutRelativePosition then
			size = object.Size:ToPixels(parentSize)
			anchor = object.AnchorPoint or Vector2.new(0, 0)

			local parentDrawPos = getAbsoluteDrawPos(object.Parent, lib)

			drawPos = Vector2.new(
				parentDrawPos.X + object._LayoutRelativePosition.X - size.X * anchor.X,
				parentDrawPos.Y + object._LayoutRelativePosition.Y - size.Y * anchor.Y
			)
		else
			size = object.Size:ToPixels(parentSize)
			anchor = object.AnchorPoint or Vector2.new(0, 0)
			drawPos = getAbsoluteDrawPos(object, lib)
		end

		local corner = object:FindFirstChildOfClass("UICorner")
		local stroke = object:FindFirstChildOfClass("UIStroke")
		local gradient = object:FindFirstChildOfClass("UIGradient")

		local rec = structs.Rectangle:new({ x = drawPos.X, y = drawPos.Y, width = size.X, height = size.Y })

		local origin = vector.create(0, 0)

		if corner then
			local minDim = math.min(size.X, size.Y)
			local cornerRadius = corner.CornerRadius.Scale * minDim + corner.CornerRadius.Offset
			local roundness = cornerRadius / minDim

			if object.Rotation ~= 0 then
				lib.DrawRectanglePro(rec, origin, object.Rotation, color)
			else
				lib.DrawRectangleRounded(rec, roundness, segments, color)
			end

			if stroke then
				if object.Rotation ~= 0 then
					lib.DrawRectangleLinesEx(rec, stroke.Thickness, Color3ToRaylib(stroke.Color, stroke.Transparency))
				else
					lib.DrawRectangleRoundedLinesEx(
						rec,
						roundness,
						segments,
						stroke.Thickness,
						Color3ToRaylib(stroke.Color, stroke.Transparency)
					)
				end
			end
		elseif gradient then
			local steps = 50
			local minDim = math.min(size.X, size.Y)
			local cornerRadius = 0
			if corner then
				cornerRadius = corner.CornerRadius.Scale * minDim + corner.CornerRadius.Offset
			end

			local stepHeight = size.Y / steps

			for i = 0, steps - 1 do
				local t1 = i / steps
				local t2 = (i + 1) / steps
				local color1 = gradient.ColorSequence:Evaluate(t1)
				local color2 = gradient.ColorSequence:Evaluate(t2)

				local offsetLeft, offsetRight = 0, 0
				if cornerRadius > 0 then
					if i * stepHeight < cornerRadius then
						local ratio = (cornerRadius - i * stepHeight) / cornerRadius
						offsetLeft = cornerRadius * (1 - math.sqrt(1 - ratio ^ 2))
						offsetRight = offsetLeft
					end
					if (i + 1) * stepHeight > (size.Y - cornerRadius) then
						local ratio = ((i + 1) * stepHeight - (size.Y - cornerRadius)) / cornerRadius
						local bottomOffset = cornerRadius * (1 - math.sqrt(1 - ratio ^ 2))
						offsetLeft = math.max(offsetLeft, bottomOffset)
						offsetRight = math.max(offsetRight, bottomOffset)
					end
				end

				local sliceRec = structs.Rectangle:new({
					x = drawPos.X + offsetLeft,
					y = drawPos.Y + i * stepHeight,
					width = size.X - offsetLeft - offsetRight,
					height = stepHeight,
				})

				lib.DrawRectangleGradientEx(
					sliceRec,
					Color3ToRaylib(color1, 0),
					Color3ToRaylib(color1, 0),
					Color3ToRaylib(color2, 0),
					Color3ToRaylib(color2, 0)
				)
			end

			if stroke then
				if corner then
					local roundness = (cornerRadius / minDim) or 0

					lib.DrawRectangleRoundedLinesEx(
						rec,
						roundness,
						segments,
						stroke.Thickness,
						Color3ToRaylib(stroke.Color, stroke.Transparency)
					)
				else
					lib.DrawRectangleLinesEx(rec, stroke.Thickness, Color3ToRaylib(stroke.Color, stroke.Transparency))
				end
			end
		elseif stroke and not corner then
			if object.Rotation ~= 0 then
				lib.DrawRectanglePro(rec, origin, object.Rotation, color)
				lib.DrawRectangleLinesEx(rec, stroke.Thickness, Color3ToRaylib(stroke.Color, stroke.Transparency))
			else
				lib.DrawRectangleRec(rec, color)
				lib.DrawRectangleLinesEx(rec, stroke.Thickness, Color3ToRaylib(stroke.Color, stroke.Transparency))
			end
		else
			lib.DrawRectanglePro(rec, origin, object.Rotation, color)
		end

		if object.ClipsDescendants == true then
			lib.BeginScissorMode(drawPos.X, drawPos.Y, size.X, size.Y)
		end

		for _, child in pairs(object:GetChildren()) do
			if child.render then
				child.render(lib, child, dt, structs, renderer)
			end
		end

		if object.ClipsDescendants == true then
			lib.EndScissorMode()
		end

		object.AbsolutePosition = drawPos
		object.AbsoluteSize = size

		return drawPos, size
	end,
}

return {
	class = "GuiObject",
	non_creatable = true,
	render = propTable.render,
	callback = function(instance, renderer)
		local MouseEnter = signal.new()
		local MouseLeave = signal.new()
		local MouseMoved = signal.new()
		local MouseWheelForward = signal.new()
		local MouseWheelBackward = signal.new()
		local TouchTap = signal.new()
		local TouchLongPress = signal.new()
		local InputBegan = signal.new()
		local InputChanged = signal.new()
		local InputEnded = signal.new()

		propTable.MouseEnter = MouseEnter
		propTable.MouseLeave = MouseLeave
		propTable.MouseMoved = MouseMoved
		propTable.MouseWheelForward = MouseWheelForward
		propTable.MouseWheelBackward = MouseWheelBackward
		propTable.TouchTap = TouchTap
		propTable.TouchLongPress = TouchLongPress
		propTable.InputBegan = InputBegan
		propTable.InputChanged = InputChanged
		propTable.InputEnded = InputEnded

		instance:SetProperties(propTable)

		return instance
	end,
	inherit = function(tble)
		local MouseEnter = signal.new()
		local MouseLeave = signal.new()
		local MouseMoved = signal.new()
		local MouseWheelForward = signal.new()
		local MouseWheelBackward = signal.new()
		local TouchTap = signal.new()
		local TouchLongPress = signal.new()
		local InputBegan = signal.new()
		local InputChanged = signal.new()
		local InputEnded = signal.new()

		tble.MouseEnter = MouseEnter
		tble.MouseLeave = MouseLeave
		tble.MouseMoved = MouseMoved
		tble.MouseWheelForward = MouseWheelForward
		tble.MouseWheelBackward = MouseWheelBackward
		tble.TouchTap = TouchTap
		tble.TouchLongPress = TouchLongPress
		tble.InputBegan = InputBegan
		tble.InputChanged = InputChanged
		tble.InputEnded = InputEnded

		for prop, val in pairs(propTable) do
			if tble[prop] then
				continue
			end
			tble[prop] = val
		end
	end,
}
