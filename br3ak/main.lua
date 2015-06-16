-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- constants
local TILE_SIZE = 30
local TILE_HALF_SIZE = TILE_SIZE * 0.5
local N_ROWS = 10
local N_COLS = 10
local COLORS = {
    { r=0/255,      g=160/255,  b=176/255 },
    { r=237/255,    g=201/255,  b=81/255 },
    { r=100/255,    g=66/255,   b=103/255 },
    { r=205/255,    g=51/255,   b=63/255 }
}

local tileMatrix = {}
local grid = display.newGroup()

-- returns a new tile
local function newTile( px, py )
    local tile = display.newRect( px, py, TILE_SIZE, TILE_SIZE )
    tile.value = math.random( #COLORS )
    tile.visited = false
    local color = COLORS[tile.value]
    tile:setFillColor( color.r, color.g, color.b )
    return tile
end

-- removes the neighbors of the same type - flood fill algorithm
local function floodFill( row, col, value, tiles )
    if row > 0 and row < N_ROWS+1 and col > 0 and col < N_COLS+1 then
        local tile = tileMatrix[row][col]
        if tile ~= nil and tile.value == value and not tile.visited then
            tile.visited = true
            tiles[#tiles+1] = { row=row, col=col }
            floodFill( row + 1, col, value, tiles )
            floodFill( row - 1, col, value, tiles )
            floodFill( row, col + 1, value, tiles )
            floodFill( row, col - 1, value, tiles )
        end
    end
end

-- returns how may holes have under such tile
local function holesBelow( row, col )
    local holes = 0
    for row=row+1, N_ROWS do
        if tileMatrix[row][col] == nil then
            holes = holes + 1
        end
    end
    return holes
end

-- make remaining tiles fall down once you removed tiles
local function fall()
    for row=N_ROWS, 1, -1 do
        for col=N_COLS, 1, -1 do
            if tileMatrix[row][col] ~= nil then
                local holes = holesBelow( row, col )
                if holes > 0 then
                    transition.to( tileMatrix[row][col], { time=500, y=( row + holes ) * TILE_SIZE - TILE_HALF_SIZE } )
                    tileMatrix[row+holes][col] = tileMatrix[row][col]
                    tileMatrix[row][col] = nil
                end
            end
        end
    end
end

-- add new tiles falling from the top
local function fallFromTop()
    for col=1, N_COLS do
        local holes = holesBelow( 0, col )
        for row=1, holes do
            tileMatrix[row][col] = newTile( TILE_SIZE * col - TILE_HALF_SIZE, -( holes - row ) * TILE_SIZE - TILE_HALF_SIZE )
            grid:insert( tileMatrix[row][col] )
            transition.to( tileMatrix[row][col], { time=500, y=TILE_SIZE * row - TILE_HALF_SIZE } )
        end
    end
end

-- handle touch event
local function touchHandler( event )
    if event.phase == "began" then
        local row = math.ceil( ( event.y-event.target.y ) / ( TILE_SIZE ) )
        local col = math.ceil( ( event.x-event.target.x ) / ( TILE_SIZE ) )
        
        local tiles = {}
        floodFill( row, col, tileMatrix[row][col].value, tiles )
        
        if #tiles > 2 then
            for i=1, #tiles do
                local row,col = tiles[i].row, tiles[i].col
                tileMatrix[row][col]:removeSelf()
                tileMatrix[row][col] = nil
            end
            fall()
            fallFromTop()
        else
            for i=1, #tiles do
                local row,col = tiles[i].row, tiles[i].col
                tileMatrix[row][col].visited = false
            end
        end
    end
    return true
end

-- create grid with tiles
for row=1, N_ROWS do
    tileMatrix[row] = {}
    for col=1, N_COLS do
        local tile = newTile( TILE_SIZE * col - TILE_HALF_SIZE, TILE_SIZE * row - TILE_HALF_SIZE )
        tileMatrix[row][col] = tile
        grid:insert( tile )
    end
end

-- add events and position the grid
grid.x = display.contentCenterX - grid.width * 0.5
grid.y = display.contentCenterY - grid.height * 0.5
grid:addEventListener( "touch", touchHandler )