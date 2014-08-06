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
	print( "1: create scene about" )
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
	hsText = display.newText(" High Scores:", 0, 0, nil, 15)
	hsText.x = 200
	hsText.y = 150
		
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
	sceneGroup:insert( hsText )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		print( "1: show event, phase will about" )
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		print( "1: show event, phase did about" )
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		sceneGroup.isVisible = true
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	audio.stop()
	sceneGroup.isVisible = false
	print( "hide event about" )
end

function scene:destroy( event )
	print( "((destroying about view))" )
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene