-- devcell

local KineticaRaylib = game:GetService("KineticaRaylib")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local renderer = KineticaRaylib.renderer
local rl = KineticaRaylib.lib
local structs = KineticaRaylib.structs

local windowRegistry = {}

local window = require("@kinetica.rayguiwindow")(rl, structs)

local function create_window(title, frame)
	repeat
		task.wait()
	until frame.AbsolutePosition and frame.AbsoluteSize
	local myWindow = window.create({
		title = title,
		x = frame.AbsolutePosition.X,
		y = frame.AbsolutePosition.Y,
		width = frame.AbsoluteSize.X,
		height = frame.AbsoluteSize.Y,
	})
	return myWindow
end

local function create_window_back(screenGui, title, AnchorPoint, size)
	local frame = Instance.new("Frame")
	frame.Position = UDim2.new(AnchorPoint.X, 0, AnchorPoint.Y, 0)
	frame.AnchorPoint = AnchorPoint
	frame.Size = size or UDim2.new(0, 400, 0.5, 0)
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	frame.BackgroundTransparency = 0
	frame.Parent = screenGui

	return create_window(title, frame)
end

-- create explorer ingame
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Explorer"
screenGui.Parent = LocalPlayer.PlayerGui

local propback = create_window_back(screenGui, "Properties", Vector2.new(1, 1))
local explorerback = create_window_back(screenGui, "Explorer", Vector2.new(1, 0))
local outputback = create_window_back(screenGui, "Output", Vector2.new(0.5, 1), UDim2.new(1, 0, 0.08, 0))
local toolbar = create_window_back(screenGui, "toolbar", Vector2.new(0.5, 0), UDim2.new(1, 0, 0.1, 0))

local expanded = {}
local yOffset = 0
local selected = nil

local function DrawTree(instance, indent, winX, winY, winWidth)
	indent = indent or 0
	winX = winX or 0
	winY = winY or 0
	winWidth = winWidth or 350 -- fallback if not provided

	local children = instance:GetChildren()
	local hasChildren = #children > 0
	local isExpanded = expanded[instance]

	local nodeWidth = 330 -- width of the text button
	local nodeHeight = 22
	local padding = 10

	-- Node button (aligned to the right side)
	local btnX = winX + winWidth - nodeWidth - padding - (indent * -12)
	local btn = rl.GuiButton(
		structs.Rectangle:new({
			x = btnX,
			y = winY + 10 + yOffset,
			width = nodeWidth,
			height = nodeHeight,
		}),
		instance.Name
	)
	if btn == 1 then
		selected = instance
		print("Selected:", instance.Name)
	end

	-- Expand/collapse toggle (right of the node)
	if hasChildren then
		local toggleX = btnX + nodeWidth + 4 -- just a small offset to the right
		local toggle = rl.GuiButton(
			structs.Rectangle:new({
				x = toggleX,
				y = winY + 10 + yOffset,
				width = 20,
				height = nodeHeight,
			}),
			isExpanded and "▼" or "▶"
		)
		if toggle == 1 then
			expanded[instance] = not isExpanded
		end
	end

	yOffset = yOffset + nodeHeight + 2

	-- Recurse into children if expanded
	if isExpanded then
		for _, child in ipairs(children) do
			DrawTree(child, indent + 1, winX, winY, winWidth)
		end
	end
end

-- Update window.stepped for Explorer tree
window.stepped = function(windowData)
	if windowData.title == "Explorer" then
		yOffset = 0

		for _, child in ipairs(game.Root:GetChildren()) do
			DrawTree(child, 0, windowData.x, windowData.y + 20)
		end
	end
end

renderer.Add2DStack(function(data)
	window.update()

	window.draw()
end)
