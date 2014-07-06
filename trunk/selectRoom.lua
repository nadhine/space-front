local storyboard = require "storyboard"
local composer = require "composer"
local scene = composer.newScene()
local widget = require "widget"
local globals = require( "globals" )

widget.setTheme( "widget_theme_android" )

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

local function tableViewListener( event )
    local phase = event.phase
    local row = event.target
end

-- Handle row rendering
local function onRowRender( event )
    local phase = event.phase
    local row = event.row

    local rowTitle = display.newText( row, "Row " .. row.index, 0, 0, nil, 10 )
    rowTitle.x = row.x - ( row.contentWidth * 0.5 ) + ( rowTitle.contentWidth * 0.5 )
    rowTitle.y = row.contentHeight * 0.5
    rowTitle:setFillColor( 255, 255, 255 )
end

-- Handle touches on the row
local function onRowTouch( event )
    local phase = event.phase

    if "press" == phase then
        print( "Touched row:", event.target.index )
    end
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
		gameoverText.y = 80
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
		
	local tableView = widget.newTableView
	{
		top = 100,
		width = 160, 
		height = 160,
		listener = tableViewListener,
		onRowRender = onRowRender,
		onRowTouch = onRowTouch,
	}
		tableView.x = 100
		tableView.y = 200

	-- Create 5 rows
	for i = 1, 4 do
		local isCategory = false
		local rowHeight = 40
		local rowColor = 
		{ 
			default = { 0, 0, 0 },
		}
		local lineColor = { 105, 105, 105 }

		-- Make some rows categories
		if i == 25 or i == 50 or i == 75 then
			isCategory = true
			rowHeight = 24
			rowColor = 
			{ 
				default = { 150, 160, 180, 200 },
			}
		end

		-- Insert the row into the tableView
		tableView:insertRow
		{
			isCategory = isCategory,
			rowHeight = rowHeight,
			rowColor = rowColor,
			lineColor = lineColor,
		}
	end 
				
		-- all display objects must be inserted into group
		sceneGroup:insert( background )
		sceneGroup:insert( gameoverText )
		sceneGroup:insert( menuBtn )
		sceneGroup:insert( playBtn )
		sceneGroup:insert( tableView )
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