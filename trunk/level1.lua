-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local backgroundsnd = audio.loadStream ( "audio/bgMusic.mp3")

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()
physics.setGravity(-5, 0)
--------------------------------------------


function scene:create( event )
-- Hide status bar, so it won't keep covering our game objects

-- A heavier gravity, so enemies planes fall faster
-- !! Note: there are a thousand better ways of doing the enemies movement,
-- but I'm going with gravity for the sake of simplicity. !!


-- Layers (Groups). Think as Photoshop layers: you can order things with Corona groups,
-- as well have display objects on the same group render together at once. 
local gameLayer    = display.newGroup()
local bulletsLayer = display.newGroup()
local enemiesLayer = display.newGroup()
local barrierLayer = display.newGroup()

-- Declare variables
local gameIsActive = true
local scoreText
local sounds
local score = 0
local toRemove = {}
local background
local player
local halfPlayerWidth

local landscape_1 = display.newImageRect( "images/fase1.png", 3963, 320 )

-- landscape:setReferencePoint( display.TopLeftReferencePoint )
landscape_1.anchorX = 0
landscape_1.anchorY = 0
landscape_1.x = 0
landscape_1.y = 0


-- Keep the texture for the enemy and bullet on memory, so Corona doesn't load them everytime
local textureCache = {}
textureCache[1] = display.newImage("images/meteoro1.png"); textureCache[1].isVisible = false;
textureCache[2] = display.newImage("images/tiro1.png");  textureCache[2].isVisible = false;
textureCache[3] = display.newImage("images/inimigo1-1b.png");  textureCache[3].isVisible = false;
local halfEnemyWidth = textureCache[1].contentWidth * .5

-- Adjust the volume
audio.setMaxVolume( 0.5, { channel=1 } )

-- Pre-load our sounds
sounds = {
	pew = audio.loadSound("audio/pew.wav"),
	boom = audio.loadSound("audio/boom.wav"),
	gameOver = audio.loadSound("audio/gameOver.wav")
}

-- display a background image
gameLayer:insert(landscape_1)


-- Order layers (background was already added, so add the bullets, enemies, and then later on
-- the player and the score will be added - so the score will be kept on top of everything)
gameLayer:insert(bulletsLayer)
gameLayer:insert(enemiesLayer)
gameLayer:insert(barrierLayer)

audio.play (backgroundsnd, { loops = 3})
audio.setVolume(0.2, {backgroundsnd} )

 local function reset_landscape( landscape )
	landscape.x = 0
	transition.to( landscape, {x=0-3963+480, time=30000, onComplete=reset_landscape} )
end

local function onCollision(self, event)
	-- Bullet hit enemy
	if self.name == "bullet" and event.other.name == "enemy" and gameIsActive then
		-- Increase score
		score = score + 3
		scoreText.text = score
		
		-- Play Sound
		audio.play(sounds.boom)
		
		-- We can't remove a body inside a collision event, so queue it to removal.
		-- It will be removed on the next frame inside the game loop.
		table.insert(toRemove, event.other)
	
	-- Player collision - GAME OVER	
	elseif self.name == "player" and event.other.name == "enemy" or self.name == "player" and event.other.name == "barrier" then
		audio.play(sounds.gameOver)
		
		local gameoverText = display.newText("Game Over!", 0, 0, nil, 35)
		gameoverText.x = display.contentCenterX
		gameoverText.y = display.contentCenterY
		gameLayer:insert(gameoverText)
		
		-- This will stop the gameLoop
		gameIsActive = false
	elseif self.name == "bullet" and event.other.name == "barrier" and gameIsActive then
	-- Increase score
		score = score + 1
		scoreText.text = score
		
		-- Play Sound
		audio.play(sounds.boom)
		
		-- We can't remove a body inside a collision event, so queue it to removal.
		-- It will be removed on the next frame inside the game loop.
		table.insert(toRemove, event.other)
	end
end

-- Load and position the player
player = display.newImageRect("images/nave1.png",80,30)player.y = display.contentCenterY
player.x = 30

