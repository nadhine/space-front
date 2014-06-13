-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------
-- include Corona's "widget" library
local widget = require "widget"

local storyboard = require "storyboard"
local composer = require( "composer" )
local scene = composer.newScene()

-- include functions pubnub
require ("multiplayerFunctions");
-- include Corona's "widget" library
local widget = require "widget"

local backgroundsnd = audio.loadStream ( "audio/bgMusic.mp3")

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()
physics.setGravity(-5, 0)
--------------------------------------------


function scene:create( event )
	local sceneGroup = self.view
	-- Hide status bar, so it won't keep covering our game objects

	-- A heavier gravity, so enemies planes fall faster
	-- !! Note: there are a thousand better ways of doing the enemies movement,
	-- but I'm going with gravity for the sake of simplicity. !!


	-- Layers (Groups). Think as Photoshop layers: you can order things with Corona groups,
	-- as well have display objects on the same group render together at once. 
	local gameLayer    = display.newGroup()
	local bulletsLayer = display.newGroup()
	local enemiesLayer = display.newGroup()
	local enemiesBulletsLayer = display.newGroup()
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
	local resist = 0

	local landscape = display.newImageRect( "images/fase1.png", 3963, 320 )

	-- landscape:setReferencePoint( display.TopLeftReferencePoint )
	landscape.anchorX = 0
	landscape.anchorY = 0
	landscape.x = 0
	landscape.y = 0


	-- Keep the texture for the enemy and bullet on memory, so Corona doesn't load them everytime
	local textureCache = {}
	textureCache[1] = display.newImage("images/meteoro1.png"); textureCache[1].isVisible = false;
	textureCache[2] = display.newImage("images/tiro1.png");  textureCache[2].isVisible = false;
	textureCache[3] = display.newImage("images/tiro2.png");  textureCache[3].isVisible = false;
	textureCache[4] = display.newImage("images/inimigo1-1b.png");  textureCache[4].isVisible = false;
	local halfEnemyWidth = textureCache[1].contentWidth * .5

	-- Adjust the volume
	audio.setMaxVolume( 0.2, { channel=1 } )

	-- Pre-load our sounds
	sounds = {
		pew = audio.loadSound("audio/pew.wav"),
		boom = audio.loadSound("audio/boom.wav"),
		gameOver = audio.loadSound("audio/gameOver.wav")
	}

	-- display a background image
	gameLayer:insert(landscape)


	-- Order layers (background was already added, so add the bullets, enemies, and then later on
	-- the player and the score will be added - so the score will be kept on top of everything)
	gameLayer:insert(bulletsLayer)
	gameLayer:insert(enemiesLayer)
	gameLayer:insert(barrierLayer)
	gameLayer:insert(enemiesBulletsLayer)
	sceneGroup:insert(gameLayer)

	audio.play (backgroundsnd, { loops = 3})
	audio.setVolume(0.1, {backgroundsnd} )

	local function reset_landscape( landscape )
		landscape.x = 0
		transition.to( landscape, {x=0-3963+480, time=30000, onComplete=reset_landscape} )
	end

	local function menuBtnRelease()
		print( "menubtn" )
		-- go to about.lua scene
		composer.gotoScene( "menu", "fade", 500 )
		print( "go to menu" )
		
		return true	-- indicates successful touch
	end
	
	local function restartBtnRelease()
		-- go to about.lua scene
		composer.gotoScene( "level1", "fade", 500 )	
		return true	-- indicates successful touch
	end

	local function gameover()
		audio.play(sounds.gameOver)
		
		local gameoverText = display.newText("Game Over!", 0, 0, nil, 35)
		gameoverText.x = display.contentCenterX
		gameoverText.y = display.contentCenterY
		gameLayer:insert(gameoverText)
		
		menuBtn = widget.newButton{
		labelColor = { default={255}, over={128} },
		defaultFile="images/menubtn.png",
		overFile="images/menubtnover.png",
		width=154, height=40,
		onRelease = menuBtnRelease	-- event listener function
		}
		menuBtn.x =  240
		menuBtn.y =  230
		
		restartBtn = widget.newButton{
		labelColor = { default={255}, over={128} },
		defaultFile="images/restartbtn.png",
		overFile="images/restartbtnover.png",
		width=154, height=40,
		onRelease = restartBtnRelease	-- event listener function
		}
		restartBtn.x =  240
		restartBtn.y =  290
		
		-- all display objects must be inserted into group
		gameLayer:insert( menuBtn )
		gameLayer:insert( restartBtn )
		gameIsActive = false
		storyboard.removeScene( "level1" )
		-- This will stop the gameLoop
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
		
		elseif self.name == "bullet" and event.other.name == "barrier" and gameIsActive then
			-- Increase score
			score = score + 1
			scoreText.text = score
			
			-- Play Sound
			audio.play(sounds.boom)	
			-- We can't remove a body inside a collision event, so queue it to removal.
			-- It will be removed on the next frame inside the game loop.
			table.insert(toRemove, event.other)
			
		-- Player collision - GAME OVER	
		elseif self.name == "player" and event.other.name == "enemy" or self.name == "player" and event.other.name == "barrier" then
			gameover()		
		end
		if self.name == "Ebullet" and event.other.name == "player" then
			gameover()			
		end
	end

	-- Load and position the player
	player = display.newImageRect("images/nave1.png",60,30)
	player.y = display.contentCenterY
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
	scoreText = display.newText(score, 0, 0, nil, 25)
	scoreText.x = 430
	scoreText.y = 25
	gameLayer:insert(scoreText)

	reset_landscape( landscape )

	-- Load and position the enemys
	halfPlayerWidth = 0
	enemy = display.newImageRect("images/inimigo1-1b.png",30,30)
	enemy.y = 100
	enemy.x = 450
	-- Add a physics body. It is kinematic, so it doesn't react to gravity .....
	physics.addBody(enemy, "dynamic", {density=10, bounce = 0})
	-- This is necessary so we know who hit who when taking care of a collision event
	enemy.name = "enemy"
	-- Listen to collisions
	enemy.collision = onCollision
	enemy:addEventListener("collision", enemy)
	-- Add to main layer
	gameLayer:insert(enemy)
	-- Store half width, used on the game loop
	halfPlayerWidth = enemy.contentWidth * .5

	--------------------------------------------------------------------------------
	-- Game loop
	--------------------------------------------------------------------------------
	local timeLastBullet, timeLastBarrier , timeLastEnemyBullet= 0, 0, 0
	local bulletInterval = 1000

	local function gameLoop(event)
		if gameIsActive then
			
			-- Remove collided enemy planes
			for i = 1, #toRemove do
				toRemove[i].parent:remove(toRemove[i])
				toRemove[i] = nil
			end
			-- Check if it's time to spawn another enemy,
			-- based on a random range and last spawn (timeLastBarrier)
			if event.time - timeLastBarrier >= math.random(600, 1000) then
				-- Randomly position it on the top of the screen
				local barrier = display.newImage("images/meteoro1.png")
				barrier.x = display.contentWidth + barrier.contentHeight
				barrier.y = math.random(0, display.contentHeight)

				-- This has to be dynamic, making it react to gravity, so it will
				-- fall to the bottom of the screen.
				physics.addBody(barrier, "dynamic", {bounce = 0})
				barrier.name = "barrier"
				
				enemiesLayer:insert(barrier)
				timeLastBarrier = event.time
			end
			---enemy movement
			
			if enemy.x ~= nil then
				enemy.x = enemy.x - 2
				
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
			
			---spaw enemy bullet
			if halfPlayerWidth > 0 and event.time - timeLastEnemyBullet >= math.random(250, 300) and enemy.x ~= nil then
				local Ebullet = display.newImage("images/tiro2.png")
				Ebullet.x = enemy.x - halfPlayerWidth
				Ebullet.y = enemy.y
			
				-- Kinematic, so it doesn't react to gravity.
				physics.addBody(Ebullet, "dynamic", {bounce = 0})
				Ebullet.name = "Ebullet"
				
				-- Listen to collisions, so we may know when it hits an enemy.
				Ebullet.collision = onCollision
				Ebullet:addEventListener("collision", Ebullet)
			
				gameLayer:insert(Ebullet)
				
				-- Pew-pew sound!
				audio.play(sounds.pew)
				
				-- Move it to the top.
				-- When the movement is complete, it will remove itself: the onComplete event
				-- creates a function to will store information about this bullet and then remove it.
				transition.to(Ebullet, {time = 1000, x = Ebullet.contentHeight - display.contentWidth,
					onComplete = function(self) self.parent:remove(self); self = nil; end
				})
							
				timeLastEnemyBullet = event.time
		
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
		if event.y >= player.height and event.y <= display.contentHeight-player.height then
			-- Update player x axis
			player.y = event.y + 5
			local teste = generateId();
			print( teste );

		end
	end

	-- Player will listen to touches
	player:addEventListener("touch", playerMovement)
		
end


function scene:show( event )
	local sceneGroup = self.view

		physics.start()
		sceneGroup.isVisible = true

end

function scene:hide( event )
	local sceneGroup = self.view
		audio.stop()
		sceneGroup.isVisible = false	

end

function scene:destroy( event )
	-- Called prior to the removal of scene's "view" (gameLayer)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	physics.stop()
	audio.stop()
	package.loaded[physics] = nil
	physics = nil
	sceneGroup:removeSelf()
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene