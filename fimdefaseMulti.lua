local storyboard = require "storyboard"
local composer = require "composer"
local scene = composer.newScene()
local widget = require "widget"
local globals = require( "globals" )
local vidas = require("lifes")
require ("multiplayerFunctions");
-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- local forward references should go here

-- -------------------------------------------------------------------------------

print( "fimdefaseMulti.lua has been loaded." )

local score = 0
local level = globals.fase
local gameIsActive = true

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
	-- go to fimdefase.lua scene
	composer.gotoScene( level, "fade", 50  )
	return true	-- indicates successful touch
end

local function maisVidaBtnRelease()
	-- go to fimdefase.lua scene
	if globals.score > 50 then
		globals.vida = globals.vida + 1
		globals.score = globals.score - 50
		local score = globals.score
		vidas.minhaVida()
	end
	return true	-- indicates successful touch
end

local function doacaoBtnRelease()
	-- go to fimdefase.lua scene
	if globals.score >  50 then
		globals.score = globals.score - 50
		
	end
	return true	-- indicates successful touch
end

local function handlerFunction( event )

    if ( event.phase == "began" ) then

        -- user begins editing text field
        print( event.text )
    end   
end

-- "scene:create()"
function scene:create( event )
	print( "1: create scene fimdefase" )
	local sceneGroup = self.view
	-- display a background image
	local background = display.newImageRect( "images/background1.png", display.contentWidth, display.contentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = 0, 0

	local gameoverText = display.newText("Fim de Fase!", 0, 0, nil, 35)
		gameoverText.x = display.contentCenterX
		gameoverText.y = display.contentCenterY - 120
		sceneGroup:insert(gameoverText)
		
	local score = globals.score
	local ptsText = display.newText(" Sua Pontuação: "..score, 0, 0, nil, 15)
		ptsText.x = 90
		ptsText.y = 100
		
	local ptsPLayer2Text = display.newText(" P2: "..score, 0, 0, nil, 15)
		ptsPLayer2Text.x = 90
		ptsPLayer2Text.y = 150
		
	local numericField = native.newTextField( 275, 150, 150, 40 )
		numericField.inputType = "number"
		numericField:addEventListener( "userInput", handlerFunction )	
		
	local maisVidaBtn = widget.newButton{
		labelColor = { default={255}, over={128} },
		defaultFile="images/maisVidaBtn.png",
		overFile="images/maisVidaBtn.png",
		width=150, height=40,
		onRelease = maisVidaBtnRelease	-- event listener function
		}
		maisVidaBtn.x =  275
		maisVidaBtn.y =  100
	
	local doacaoBtn = widget.newButton{
		labelColor = { default={255}, over={128} },
		defaultFile="images/doacaoBtn.png",
		overFile="images/doacaoBtn.png",
		width=20, height=40,
		onRelease = doacaoBtnRelease	-- event listener function
		}
		doacaoBtn.x =  numericField.x - 100
		doacaoBtn.y =  numericField.y
		
	local menuBtn = widget.newButton{
		labelColor = { default={255}, over={128} },
		defaultFile="images/menubtn.png",
		overFile="images/menubtnover.png",
		width=154, height=40,
		onRelease = menuBtnRelease	-- event listener function
		}
		menuBtn.x =  240
		menuBtn.y =  210
		
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
		sceneGroup:insert( ptsText)
		sceneGroup:insert( menuBtn )
		sceneGroup:insert( restartBtn )
		sceneGroup:insert( maisVidaBtn )
		sceneGroup:insert( doacaoBtn )
		sceneGroup:insert( numericField )
		
	-- local function gameLoop(event)
		-- if gameIsActive then
			-- if handlerFunction then
				-- sendMessage()
			-- end
		-- end
	-- end
		-- Runtime:addEventListener("enterFrame", gameLoop)
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
		composer.removeScene( level )
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