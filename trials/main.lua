-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide status bar
display.setStatusBar( display.HiddenStatusBar )

-- set default screen background color to blue
display.setDefault( "background", 197/255, 224/255, 220/255 )

-- require the widget library
local widget = require "widget"

-- active multitouch
system.activate( "multitouch" )

-- require the physics library
local physics = require "physics"
--physics.setDrawMode( "hybrid" )
physics.start()
physics.setGravity( 0, 9.8 )

-- constants
local screenW, screenH = display.actualContentWidth, display.actualContentHeight
local centerX, centerY = display.contentCenterX, display.contentCenterY
local originX, originY = display.screenOriginX, display.screenOriginY

-- variables
local horizontal = 0
local vertical = 0
local level = display.newGroup()

-----------------------------------------------------------------------------------------

local ground = display.newRect( 0, 0, screenW * 5, 100 )
ground:setFillColor( 0/255, 153/255, 76/255 )
ground.anchorX, ground.anchorY = 0, 1
ground.x, ground.y = originX, originY + screenH
physics.addBody( ground, "static", { density=1, friction=0.3, bounce=0 } )

local obstacle1 = display.newPolygon( 0, 0, { -40,0, 40,0, 0,-40 } )
obstacle1:setFillColor( 119/255, 79/255, 56/255 )
obstacle1.anchorX, obstacle1.anchorY = 0.5, 1
obstacle1.x, obstacle1.y = centerX + 200, ground.y - ground.height
physics.addBody( obstacle1, "static", { friction=0.3, shape={ -40,20, 40,20, 0,-20 } } )

local obstacle2 = display.newPolygon( 0, 0, { -80,0, 80,0, 0,-60 } )
obstacle2:setFillColor( 119/255, 79/255, 56/255 )
obstacle2.anchorX, obstacle2.anchorY = 0.5, 1
obstacle2.x, obstacle2.y = centerX + 700, ground.y - ground.height
physics.addBody( obstacle2, "static", { friction=0.3, shape={ -80,30, 80,30, 0,-30 } } )

local box1 = display.newRect( 0, 0, 15, 30 )
box1:setFillColor( 220/255, 20/255, 60/255 )
box1.anchorX, box1.anchorY = 0.5, 1
box1.x, box1.y = centerX + 1000, ground.y - ground.height
physics.addBody( box1, "dynamic", { density=1, friction=0.5 } )

local box2 = display.newRect( 0, 0, 15, 30 )
box2:setFillColor( 220/255, 20/255, 60/255 )
box2.anchorX, box2.anchorY = 0.5, 1
box2.x, box2.y = box1.x, box1.y - box1.height
physics.addBody( box2, "dynamic", { density=1, friction=0.5 } )

level:insert( ground )
level:insert( obstacle1 )
level:insert( obstacle2 )
level:insert( box1 )
level:insert( box2 )

-----------------------------------------------------------------------------------------

local cart = display.newImageRect( "truck.png", 95, 39 )
cart.x, cart.y = centerX, centerY
physics.addBody( cart, "dynamic", { density=1, friction=0.5, bounce=0.2, filter={ groupIndex=-1 } } )

local wheel1 = display.newImageRect( "wheel.png", 30, 30 )
wheel1.x, wheel1.y = cart.x - 27, cart.y + 24
physics.addBody( wheel1, "dynamic",
    { density=1, friction=5, bounce=0.2, filter={ groupIndex=-1 }, radius=15 }
)

local wheel2 = display.newImageRect( "wheel.png", 30, 30 )
wheel2.x, wheel2.y = cart.x + 27, cart.y + 24
physics.addBody( wheel2, "dynamic",
    { density=1, friction=5, bounce=0.2, filter={ groupIndex=-1 }, radius=15 }
)

local wheelJoint1 = physics.newJoint( "wheel", cart, wheel1, wheel1.x, wheel1.y, 0, 10 )
wheelJoint1.springDampingRatio = 1
wheelJoint1.springFrequency = 10

local wheelJoint2 = physics.newJoint( "wheel", cart, wheel2, wheel2.x, wheel2.y, 0, 10 )
wheelJoint2.springDampingRatio = 1
wheelJoint2.springFrequency = 10

level:insert( cart )
level:insert( wheel1 )
level:insert( wheel2 )	

-----------------------------------------------------------------------------------------

local function enterFrame( event )
    if horizontal > 0 then
        wheel1:applyTorque( 10 )
        wheel2:applyTorque( 10 )
    elseif horizontal < 0 then
        wheel1:applyTorque( -10 )
        wheel2:applyTorque( -10 )
    end
    
    cart:applyTorque( 80 * vertical )
    
    cart.parent.x = centerX - cart.x
end
Runtime:addEventListener( "enterFrame", enterFrame )

local function controlHandler( event )
    local id = event.target.id
    local phase = event.phase
    
    if phase == "began" or phase == "moved" then
        if id == "forward" then
            horizontal = 1
        elseif id == "backward" then
            horizontal = -1
        end
        if id == "rotate-back" then
            vertical = -1
        elseif id == "rotate-forward" then
            vertical = 1
        end
    else
        if id == "forward" or id == "backward" then
            horizontal = 0
        end
        if id == "rotate-back" or id == "rotate-forward" then
            vertical = 0
        end
    end
end

local btnForward = widget.newButton{
    defaultFile = "btn_arrow.png",
    width=50, height=50,
    id="forward",
    onEvent=controlHandler
}
btnForward.x = originX + screenW - btnForward.height * 0.5 - 5
btnForward.y = originY + screenH - btnForward.height * 0.5 - 5

local btnBackward = widget.newButton{
    defaultFile = "btn_arrow.png",
    width=50, height=50,
    id="backward",
    onEvent=controlHandler
}
btnBackward.rotation = 180
btnBackward.x = btnForward.x - btnForward.width - 5
btnBackward.y = btnForward.y

local btnRotBack = widget.newButton{
    defaultFile = "btn_rotate.png",
    width=50, height=50,
    id="rotate-back",
    onEvent=controlHandler
}
btnRotBack.x = originX + btnRotBack.width * 0.5 + 5
btnRotBack.y = originY + screenH - btnRotBack.height * 0.5 - 30
btnRotBack.rotation = 90
btnRotBack.yScale = -1

local btnRotForward = widget.newButton{
    defaultFile = "btn_rotate.png",
    width=50, height=50,
    id="rotate-forward",
    onEvent=controlHandler
}
btnRotForward.x = btnRotBack.x + btnRotForward.width + 5
btnRotForward.y = originY + screenH - btnRotForward.height * 0.5 - 5
btnRotForward.rotation = 90