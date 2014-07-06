-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"
local globals = require( "globals" )

--------------------------------------------

-- forward declarations and other locals
local playBtn
local level = globals.fase
local backgroundsnd = audio.loadStream ( "audio/POL-evil-throne-short.wav")

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	
	-- go to level1.lua scene
	composer.gotoScene( "level1", "fade", 500 )
	
	return true	-- indicates successful touch
end

local function multiPlayBtnRelease()
	-- go to level1multi.lua scene
	composer.gotoScene( "selectRoom", "fade", 500 )
	
	return true	-- indicates successful touch
end

local function aboutBtnRelease()
	
	-- go to about.lua scene
	composer.gotoScene( "about", "fade", 500 )
	
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
	
	audio.play (backgroundsnd, { loops = 1})
	audio.setVolume(0.1, {backgroundsnd} )
	
	-- create a widget button (which will loads level1.lua on release)
	playBtn = widget.newButton{
		labelColor = { default={255}, over={128} },
		defaultFile="images/playbtn.png",
		overFile="images/playbtnover.png",
		width=154, height=40,
		onRelease = onPlayBtnRelease	-- event listener function
	}
	playBtn.x = 100
	playBtn.y = 200
	
	multiPlayBtn = widget.newButton{
	labelColor = { default={255}, over={128} },
	defaultFile="images/2playersbtn.png",
	overFile="images/2playersbtnover.png",
	width=154, height=40,
	onRelease = multiPlayBtnRelease	-- event listener function
	}
	multiPlayBtn.x =  100
	multiPlayBtn.y =  270
	
	aboutBtn = widget.newButton{
	labelColor = { default={255}, over={128} },
	defaultFile="images/about.png",
	overFile="images/about.png",
	width=200, height=147,
	onRelease = aboutBtnRelease	-- event listener function
	}
	aboutBtn.x =  380
	aboutBtn.y =  200
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( titleLogo )
	sceneGroup:insert( playBtn )
	sceneGroup:insert(multiPlayBtn)
	sceneGroup:insert(aboutBtn)
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
		audio.play (backgroundsnd, { loops = 1})
		sceneGroup.isVisible = true
		composer.removeScene( "about" )
		composer.removeScene( "selectRoom" )
		composer.removeScene( level )
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.
		audio.stop()
		sceneGroup.isVisible = false
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
end

function scene:destroy( event )
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc
	print( "((destroying scene 1's view))" )
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene