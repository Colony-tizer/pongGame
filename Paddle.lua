Paddle = Class{}

function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
end

function Paddle:collides(object) 
    return not ((self.x > object.x + object.width or self.x + self.width < object.x) or
             (self.y > object.y + object.height or self.y + self.height < object.y))
end

function Paddle:update(dt, windowSize)
    local newPos = self.y + self.dy * dt
    if (self.dy < 0) then
        self.y = love.math.max(0, newPos)
    else 
        self.y = love.math.min(windowSize.height - self.height / 2, newPos)
    end
end



function Paddle:render() 
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end