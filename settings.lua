data:extend({
	{
		type = "int-setting",
		name = "shifted_worlds-teleportation_time",
		setting_type = "runtime-global",
		default_value = 45,
		minimum_value = 1,
		maximum_value = 360
	}, {
		type = "int-setting",
		name = "shifted_worlds_count",
		setting_type = "runtime-global",
		default_value = 2,
		minimum_value = 2,
		maximum_value = 20
	}, {
		type = "int-setting",
		name = "shifted_worlds-scan-radius",
		setting_type = "runtime-global",
		default_value = 10,
		minimum_value = 0,
		maximum_value = 40
	}, {
		type = "int-setting",
		name = "shifted_worlds-clear-radius",
		setting_type = "runtime-global",
		default_value = 10,
		minimum_value = 0,
		maximum_value = 40
	}, {
		type = "bool-setting",
		name = "shifted_worlds-auto-teleportation",
		setting_type = "runtime-global",
		default_value = true
	}, {
		type = "bool-setting",
		name = "shifted_worlds-auto-save",
		setting_type = "runtime-global",
		default_value = false
	}, {
		type = "bool-setting",
		name = "shifted_worlds-teleport-after-death",
		setting_type = "runtime-global",
		default_value = false
	}
})
