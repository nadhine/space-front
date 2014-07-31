-----------------------------------------------------------------------------------------
--------- level1.lua
-----------------------------------------------------------------------------------------
-- include Corona's  libraries
local widget = require "widget"
local storyboard = require "storyboard"
local composer = require( "composer" )
local physics = require "physics"
local createEnemies = require "createEnemies"
local createEnemiesBullets = require "createEnemiesBullets"
local createExplosion = require "createExplosion"
local globals = require( "globals" )
-- include functions pubnub
require ("multiplayerFunctions");
-- include functions of protocols
local protocolo = require("protocolos");
local enemyPosition = require("enemyPosition")
local vidas = require("lifes")

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
local explosionLayer = display.newGroup()

-- Declare variables
local gameIsActive = true
local scoreText
local sounds
globals.score = 0
globals.fase = "level1multi"
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
gameLayer:insert(explosionLayer)

local fimdeFase = function()
	gameIsActive = false
	composer.gotoScene("fimdefase","fade")
end

----paralax
local function resetLandscape( landscape )
	landscape.x = 0
	transition.to( landscape, {x=0-3963+480, time=50000, onComplete=fimdeFase} )
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
		globals.score = globals.score + 3
		scoreText.text = globals.score
		
		-- Play Sound
		audio.play(sounds.boom)	
		-- We can't remove a body inside a collision event, so queue it to removal.
		-- It will be removed on the next frame inside the game loop.
		local explosion = createExplosion.create(event.other, "images/explosion.png", 24,23,8)
		display.remove(event.other)
	
	elseif self.name == "bullet" and event.other.name == "barrier" and gameIsActive then
		-- Increase score
		globals.score = globals.score + 1
		scoreText.text = globals.score
		
		-- Play Sound
		audio.play(sounds.boom)	
		-- We can't remove a body inside a collision event, so queue it to removal.
		-- It will be removed on the next frame inside the game loop.
		local explosion = createExplosion.create(event.other, "images/explosion.png", 24,23,8)		
		display.remove(event.other)
		
	-- Player collision - GAME OVER	
	elseif self.name == "player" and event.other.name == "enemy" or self.name == "player" and event.other.name == "barrier" or self.name == "player" and event.other.name == "ebullet" then
		local explosion = createExplosion.create(self, "images/explosion.png", 24,23,8)
		--gameover()
		if globals.vida == 0 then
			gameover()
		else
			globals.vida = globals.vida - 1 
		end
	end
end

