module(..., package.seeall)
local globals = require( "globals" )

local vida1 =  display.newImageRect( "images/life.png",20,15)
vida1.x = 25
vida1.y = 25
vida1.id = 1
local vida2 =  display.newImageRect( "images/life.png",20,15)
vida2.x = 50
vida2.y = 25
vida2.id = 2
local vida3 =  display.newImageRect( "images/life.png",20,15)
vida3.x = 75
vida3.y = 25
vida3.id = 3
local vida4 =  display.newImageRect( "images/life.png",20,15)
vida4.x = 100
vida4.y = 25
vida4.id = 4
local vida5 =  display.newImageRect( "images/life.png",20,15)
vida5.x = 125
vida5.y = 25
vida5.id = 5
local vida6 =  display.newImageRect( "images/life.png",20,15)
vida6.x = 150
vida6.y = 25
vida6.id = 6
local vida7 =  display.newImageRect( "images/life.png",20,15)
vida7.x = 175
vida7.y = 25
vida7.id = 7

vidas = {vida1,vida2,vida3,vida4,vida5,vida6,vida7}


function minhaVida()
	for i = 1,(table.getn(vidas)) do
		vida = (vidas[i])
		if vida.id > globals.vida then
			vida.isVisible = false
		else 
			vida.isVisible = true
		end
	end
end

