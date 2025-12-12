-- devcell

local KinemiumRaylib = game:GetService("KinemiumRaylib")
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")
local KinemiumFontService = game:GetService("KinemiumFontService")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local renderer = KinemiumRaylib.renderer
local rl = KinemiumRaylib.lib
local Selection = game:GetService("Selection")
local LogService = game:GetService("LogService")
local structs = KinemiumRaylib.structs
local vend = KinemiumFontService.GetDefaultFont()

if game.Context ~= Enum.GameContext.Editor then
	return
end

print("This is viewport.")

KinemiumIconLoader.new("Add", "./src/assets/images/icons/vanilla3/ui/16x/200/Add.png")

local png = KinemiumIconLoader.Get("Add")
local addIcon = KinemiumIconLoader.ToTexture(png)

local windowRegistry = {}

local aereon = import("@Kinemium.Aereon")
local window = aereon.window(game, nil, 1)

local blacklisted = {
	"Children",
}

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
	frame.BackgroundTransparency = 1
	frame.Parent = screenGui

	return frame
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Output"
screenGui.Parent = LocalPlayer.PlayerGui

local frame = create_window_back(screenGui, "Output", Vector2.new(0, 0.5), UDim2.new(0.78, 0, 0.75, 0))

local function Color3ToRaylib(c, transparency)
	local r, g, b = c:ToRGB()
	return structs.Color:new({
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - transparency)),
	})
end

task.wait(2)
renderer.renderSceneCallbackSet(function(texture, lib, size)
	lib.DrawTexturePro(
		texture,
		structs.Rectangle:new({ x = 0, y = 0, width = size.x, height = -size.y }),
		structs.Rectangle:new({
			x = frame.AbsolutePosition.X,
			y = frame.AbsolutePosition.Y,
			width = frame.AbsoluteSize.X,
			height = frame.AbsoluteSize.Y,
		}),
		vector.create(0, 0, 0),
		0,
		KinemiumRaylib.const.WHITE
	)
end)