-- Add a physics body. It is kinematic, so it doesn't react to gravity.
physics.addBody(player, "kinematic", {bounce = 0})

-- This is necessary so we know who hit who when taking care of a collision event
player.name = "player"

-- Listen to collisions
player.collision = onCollision
player:addEventListener("collision", player)

-- Add to main layer
gameLayer:insert(player)

-- Store half width, used on the game loop
halfPlayerWidth = player.contentWidth * .5

-- Show the score
scoreText = display.newText(score, 0, 0, nil, 35)
scoreText.x = 30
scoreText.y = 25
gameLayer:insert(scoreText)

reset_landscape( landscape_1 )
--------------------------------------------------------------------------------
-- Game loop
--------------------------------------------------------------------------------
local timeLastBullet, timeLastEnemy = 0, 0
local bulletInterval = 1000

local function gameLoop(event)
	if gameIsActive then
		
		-- Remove collided enemy planes
		for i = 1, #toRemove do
			toRemove[i].parent:remove(toRemove[i])
			toRemove[i] = nil
		end
		-- Check if it's time to spawn another enemy,
		-- based on a random range and last spawn (timeLastEnemy)
		if event.time - timeLastEnemy >= math.random(600, 1000) then
			-- Randomly position it on the top of the screen
			local barrier = display.newImage("images/meteoro1.png")
			barrier.x = display.contentWidth + barrier.contentHeight
			barrier.y = math.random(0, display.contentHeight)

			-- This has to be dynamic, making it react to gravity, so it will
			-- fall to the bottom of the screen.
			physics.addBody(barrier, "dynamic", {bounce = 0})
			barrier.name = "enemy"
			
			enemiesLayer:insert(barrier)
			timeLastEnemy = event.time
		end
	
		-- Spawn a bullet
		if event.time - timeLastBullet >= math.random(250, 300) then
			local bullet = display.newImage("images/tiro1.png")
			bullet.x = player.x + player.contentWidth/2
			bullet.y = player.y
		
			-- Kinematic, so it doesn't react to gravity.
			physics.addBody(bullet, "kinematic", {bounce = 0})
			bullet.name = "bullet"
			
			-- Listen to collisions, so we may know when it hits an enemy.
			bullet.collision = onCollision
			bullet:addEventListener("collision", bullet)
		
			gameLayer:insert(bullet)
			
			-- Pew-pew sound!
			audio.play(sounds.pew)
			
			-- Move it to the top.
			-- When the movement is complete, it will remove itself: the onComplete event
			-- creates a function to will store information about this bullet and then remove it.
			transition.to(bullet, {time = 1000, x = display.contentWidth - bullet.contentHeight,
				onComplete = function(self) self.parent:remove(self); self = nil; end
			})
						
			timeLastBullet = event.time
		end
		if event.time - timeLastEnemy >= math.random(600, 1000) then
			-- Randomly position it on the top of the screen
			local enemy = display.newImage("images/inimigo1-1b.png")
			enemy.x = display.contentWidth + enemy.contentHeight
			enemy.y = math.random(0, display.contentHeight)

			-- This has to be dynamic, making it react to gravity, so it will
			-- fall to the bottom of the screen.
			physics.addBody(enemy, "dynamic", {bounce = 0})
			enemy.name = "enemy"
			
			enemiesLayer:insert(enemy)
			timeLastEnemy = event.time
			
		end
	

	end
end

-- Call the gameLoop function EVERY frame,
-- e.g. gameLoop() will be called 30 times per second ir our case.
Runtime:addEventListener("enterFrame", gameLoop)

-- Create a runtime event to move backgrounds
-- Runtime:addEventListener( "enterFrame", move )
--------------------------------------------------------------------------------
-- Basic controls
--------------------------------------------------------------------------------
local function playerMovement(event)
	-- Doesn't respond if the game is ended
	if not gameIsActive then return false end
	
	-- Only move to the screen boundaries
	if event.y >= 0 or event.y <= display.contentHeight then
		-- Update player x axis
		player.y = event.y
	end
end

-- Player will listen to touches
player:addEventListener("touch", playerMovement)
	
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
	audio.stop (backgroundsnd)
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