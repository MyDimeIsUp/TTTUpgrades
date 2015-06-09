
-- Number of upgrades you can have at once
UConfig.DefaultUpgrades = 5

-- Upgrades number for specific ranks, example (if the rank is "rank")
UConfig.Upgrades["superadmin"] = 3

-- Use a whitelist to only allow specific ranks to use the upgrades system
UConfig.Whitelist = false
UConfig.AllowedRanks = {
	"admin",
	"superadmin",
	"owner",
	"donator"
}
UConfig.Whitelist_ErrorMessage = "You are not allowed to use the upgrades system!"

-- if you have a custom pointshop skin, set this to true. You will have to press a F-key to open it
UConfig.StandaloneMenu = true
UConfig.StandaloneMenuKey = KEY_F6