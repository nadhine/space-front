-----------------------------------------------------------------------------------------
--------- level1.lua
-----------------------------------------------------------------------------------------
-- include Corona's  libraries
local widget = require "widget"
local storyboard = require "storyboard"
local composer = require( "composer" )
local physics = require "physics"

local scene = composer.newScene()
local backgroundsnd = audio.loadStream ( "audio/bgMusic.mp3")
physics.start()
physics.setGravity(0, 0)
--------------------------------------------

-- Declare  Layers
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
gameLayer:insert(landscape)

-- Keep the texture for the enemy and bullet on memory, so Corona doesn't load them everytime
local textureCache = {}
textureCache[1] = display.newImage("images/meteoro1.png"); textureCache[1].isVisible = false;
textureCache[2] = display.newImage("images/tiro1.png");  textureCache[2].isVisible = false;
textureCache[3] = display.newImage("images/tiro2.png");  textureCache[3].isVisible = false;
textureCache[4] = display.newImage("images/inimigo1-1b.png");  textureCache[4].isVisible = false;
local halfEnemyWidth = textureCache[1].contentWidth * .5

-- Adjust the volume
audio.setMaxVolume( 0.2, { channel=1 } )
audio.play (backgroundsnd, { loops = 3})
audio.setVolume(0.1, {backgroundsnd} )

-- Pre-load our sounds
sounds = {
	pew = audio.loadSound("audio/pew.wav"),
	boom = audio.loadSound("audio/boom.wav"),
	gameOver = audio.loadSound("audio/gameOver.wav")
}

-- Order layers (background was already added, so add the bullets, enemies, and then later on
-- the player and the score will be added - so the score will be kept on top of everything)
gameLayer:insert(bulletsLayer)
gameLayer:insert(enemiesLayer)
gameLayer:insert(barrierLayer)
gameLayer:insert(enemiesBulletsLayer)


----paralax
local function reset_landscape( landscape )
	landscape.x = 0
	transition.to( landscape, {x=0-3963+480, time=30000, onComplete=reset_landscape} )
end

local function gameover()
	audio.play(sounds.gameOver)
	gameIsActive = false
	composer.gotoScene("gameover","fade")
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

--------------------------------------------
function scene:create( event )
	print( "1: create scene level1" )
	local sceneGroup = self.view
	sceneGroup:insert(gameLayer)
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
	tableEnemies = {}
	en = {}
	tableEnemies[100] = 250
	tableEnemies[200] = 250
	tableEnemies[300] = 350
	cont = 1
	halfPlayerWidth = 0
	for key,v in pairs(tableEnemies) do		
		enemy = display.newImageRect("images/inimigo1-1b.png",30,30)
		enemy.y = key
		enemy.x = v
		-- Add a physics body. It is kinematic, so it doesn't react to gravity .....
		physics.addBody(enemy, "dynamic", {density=10, bounce = 0})
		-- This is necessary so we know who hit who when taking care of a collision event
		enemy.name = "enemy"
		-- Listen to collisions
		enemy.collision = onCollision
		enemy:addEventListener("collision", enemy)
		-- Add to main layer
		enemiesLayer:insert(enemy)
		gameLayer:insert(enemy)
		en[cont] = enemy
		cont = cont +1
		-- Store half width, used on the game loop
		halfPlayerWidth = enemy.contentWidth * .5
		print (enemy.name)
	end

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
				transition.to(barrier, {time = 10000, x = barrier.contentWidth - display.contentHeight,
					onComplete = function(self) if self.parent then self.parent:remove(self); self = nil; end end})
				barrierLayer:insert(barrier)
				timeLastBarrier = event.time
			end
			---enemy movement
			for i = 1,3 do
				enemy = (en[i])
				if enemy.x ~= nil then
					enemy.x = enemy.x - 2
								---spaw enemy bullet
				end
				--- o parametro de tempo impede q as balas aparecam em todos os inimigos
				if event.time - timeLastEnemyBullet >= 600 and enemy.x ~= nil then
					
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

					transition.to(Ebullet, {time = 1000, x = Ebullet.contentHeight - display.contentWidth,
						onComplete = function(self) if self.parent then self.parent:remove(self); self = nil; end end
					})
								
					timeLastEnemyBullet = event.time
			
				end
			end
		
			-- Spawn a bullet
			if event.time - timeLastBullet >= 300 then
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
				
				-- When the movement is complete, it will remove itself: the onComplete event
				-- creates a function to will store information about this bullet and then remove it.
				transition.to(bullet, {time = 1000, x = display.contentWidth - bullet.contentHeight,
					onComplete = function(self) if self.parent then self.parent:remove(self); self = nil; end end
				})
							
				timeLastBullet = event.time
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
		end
	end

	-- will listen to all touches
	Runtime:addEventListener("touch", playerMovement)
		
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		print( "1: show event, phase will level1" )
		-- Called when the scene is still off screen and is about to move on screen
		-- local currScene = composer.getSceneName( "level1" )
		-- composer.gotoScene( currScene )
	elseif phase == "did" then
			print( "1: show event, phase did level1" )
			sceneGroup.isVisible = true
			composer.removeScene( "gameover" )
	end	
end

function scene:hide( event )
	print( "hide scene level 1" )
	local sceneGroup = self.view
		audio.stop()
		sceneGroup.isVisible = false	

end

function scene:destroy( event )
	print( "((destroying level1's view))" )
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene