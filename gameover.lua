local storyboard = require "storyboard"
local composer = require "composer"
local scene = composer.newScene()
local widget = require "widget"
local globals = require( "globals" )

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- local forward references should go here

-- -------------------------------------------------------------------------------
local level = globals.fase
print( "gameover.lua has been loaded." )

----back to menu
local function menuBtnRelease()
	print( "menubtn" )
	-- go to about.lua scene
	composer.gotoScene( "menu", "fade", 500 )
	print( "go to menu" )
	
	return true	-- indicates successful touch
end
---restart game
local function restartBtnRelease()
	-- go to gameover.lua scene
	composer.gotoScene( level, "fade", 50  )
	return true	-- indicates successful touch
end

-- "scene:create()"
function scene:create( event )
	print( "1: create scene gameover" )
	local sceneGroup = self.view
	-- display a background image
	local background = display.newImageRect( "images/background1.png", display.contentWidth, display.contentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = 0, 0

	local gameoverText = display.newText("Game Over!", 0, 0, nil, 35)
		gameoverText.x = display.contentCenterX
		gameoverText.y = display.contentCenterY
		sceneGroup:insert(gameoverText)
		
	local menuBtn = widget.newButton{
		labelColor = { default={255}, over={128} },
		defaultFile="images/menubtn.png",
		overFile="images/menubtnover.png",
		width=154, height=40,
		onRelease = menuBtnRelease	-- event listener function
		}
		menuBtn.x =  240
		menuBtn.y =  230
		
	local restartBtn = widget.newButton{
		labelColor = { default={255}, over={128} },
		defaultFile="images/restartbtn.png",
		overFile="images/restartbtnover.png",
		width=154, height=40,
		onRelease = restartBtnRelease	-- event listener function
		}
		restartBtn.x =  240
		restartBtn.y =  290
		
		-- all display objects must be inserted into group
		sceneGroup:insert( background )
		sceneGroup:insert( gameoverText )
		sceneGroup:insert( menuBtn )
		sceneGroup:insert( restartBtn )
end


-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
		composer.removeScene(level)
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene