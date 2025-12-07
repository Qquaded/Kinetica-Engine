local Instance = require("@Instance")
local signal = require("@kinetica.signal")
local StarterGui = require("@StarterGui")
local Workspace = require("@Workspace")
local Enum = require("@EnumMap")
local Mouse = require("@Mouse")
local Player = require("@Player")

local Players = Instance.new("Players")

Players.PlayerAdded = signal.new()
Players.PlayerRemoving = signal.new()

local playerRegistry = {}
Players.Players = playerRegistry

local function CreatePlayer(name, userId): Instance
	local player = Instance.new("Player")
	player.Name = name
	player.UserId = userId

	local changed = Player.callback(player)

	return changed
end

function Players:AddPlayer(name, userId)
	local player = CreatePlayer(name, userId)
	table.insert(playerRegistry, player)
	self.PlayerAdded:Fire(player)
	return player
end

function Players:RemovePlayer(player)
	for i, p in ipairs(playerRegistry) do
		if p == player then
			table.remove(playerRegistry, i)
			break
		end
	end
	self.PlayerRemoving:Fire(player)
end

function Players:GetPlayerByName(name)
	for _, p in ipairs(playerRegistry) do
		if p.Name == name then
			return p
		end
	end
end

function Players:GetPlayerByUserId(userId)
	for _, p in ipairs(playerRegistry) do
		if p.UserId == userId then
			return p
		end
	end
end

-- client
Players.LocalPlayer = nil
Players.SetupClient = true

StarterGui.InitRenderer = function(renderer, signal, starterGui)
	local lib = renderer.lib
	if Players.SetupClient == true then
		-- create with default player name & id
		Players.LocalPlayer = CreatePlayer("Player1", 1)

		Players.LocalPlayer:SetProperties({
			GetMouse = function(self)
				local mouse_instance = Instance.new("Mouse")
				return Mouse.callback(mouse_instance, renderer)
			end,
		})
	end
end

return Players
