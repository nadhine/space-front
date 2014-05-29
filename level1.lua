-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5
local numBullets = 99999999999

function shoot(event)
	
	if (numBullets ~= 0) then
		numBullets = numBullets - 1
		local bullet = display.newImage("/images/tiro1.png")
		physics.addBody(bullet, "static", {density = 1, friction = 0, bounce = 0});
		bullet.x = ship.x 
		bullet.y = ship.y 
		bullet.myName = "bullet"
		transition.to ( bullet, { time = 1000, x = ship.x, y =-100} )
		audio.play(shot)
	end 
	
end

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view
	-- display a background image
	local background = display.newImage( "/images/fundo1.png")
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = 0, 0
	background:setFillColor( .5 )
	
	-- make a meteoro (off-screen), position it, and rotate slightly
	local meteoro = display.newImage( "/images/meteoro1.png")
	meteoro.x, meteoro.y = 160, -100
	meteoro.rotation = 15
	
	-- add physics to the meteoro
	physics.addBody( meteoro, { density=1.0, friction=0.3, bounce=0.3 } )
	
	-- create a botao object and add physics (with custom shape)
	local botao = display.newImageRect( "/images/botao.png", 80, 80 )
	botao.anchorX = 200
	botao.anchorY = 400
	botao.x, botao.y = 200, 0
	
	-- make a nave (off-screen), position it
	local nave1 = display.newImage( "/images/nave1.png")
	nave1.x, nave1.y = 40, 100
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( botao)
	sceneGroup:insert( meteoro )
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		physics.start()
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	
	package.loaded[physics] = nil
	physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene