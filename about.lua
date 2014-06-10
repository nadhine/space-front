local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"

---------
local function backBtnRelease()
	
	-- go to about.lua scene
	composer.gotoScene( "menu", "fade", 500 )
	
	return true	-- indicates successful touch
end

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	local background = display.newImageRect( "images/background1.png", display.contentWidth, display.contentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = 0, 0
	
	-- create/position logo/title image on upper-half of the screen
	local titleLogo = display.newImageRect( "images/logo.png", 264, 42 )
	titleLogo.x = display.contentWidth * 0.5
	titleLogo.y = 100
	aboutText = display.newText(" O jogo se passa em 2045 em um tempo de muita evolução tecnológica", 0, 0, nil, 12)
	aboutText.x = 200
	aboutText.y = 250
	
	audio.play (backgroundsnd, { loops = 1})
	audio.setVolume(0.1, {backgroundsnd} )
	
	
	backBtn = widget.newButton{
	labelColor = { default={255}, over={128} },
	defaultFile="images/menubtn.png",
	overFile="images/menubtnover.png",
	width=154, height=40,
	onRelease = backBtnRelease	-- event listener function
	}
	backBtn.x =  380
	backBtn.y =  200
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( titleLogo )
	sceneGroup:insert( backBtn )
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
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	audio.stop()
	if aboutText then
		aboutText:removeSelf()
		aboutText = nil
	end
	if backBtn then
		backBtn:removeSelf()	-- widgets must be manually removed
		backBtn = nil
	end
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	audio.stop()
	if aboutText then
		aboutText:removeSelf()
		aboutText = nil
	end
	if backBtn then
		backBtn:removeSelf()	-- widgets must be manually removed
		backBtn = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene