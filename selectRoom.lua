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
print( "selectRoom.lua has been loaded." )

----back to menu
local function menuBtnRelease()
	print( "menubtn" )
	-- go to about.lua scene
	composer.gotoScene( "menu", "fade", 500 )
	print( "go to menu" )
	
	return true	-- indicates successful touch
end
---restart game
local function onPlayBtnRelease()
	composer.gotoScene( "level1multi", "fade", 50  )
	return true	-- indicates successful touch
end
-- Handle press events for the checkbox
local function onSwitchPress( event )
    local switch = event.target
    print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )
end


-- "scene:create()"
function scene:create( event )
	print( "1: create scene selectRoom" )
	local sceneGroup = self.view
	-- display a background image
	local background = display.newImageRect( "images/background1.png", display.contentWidth, display.contentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = 0, 0

	local gameoverText = display.newText("Selecione sua sala: ", 0, 0, nil, 20)
		gameoverText.x = 100
		gameoverText.y = 100
		sceneGroup:insert(gameoverText)
		
	local menuBtn = widget.newButton{
		labelColor = { default={255}, over={128} },
		defaultFile="images/menubtn.png",
		overFile="images/menubtnover.png",
		width=154, height=40,
		onRelease = menuBtnRelease	-- event listener function
		}
		menuBtn.x =  380
		menuBtn.y =  130
		
	local playBtn = widget.newButton{
		labelColor = { default={255}, over={128} },
		defaultFile="images/playbtn.png",
		overFile="images/playbtnover.png",
		width=154, height=40,
		onRelease = onPlayBtnRelease	-- event listener function
	}
		playBtn.x =  380
		playBtn.y =  190
		

		local checkboxBtn = widget.newSwitch{
			left = 240,
			top = 350,
			style = "checkbox",
			id = "Checkbox",
			onPress = onSwitchPress
		}
		checkboxBtn.text = display.newEmbossedText( tostring( checkboxBtn.isOn ), 0, 0, native.systemFontBold, 18 )
		checkboxBtn.text.x = checkboxBtn.x
		checkboxBtn.text.y = checkboxBtn.y - checkboxBtn.text.contentHeight
		
		-- all display objects must be inserted into group
		sceneGroup:insert( background )
		sceneGroup:insert( gameoverText )
		sceneGroup:insert( menuBtn )
		sceneGroup:insert( playBtn )
		sceneGroup:insert( checkboxBtn )
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