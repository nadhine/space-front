module(..., package.seeall)
local createEnemies = require "createEnemies"

function stage1()
	local enemiespos = { {400,100},
						{800,200},
						{1200,300},
						{600,200},
						{700,300},
						{800,100},
						{1100,300},
						{1200,150},
						{3100,150},
						{3300,250},
						{4000,120}
	}
return enemiespos
end

function stage1b()
	local enemiespos = { {480,70},
						{350,150},
						{1650,300},
						{1600,150},
						{1000,320},
						{2500,100},
						{3000,200},
						{2200,250},
						{4200,250}
	}
return enemiespos
end

function stage2()
	local enemiespos = { {500,100},
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

function stage2b()
	local enemiespos = { {300,70},
						{350,150},
						{1650,300},
						{1600,150},
						{1000,300},
						{2500,100},
						{3000,200},
						{2200,250}
	}
return enemiespos
end


function stage2c()
	local enemiespos = { {650,150},
						{750,150},
						{2850,300},
						{950,150},
						{1500,300},
						{3500,100},
						{4000,200},
						{3200,250}
	}
return enemiespos
end