--------------------------------------------
function scene:create( event )
	print( "1: create scene level1multi" )
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
	scoreText = display.newText(globals.score, 0, 0, nil, 25)
	scoreText.x = 430
	scoreText.y = 25
	gameLayer:insert(scoreText)

	resetLandscape( landscape )

	-- Load and position the enemys
	local tableEnemies = enemyPosition.stage1()
	local enemies = {}
	local cont = 0

	for key,v in pairs(tableEnemies) do		
		enemy = createEnemies.create("images/inimigo1-1b.png", (v[1]), (v[2]), 1000)
		enemiesLayer:insert(enemy)
		gameLayer:insert(enemy)
		enemies[cont] = enemy
		enemy.id = cont
		cont = cont +1

	end
	
	tableEnemies2 = enemyPosition.stage1b()
	for key,v in pairs(tableEnemies2) do		
		enemy = createEnemies.create("images/inimigo1-2b.png", (v[1]), (v[2]), 3000)
		enemiesLayer:insert(enemy)
		gameLayer:insert(enemy)
		enemies[cont] = enemy
		enemy.id = cont
		cont = cont +1

	end

	--------------------------------------------------------------------------------
	-- Game loop
	--------------------------------------------------------------------------------
	local timeLastBullet, timeLastBarrier = 0, 0


	local function gameLoop(event)
		if gameIsActive then
			vidas.minhaVida()
			-- Check if it's time to spawn another enemy,
			-- based on a random range and last spawn (timeLastBarrier)
			if(packReceived~="nada") then
				if(player2 == nil) then
						-- Load and position the player
					player2 = display.newImageRect("images/nave2.png",60,30)
					player2.y = packReceived["bulletY"]
					player2.x = packReceived["bulletX"]
					-- Add a physics body. It is kinematic, so it doesn't react to gravity.
					physics.addBody(player, "kinematic", {bounce = 0})
					-- This is necessary so we know who hit who when taking care of a collision event
					player2.name = "player"
					-- Listen to collisions
					player2.collision = onCollision
					player2:addEventListener("collision", player2)
					-- Add to main layer
					gameLayer:insert(player2)
				end
				if(player2 ~= nil) then
					player2.x = packReceived["bulletX"]
					player2.y = packReceived["bulletY"]
				end
					

				--COLOCAR AQUI AS FUNÇOES DE CRIAR AS BALAS E O JOGADOR 2
				local bullet = display.newImage("images/tiro1.png")
				bullet.x = packReceived["bulletX"] + player.contentWidth *0.5
				bullet.y = packReceived["bulletY"]
				physics.addBody(bullet, "dynamic", {density=1000, bounce = 0, friction = 0})
				bullet.name = "bullet"
				bullet.isBullet = true
				bullet:setLinearVelocity( 800,0 )
				bullet.collision = onCollision
				bullet:addEventListener("collision", bullet)

				gameLayer:insert(bullet)
				audio.play(sounds.pew)
				
				-- When the movement is complete, it will remove itself: the onComplete event
				-- creates a function to will store information about this bullet and then remove it.
				transition.to(bullet, {time = 1000, x =  packReceived["bulletX"] + 400,
					onComplete = function(self) if self.parent then self.parent:remove(self); self = nil; end end
				})
				
				print( packReceived["bulletY"] )
				packReceived="nada"
			end
			if event.time - timeLastBarrier >= math.random(600, 1000) then
				-- Randomly position it on the top of the screen
				local barrier = display.newImage("images/meteoro1.png")
				barrier.x = display.contentWidth + barrier.contentHeight
				barrier.y = math.random(0, display.contentHeight)

				physics.addBody(barrier, "dynamic", {density=1, bounce = 0, friction = 0})
				barrier.name = "barrier"
				barrierLayer:insert(barrier)
				transition.to(barrier, {time = 10000, x = - display.contentWidth,
					onComplete = function(self) if self.parent then self.parent:remove(self); self = nil; end end})
				timeLastBarrier = event.time
			end
			
			---enemy movement
			for i = 0,(table.getn(enemies)) do
				enemy = (enemies[i])
				if enemy.x ~= nil then
					enemy.x = enemy.x - 3
				end
				---spaw enemy bullet
				if event.time - enemy.timeLastEnemyBullet >= enemy.interv and enemy.x ~= nil then
					local ebullet = createEnemiesBullets.create(enemy, "images/tiro2.png")
					enemy.timeLastEnemyBullet = event.time
					gameLayer:insert(ebullet)
				end
			end
			
			--Se receber uma tabela verificar dessa forma table['protocolo'] para saber qual o protocolo, dps pega as variaveis x e y
			--table['bulletX'] e table['bulletY']
			-- Spawn a player's bullet
			if event.time - timeLastBullet >= 300 and player.x ~= nil then
				local bullet = display.newImage("images/tiro1.png")
				bullet.x = player.x + player.contentWidth *0.5
				bullet.y = player.y
				physics.addBody(bullet, "dynamic", {density=1000, bounce = 0, friction = 0})
				bullet.name = "bullet"
				bullet.isBullet = true
				bullet:setLinearVelocity( 800,0 )
				bullet.collision = onCollision
				bullet:addEventListener("collision", bullet)
			
				-- before of create the bullet in stage, send to pubnub for the other player see the bullet
				local protoBullet = {}
				protoBullet["playerId"] = playerId
				protoBullet["bulletX"] = bullet.x
				protoBullet["bulletY"] = bullet.y
				protoBullet["room"]    = "sala1"
				protoBullet["protocolo"] = "positionPlayerBullet"
				sendMessage(protoBullet)

				gameLayer:insert(bullet)
				audio.play(sounds.pew)
				
				-- When the movement is complete, it will remove itself: the onComplete event
				-- creates a function to will store information about this bullet and then remove it.
				transition.to(bullet, {time = 1000, x = player.x + 400,
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
			player.y = event.y
		end
	end

	-- will listen to all touches
	Runtime:addEventListener("touch", playerMovement)
		
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		print( "1: show event, phase will level1multi" )
		-- Called when the scene is still off screen and is about to move on screen
		-- local currScene = composer.getSceneName( "level1" )
		-- composer.gotoScene( currScene )
	elseif phase == "did" then
			print( "1: show event, phase did level1multi" )
			sceneGroup.isVisible = true
			composer.removeScene( "gameover" )
	end	
end

function scene:hide( event )
	print( "hide scene level1multi" )
	local sceneGroup = self.view
		audio.stop()
		sceneGroup.isVisible = false	

end

function scene:destroy( event )
	print( "((destroying level1multi view))" )
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene