-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- set default background
display.setDefault( "background", 231/255, 215/255, 163/255 )

-- constants
local TILE_SIZE = 32
local TILE_HALF_SIZE = TILE_SIZE * 0.5
local MAX_ROWS = 12
local MAX_COLS = 10
local COLORS = {
    { r=0/255,      g=160/255,  b=176/255 },
    { r=237/255,    g=201/255,  b=81/255 },
    { r=100/255,    g=66/255,   b=103/255 },
    { r=205/255,    g=51/255,   b=63/255 }
}

local tileArray = {}
local board = display.newGroup()

-- returns a new tile
local function newTile( px, py )
    local randomTile = math.random( #COLORS )
    local tile = display.newRect( px, py, TILE_SIZE, TILE_SIZE )
    tile.value = randomTile
    tile:setFillColor( COLORS[randomTile].r, COLORS[randomTile].g, COLORS[randomTile].b )
    return tile
end

-- removes the neighbors of the same type - flood fill algorithm
local function floodFill( row, col, value )
    if row > 0 and row < MAX_ROWS+1 and col > 0 and col < MAX_COLS+1 then
        if tileArray[row][col] ~= nil and tileArray[row][col].value == value then
            tileArray[row][col]:removeSelf()
            tileArray[row][col] = nil
            floodFill( row+1, col, value )
            floodFill( row-1, col, value )
            floodFill( row, col+1, value )
            floodFill( row, col-1, value )
        end
    end
end

-- returns how may holes have under such tile
local function holesBelow( row, col )
    local holes = 0
    for row=row+1, MAX_ROWS do
        if tileArray[row][col] == nil then
            holes = holes + 1
        end
    end
    return holes
end

-- make remaining tiles fall down once you removed tiles
local function fall()
    for row=MAX_ROWS, 1, -1 do
        for col=MAX_COLS, 1, -1 do
            if tileArray[row][col] ~= nil then
                local holes = holesBelow( row, col )
                if holes > 0 then
                    transition.to( tileArray[row][col], { time=500, y=( row + holes ) * TILE_SIZE - TILE_HALF_SIZE } )
                    tileArray[row+holes][col] = tileArray[row][col]
                    tileArray[row][col] = nil
                end
            end
        end
    end
end

-- add new tiles falling from the top
local function fallFromTop()
    for col=1, MAX_COLS do
        local holes = holesBelow( 0, col )
        for row=1, holes do
            tileArray[row][col] = newTile( TILE_SIZE * col - TILE_HALF_SIZE, -( holes - row ) * TILE_SIZE - TILE_HALF_SIZE )
            board:insert( tileArray[row][col] )
            transition.to( tileArray[row][col], { time=500, y=TILE_SIZE * row - TILE_HALF_SIZE } )
        end
    end
end

-- handle touch event
local function touchHandler( event )
    if event.phase == "began" then
        local row = math.ceil( ( event.y-event.target.y ) / ( TILE_SIZE ) )
        local col = math.ceil( ( event.x-event.target.x ) / ( TILE_SIZE ) )
        floodFill( row, col, tileArray[row][col].value )
        fall()
        fallFromTop()
    end
    return true
end

-- create grid with tiles
for row=1, MAX_ROWS do
    tileArray[row] = {}
    for col=1, MAX_COLS do
        local tile = newTile( TILE_SIZE * col - TILE_HALF_SIZE, TILE_SIZE * row - TILE_HALF_SIZE )
        tileArray[row][col] = tile
        board:insert( tile )
    end
end

-- add events and position the board
board.x = display.contentCenterX - board.width * 0.5
board.y = display.contentCenterY - board.height * 0.5
board:addEventListener( "touch", touchHandler )