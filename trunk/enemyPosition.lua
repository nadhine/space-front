module(..., package.seeall)
local createEnemies = require "createEnemies"

function stage1()
	local enemiespos = { {200,100},
						{800,200},
						{1200,300},
						{600,200},
						{700,300},
						{800,100},
						{1100,300},
						{1200,150},
						{2000,50}
	}
return enemiespos
end

function stage1b()
	local enemiespos = { {300,50},
						{350,150},
						{1650,300},
						{1600,150},
						{1000,320},
						{2500,100},
						{3000,200},
						{2200,250}
	}
return enemiespos
end