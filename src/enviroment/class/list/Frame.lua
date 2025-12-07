local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local GuiObject = require("@GuiObject")
local Enum = require("@EnumMap")

local propTable = {}

GuiObject.inherit(propTable)
propTable.Name = "Frame"

return {
	class = "Frame",
	render = GuiObject.render,
	callback = function(instance, renderer)
		return GuiObject.callback(instance, renderer)
	end,
	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
