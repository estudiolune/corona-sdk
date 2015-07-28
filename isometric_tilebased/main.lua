-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local Grid = require 'jumper.grid'
local Pathfinder = require 'jumper.pathfinder'

-----------------------------------------------------------------------------------------

-- hide status bar
display.setStatusBar( display.HiddenStatusBar )

-- constants
local TILE_WIDTH = 56
local TILE_HEIGHT = 28
local TILE_HALF_WIDTH = TILE_WIDTH * 0.5
local TILE_HALF_HEIGHT = TILE_HEIGHT * 0.5
local FLOOR = {
    -TILE_HALF_WIDTH,0,
    0,-TILE_HALF_HEIGHT,
    TILE_HALF_WIDTH,0,
    0,TILE_HALF_HEIGHT
}

-- tilemap 8x8
local tilemap = {
    { 0,1,0,0,0,0,0,0 },
    { 0,1,0,1,1,1,1,0 },
    { 0,0,0,0,1,0,0,0 },
    { 1,1,1,0,1,0,1,1 },
    { 0,0,0,0,1,0,0,0 },
    { 0,1,1,1,1,0,1,0 },
    { 0,0,0,0,1,0,1,0 },
    { 0,1,0,0,1,0,1,0 }
}

-- define board and player
local board = display.newGroup()
local player = display.newRect( 0, 0, 16, 34 )
player:setFillColor( 230/255,84/255,107/255 )
player.anchorY = 1
player.col, player.row = 1, 8

local grid = Grid( tilemap )
local walkable = 0
-- creates a pathfinder object using Jump Point Search
local pathfinder = Pathfinder( grid, 'JPS', walkable )
pathfinder:setMode( "ORTHOGONAL" ) -- or DIAGONAL

-- convert tilemap position to screen
local function tilemapToScreen( col, row )
    local px = ( col - row ) * TILE_HALF_WIDTH
    local py = ( col + row ) * TILE_HALF_HEIGHT
    return px, py - TILE_HALF_HEIGHT
end

-- convert screen position to tilemap
local function screenToTilemap( px, py )
    local col = ( px / TILE_HALF_WIDTH + py / TILE_HALF_HEIGHT ) * 0.5
    local row = ( py / TILE_HALF_HEIGHT -  px / TILE_HALF_WIDTH ) * 0.5
    return math.floor( col + 1 ), math.floor( row + 1 ) -- plus one because is lua, index starts with 1
end

-- move the player in the path
local function movePlayer()
    if #player.path > 0 then
        player.isMoving = true
        -- get position
        player.col, player.row = player.path[1]:getX(), player.path[1]:getY()
        local px, py = tilemapToScreen( player.col, player.row )
        -- remove this position
        table.remove( player.path, 1 )
        -- transition to new position
        transition.to( player, { x=px, y=py, time=300, onComplete=movePlayer } )
    else
        player.isMoving = false
    end
end

-- handle touch event
local function touchHandler( event )
    local phase = event.phase
    local col, row = screenToTilemap( event.x - event.target.x, event.y - event.target.y )
    
    if phase == "began" and col > 0 and row > 0 and col < 9 and row < 9 then
        -- calculates the path, and its length
        local path = pathfinder:getPath( player.col, player.row, col, row )
        if path then
            player.path = {}
            for node, count in path:nodes() do
                print( ( "Step: %02d - col: %d - row: %d" ):format(count, node:getX(), node:getY() ) )
                if count > 1 then
                    player.path[#player.path+1] = node
                end
            end
            if not player.isMoving then
                movePlayer()
            end
        end
    end
end

-- build the map
for row=1, #tilemap do
    for col=1, #tilemap[row] do
        -- get position
        local px, py = tilemapToScreen( col, row )
        -- add tile
        local tileType = tilemap[row][col]
        local tile = display.newPolygon( px, py, FLOOR )
        if tileType == 0 then
            tile:setFillColor( 186/255, 218/255, 95/255 ) -- green
        else
            tile:setFillColor( 80/255, 200/255, 198/255 ) -- blue
        end
        board:insert( tile )
        -- add column and row values
        board:insert( display.newText( col .. "," .. row, px, py, native.systemFont, 10 ) )
    end
end

-- position player
player.x, player.y = tilemapToScreen( player.col, player.row )
board:insert( player )

-- add events and position the board
board.x, board.y = display.contentCenterX, display.contentCenterY - board.height * 0.5
board:addEventListener( "touch", touchHandler )