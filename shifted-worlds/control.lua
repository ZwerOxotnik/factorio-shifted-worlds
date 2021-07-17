--[[
Copyright 2020, 2021 ZwerOxotnik <zweroxotnik@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]--

-- TODO: Fix when shifted_worlds_count is less than generated
-- TODO: Add random teleportation in the settings
-- TODO: Add endless mode in the settings (maybe)
-- TODO: Add a timer gui

local M = {}


local ceil = math.ceil


--#region Global data
local shifted_worlds
--#endregion


local setting = settings.global["shifted_worlds-teleportation_time"]
local teleportation_time = (setting and setting.value) or 45 -- minutes
setting = settings.global["shifted_worlds_count"]
local max_worlds_count = (setting and setting.value) or 2
setting = nil


--#region Util

local function create_new_world()
	local settings = game.surfaces[1].map_gen_settings
	settings.seed = math.random(0, 4294967295)
	shifted_worlds.generated_world_count = shifted_worlds.generated_world_count + 1
	local surface_name = "shifted_world_" .. shifted_worlds.generated_world_count
	local new_surface = game.create_surface(surface_name, settings)
	local worlds = shifted_worlds.worlds
	worlds[#worlds+1] = new_surface.index
	return new_surface
end

local function teleport_players()
	local next_surface
	local worlds = shifted_worlds.worlds
	if #worlds < max_worlds_count then
		next_surface = create_new_world()
	else
		next_surface = game.surfaces[worlds[1]]
		local surface_id = table.remove(worlds, 1)
		worlds[#worlds+1] = surface_id
	end

	for _, player in pairs(game.connected_players) do
		local non_colliding_position
		if player.character then
			non_colliding_position = next_surface.find_non_colliding_position(player.character.name, player.position, 1000, 1) or next_surface.find_non_colliding_position(player.character.name, {0, 0}, 1000, 1)
			-- if non_colliding_position == nil then return end -- oh, a bug, sorta
		end
		player.print({"shifted-worlds.player-were-teleported"})
		player.teleport(non_colliding_position or player.position, next_surface)
	end
end

--#endregion


--#region Functions of events

local function on_runtime_mod_setting_changed(event)
	if event.setting_type ~= "runtime-global" then return end

	if event.setting == "shifted_worlds-teleportation_time" then
		teleportation_time = settings.global[event.setting].value
	elseif event.setting == "shifted_worlds_count" then
		max_worlds_count = settings.global[event.setting].value
	end
end

local function on_player_joined_game(event)
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end

	local worlds = shifted_worlds.worlds
	if player.surface.index == worlds[1] then return end

	local target_surface = game.surfaces[worlds[1]]
	local surface_id = table.remove(worlds, 1)
	worlds[#worlds+1] = surface_id

	local non_colliding_position
	if player.character then
		local entity_name = player.character.name
		non_colliding_position = target_surface.find_non_colliding_position(entity_name, player.position, 1000, 1) or target_surface.find_non_colliding_position(entity_name, {0, 0}, 1000, 1)
		if non_colliding_position == nil then return end -- it's a bug, sorta
	end

	player.teleport(non_colliding_position or player.position, target_surface)
end

local function check_teleportation(event)
	if event.tick < 60 then
		return
	end

	local ticks_till_teleportation = shifted_worlds.next_teleportation_tick - event.tick
	if ticks_till_teleportation > 0 then
		local minutes = ceil(ticks_till_teleportation / (3600 * game.speed))
		if minutes < 5 or minutes % 10 == 0 then
			game.print({"shifted-worlds.reminder", minutes})
		end
		return
	else
		shifted_worlds.next_teleportation_tick = shifted_worlds.next_teleportation_tick + (3600 * game.speed * teleportation_time)
		teleport_players()
	end
end

--#endregion


--#region Pre-game stage

local function link_data()
	shifted_worlds = global.shifted_worlds
end

local function update_global_data()
	global.shifted_worlds = global.shifted_worlds or {}
	local data = global.shifted_worlds
	data.next_teleportation_tick = data.next_teleportation_tick or (3600 * game.speed * teleportation_time)
	data.worlds = data.worlds or {1}
	data.generated_world_count = 0

	link_data()
end


M.on_init = update_global_data
M.on_configuration_changed = update_global_data
M.on_load = link_data

--#endregion


M.events = {
	[defines.events.on_player_joined_game] = on_player_joined_game,
	[defines.events.on_runtime_mod_setting_changed] = on_runtime_mod_setting_changed
}
M.on_nth_tick = {
	[3600] = check_teleportation
}


return M
