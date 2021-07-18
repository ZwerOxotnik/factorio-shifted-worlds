
if script.level.campaign_name then return end -- Don't init if it's a campaign
if script.level.level_name == "sandbox" then return end -- Don't init if it's "sandbox" scenario
if script.level.level_name == "pvp" then return end
if script.level.level_name == "team-production" then return end
if script.level.level_name == "rocket-rush" then return end
if script.level.level_name == "wave-defence" then return end


local event_handler = require("event_handler")


MOD_PATH = "__shifted-worlds__"
MOD_SHORT_NAME = "SWs"


---@type table<string, module>
local modules = {}
modules.better_commands = require("models/BetterCommands/control")
modules.shifted_worlds = require("models/shifted-worlds/control")
-- modules.empty_module = require("models.empty-module")


-- Safe disabling of this mod remotely on init stage
-- Useful for other map developers and in some rare cases for mod devs
if script.level.mod_name and remote.interfaces["disable-" .. script.level.mod_name] then
	for _, module in pairs(modules) do
		local update_global_data_on_disabling = module.update_global_data_on_disabling
		module.events = nil
		module.on_nth_tick = nil
		module.commands = nil
		module.on_load = nil
		module.add_remote_interface = nil
		module.add_commands = nil
		module.on_configuration_changed = update_global_data_on_disabling
		module.on_init = update_global_data_on_disabling
	end
else
	modules.better_commands:handle_custom_commands(modules.shifted_worlds) -- adds commands
end


event_handler.add_libraries(modules)
