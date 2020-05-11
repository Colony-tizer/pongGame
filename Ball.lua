Ball = Class{}

function Ball:init(x, y, width, height) 
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dx = love.math.random(2) == 1 and 100 or -100
    self.dy = love.math.random(-100, 100)
end

function Ball:update(dt, windowSize)
    if (self.y < 0) then
        self.dy = -self.dy
        self.y = self.y + self.dy * dt
    else 
        if (self.y + self.height >= windowSize.height) then
            self.dy = -self.dy
            self.y = self.y - self.height + self.dy * dt 
        else
            self.y = self.y + self.dy * dt    
        end
    end
    self.x = self.x + self.dx * dt
end

function Ball:collides(object) 
    return not ((self.x > object.x + object.width or self.x + self.width < object.x) or
             (self.y > object.y + object.height or self.y + self.height < object.y))
end

function Ball:render() 
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, 5, 5)
end

function Ball:reset(posX, posY) 
    self.x = posX
    self.y = posY
end