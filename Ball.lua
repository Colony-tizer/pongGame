Ball = Class{}

DEBUG = false

COLLISION_DIRECTION = {
    ["side"] = 0,
    ["top"] = 1,
    ["bot"] = 2
}
-- max speed
SUPER_SPEED = 400
MIN_SPEED = 130

function Ball:init(x, y, width, height, debugFlag) 
    self.superSpeed = SUPER_SPEED;
    self.minSpeed = MIN_SPEED;
    self.x = x
    self.y = y
    -- previous coordinates to detect collision at hight speeds
    self.prevX = x
    self.prevY = y
    self.width = width
    self.height = height
    -- speed at X, Y axises
    self.dx = 0
    self.dy = 0
    if (debugFlag == false or debugFlag == true) then
        DEBUG = debugFlag
    end
end

function Ball:update(dt, windowSize)
    self.prevX = self.x
    self.prevY = self.y
    if (self.y <= 0) then
        self.dy = -self.dy
        self.y = self.dy * dt
    elseif (self.y + self.height >= windowSize.height) then
            self.dy = -self.dy
            self.y = windowSize.height - self.height + self.dy * dt 
        else
            self.y = self.y + self.dy * dt    
    end
    self.x = self.x + self.dx * dt
end
-- takes window properties and check whether ball hit top or bottom of screen
function Ball:collidesWall(windowSize)
    return (self.y <= 0) or (self.y + self.height >= windowSize.height)
end
-- return BOOL whether ball collides with side of object  
function Ball:collidesSide(object)
    return self:collides(object, COLLISION_DIRECTION["side"])
end
-- return BOOL whether ball collides with top part of object  
function Ball:collidesTop(object)
    return self:collides(object, COLLISION_DIRECTION["top"])
end
-- return BOOL whether ball collides with bottom part of object  
function Ball:collidesBot(object)
    return self:collides(object, COLLISION_DIRECTION["bot"])
end
-- return BOOL
--[[
    Paddle|Ball object - object with which collision should be checked
    direction - part of object with which collision should be checked
]]
function Ball:collides(object, direction)
    -- checks whether any part of ball is in the width of the object
    local isInWidth = ((self.x <= object.x + object.width and self.x > object.x) or 
        (self.x + self.width >= object.x and self.x <= object.x) or 
        (self.x >= object.x and self.x + self.width <= object.x + object.width))
    local answer = false
    if (direction == COLLISION_DIRECTION["side"]) then
        -- collision with side part of object

        -- checks whether ball is in the height of object
        local isInHeight = (self.y >= object.y and self.y + self.height <= object.y + object.height)
        -- checks whether any edge of ball touches any edge of object
        -- TODO: recheck this!
        local isEdgeCase = ((self.y + self.height >= object.y and self.y <= object.y) 
            or (self.y <= object.y + object.height and self.y + self.height >= object.y + object.height)) 
            and ((self.dx > 0 and self.prevX <= object.x) or (self.dx < 0 and self.prevX >= object.x + object.width))
        -- check whether ball collided with side of object from the last postion of ball
        local isPassedWidth = (self.prevX + self.width <= object.x and self.x >= object.x + object.width) 
            or (self.prevX >= object.x and self.x < object.x)

        answer = (isInHeight or isEdgeCase) and (isInWidth or isPassedWidth)
    elseif (direction == COLLISION_DIRECTION["top"]) then
        -- collision with top part of object

        -- checks whether ball collides with top part of object or not
        -- checks if ball at least at the top of object and last X position of ball is g
        local isTop = (self.dy >= 0 and self.y + self.height >= object.y and self.y <= object.y 
            and ((self.dx > 0 and self.prevX + self.width >= object.x) or (self.dx < 0 and self.prevX <= object.x + object.width)))
        local isPassedTop = (self.prevY + self.height <= object.y and self.y + self.height >= object.y)
        answer = isInWidth and (isTop or isPassedTop)
    elseif (direction == COLLISION_DIRECTION["bot"]) then
        local isBot = (self.dy <= 0 and self.y <= object.y + object.height 
            and self.y + self.height >= object.y + object.height and self.prevX <= object.x + object.width)
        local isPassedBot = (self.prevY >= object.y + object.height 
            and self.y <= object.y + object.height and self.y + self.height <= object.y + object.height)
        answer = isInWidth and (isBot or isPassedBot)
    else 
        answer = self:collidesSide(object) or (self:collidesBot(object) or self:collidesTop(object))
    end
    return answer
end

function Ball:setRandomVelocity() 
    local sign = love.math.random(2) == 1 and 1 or -1
    self.dx = sign * math.max(self.minSpeed, ((0.1 + love.math.random()) * self.minSpeed))
    sign = love.math.random(2) == 1 and 1 or -1
    self.dy = sign * math.max(self.minSpeed, ((0.5 + love.math.random()) * self.minSpeed))
end

function Ball:setNewDx(dx)
    self.dx = (dx < 0) and math.min(-self.minSpeed, dx) or math.max(self.minSpeed, dx)
end

function Ball:setNewDy(dy)
    self.dy = (dy < 0) and math.min(-self.minSpeed, dy) or math.max(self.minSpeed, dy)
end

function Ball:render()
    local posX = self.x + self.width / 2;
    local posY = self.y - 10
    if (posX < 0) then
        posX = math.max(self.width + 10, posX)
    else
        posX = math.min(432 - self.width - 10, posX) 
    end
    if (posY - 20 < 0) then
        posY = math.max(self.height + 10, posY)
    else
        posY = math.min(243 - self.height - 10, posY) 
    end
    love.graphics.setColor(170 / 255, 170 / 255, 160 / 255, 1)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    if (DEBUG) then
        love.graphics.setColor(0, 170 / 255, 60 / 255, 1)
        love.graphics.print(tostring((self.dy)), posX, posY)
        love.graphics.print(tostring((self.dx)), posX, posY - 10)
    end
end

function Ball:reset(posX, posY) 
    self.x = posX
    self.y = posY
    self.prevX = posX
    self.prevY = posY
    self.dx = 0
    self.dy = 0
end