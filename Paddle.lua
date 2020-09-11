Paddle = Class{}

MAX_SPEED = 300
MIN_SPEED = 100
MAX_HEIGHT = 80
MIN_HEIGHT = 10

function Paddle:init(x, y, width, height, speed, maxSpeed)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dx = 0
    self.dy = 0
    self.speed = speed
    MAX_HEIGHT = height
    MIN_SPEED = speed
    MAX_SPEED = maxSpeed
end

function Paddle:update(dt, windowSize)
    local newPos = self.y + self.dy * dt
    if (self.dy < 0) then
        self.y = math.max(0, newPos)
    else 
        self.y = math.min(windowSize.height - self.height, newPos)
    end
end

function Paddle:updateSpeedAndHeight(ballSpeed)
    self.height = math.max(MIN_HEIGHT, self.height * 0.99)
    local speedCoeff = 0.1
    if (ballSpeed >= self.speed) then
        speedCoeff = ballSpeed / self.speed
    elseif (ballSpeed < self.speed) then
        speedCoeff = math.max(0.5, ballSpeed / self.speed)
    end
    print("ball")
    print(ballSpeed)
    print(self.speed)
    print("SPeed")
    print(speedCoeff)
    self.speed = math.min(math.max(MIN_SPEED, self.speed * speedCoeff), MAX_SPEED)
end

function Paddle:reset() 
    self.height = MAX_HEIGHT
    self.speed = MIN_SPEED
end

function Paddle:render() 
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end