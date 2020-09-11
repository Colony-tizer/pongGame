push = require "push"
Class = require "class"
require "Paddle"
require "Ball"
inspect = require "inspect"
-- DEBUG to enable pause feature, ball positioning by left mouse button, display of collision with pad, position of ball
DEBUG = false
-- init height of pads
PAD_SIZE = 40
-- the number of lines describing ball's trajectory
TRACE_LINES_LIMIT = 200

-- the win condition
MAX_SCORE = 5
-- scores of players
PLAYERS_SCORE = { 0, 0 }
-- window info
WINDOWS_SIZE = { 
    ["width"] = 1280, 
    ["height"] = 720, 
    ["virtual"] = {
        ["width"] = 432,
        ["height"] = 243
    }
}
--[[
    states of game:
    start - welcome screen
    game - main state, ball moves
    pause - ball stops
    finish - one player hit MAX_SCORE
    serve - one player hit a score
]]
GAME_STATES = {
    ["start"] = 0,
    ["game"] = 1,
    ["pause"] = 2,
    ["finish"] = 3,
    ["serve"] = 4
}
HELP_TEXT = "Hello, pong\nTo control left pad use W and S\nTo control right pad use ARROW_UP and ARROW_DOWN\nBall accelerates each time when touches pad\nPlayers can adjust ball speed by moving their pads down or up at the moment of touch\nTo accelerate ball players should move their pads in direction of ball vertical direction at the moment of touch\nThe first to score 5 wins\nENTER to start\nESC to quit"
-- global var for game states
gameState = GAME_STATES["start"]
-- text to appear at top of the screen
infoText = HELP_TEXT
--
-- startup func
-- set vars etc.
--
function love.load()
    -- loading sounds
    sounds = {
        ['padSound'] = love.audio.newSource("/sounds/paddle_hit.wav", 'static'),
        ['wallSound'] = love.audio.newSource("/sounds/wall_hit.wav", 'static'),
        ['scoreSound'] = love.audio.newSource("/sounds/score.wav", 'static')
    }
    -- init of rng
    love.math.setRandomSeed(os.time())
    -- set graphical filter and bg color
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.clear(15 / 255, 15 / 255, 35 / 255, 255 / 255);
    -- init fonts
    smallFont = love.graphics.setNewFont("font.ttf", 8)
    titleFont = love.graphics.setNewFont("font.ttf", 8)
    scoreFont = love.graphics.setNewFont("font.ttf", 32)
    if (DEBUG) then
        -- shows window properties in console
        print(WINDOWS_SIZE.virtual.width, WINDOWS_SIZE.virtual.height, WINDOWS_SIZE.width, WINDOWS_SIZE.height)
    end
    push:setupScreen(WINDOWS_SIZE.virtual.width, WINDOWS_SIZE.virtual.height, WINDOWS_SIZE.width, WINDOWS_SIZE.height, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })
    -- init main elements
    ball = Ball(WINDOWS_SIZE.virtual.width / 2 + 1, WINDOWS_SIZE.virtual.height / 2 - 1, 9, 9, DEBUG)
    player1Obj = Paddle(5, 10, 5, PAD_SIZE, ball.minSpeed, ball.superSpeed, DEBUG)
    player2Obj = Paddle(WINDOWS_SIZE.virtual.width - 15, WINDOWS_SIZE.virtual.height - (PAD_SIZE + 10), 5, PAD_SIZE, ball.minSpeed, ball.superSpeed, DEBUG)
end
--[[
    Function to handle resizing
]]
function love.resize(w, h)
    push:resize(w, h)
end
--[[
    Function to handle keypressing
]]
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
    -- enter to initiate action
    if (key == 'enter' or key == 'return') then
        if (gameState == GAME_STATES["start"]) then
            -- launches game with random direction of ball
            infoText = " "
            -- resets pads
            player1Obj:reset()
            player2Obj:reset()
            ball:setRandomVelocity()
            -- transition to game state
            gameState = GAME_STATES["game"]
        elseif (gameState == GAME_STATES["serve"]) then
            -- launches game with ball moving toward player lost last match
            infoText = " "
            player1Obj:reset()
            player2Obj:reset()
            -- transition to game state
            gameState = GAME_STATES["game"]
        elseif (gameState == GAME_STATES["finish"]) then
            infoText = HELP_TEXT
            PLAYERS_SCORE = {0, 0}
            -- transition to start state
            gameState = GAME_STATES["start"]
            ball:reset(WINDOWS_SIZE.virtual.width / 2, WINDOWS_SIZE.virtual.height / 2)
            player1Obj:reset()
            player2Obj:reset()
        end
    end
    if (key == 'space' and DEBUG) then
        -- pauses game
        if (gameState == GAME_STATES["game"]) then
            gameState = 'pause'
        else if (gameState == 'pause') then
                gameState = GAME_STATES["game"]
            end
        end
    end
end
--
-- Update func dt how many ms past from the last update
--
function love.update(dt) 
    if (love.mouse.isDown(1) and DEBUG) then
        -- moving ball to cursor
        ball.x = love.mouse.getX() * (WINDOWS_SIZE.virtual.width / WINDOWS_SIZE.width)
        ball.y = love.mouse.getY() * (WINDOWS_SIZE.virtual.height / WINDOWS_SIZE.height)
        ball.prevX = ball.x
        ball.prevY = ball.y
    end
    -- PLAYER 1 CONTROLS
    if love.keyboard.isDown('w') then
        player1Obj.dy = -player1Obj.speed
    elseif love.keyboard.isDown('s') then
        player1Obj.dy = player1Obj.speed
    else 
        player1Obj.dy = 0
    end
    --------------------

    -- PLAYER 1 CONTROLS
    if love.keyboard.isDown('up') then
        player2Obj.dy = -player2Obj.speed
    elseif love.keyboard.isDown('down') then
        player2Obj.dy = player2Obj.speed
    else 
        player2Obj.dy = 0
    end
    --------------------
    player1Obj:update(dt, WINDOWS_SIZE.virtual)
    player2Obj:update(dt, WINDOWS_SIZE.virtual)

    if (gameState == GAME_STATES["game"]) then
        -- colliding flag (whether ball hit pad or not)
        local isBallCollidedPad = false;
        
        if (ball:collidesWall(WINDOWS_SIZE.virtual)) then
            sounds['wallSound']:play()
        end

        ball:update(dt, WINDOWS_SIZE.virtual)
        
        if (ball.dx > 0) then
            --[[ 
                if ball moves to the right part of screen then
                check collision with PLAYER 2 pad 
            ]]
            isBallCollidedPad = detectCollisionAndUpdate(player2Obj)
            if (isBallCollidedPad == false and ball.x > WINDOWS_SIZE.virtual.width) then
                --[[ 
                    if ball didn't collide with pad and beyond screen boundaries then
                    score goes to PLAYER 1
                ]]
                sounds['scoreSound']:play()
                -- transition to server state
                gameState = GAME_STATES["serve"]
                infoText = "Player2 serves\nPress ENTER when ready"
                PLAYERS_SCORE[1] = PLAYERS_SCORE[1] + 1 
                ball:reset(WINDOWS_SIZE.virtual.width / 2, WINDOWS_SIZE.virtual.height / 2)
                ball:setRandomVelocity()
                -- direct ball toward lost player
                ball:setNewDx(math.abs(ball.dx))
            end
        elseif (ball.dx < 0) then
            --[[ 
                if ball moves to the left part of screen then
                check collision with PLAYER 2 pad 
            ]]
            isBallCollidedPad = detectCollisionAndUpdate(player1Obj)
            if (isBallCollidedPad == false and ball.x + ball.width < 0) then
                --[[ 
                    if ball didn't collide with pad and beyond screen boundaries then
                    score goes to PLAYER 2
                ]]
                sounds['scoreSound']:play()
                -- transition to server state
                gameState = GAME_STATES["serve"]
                infoText = "Player1 serves\nPress ENTER when ready"
                PLAYERS_SCORE[2] = PLAYERS_SCORE[2] + 1
                ball:reset(WINDOWS_SIZE.virtual.width / 2, WINDOWS_SIZE.virtual.height / 2)
                ball:setRandomVelocity()
                -- direct ball toward lost player
                ball:setNewDx(-math.abs(ball.dx))
            end
        end
        if (isBallCollidedPad == false and (PLAYERS_SCORE[1] == MAX_SCORE or PLAYERS_SCORE[2] == MAX_SCORE)) then
            --[[ 
                if ball didn't collide and any player hit MAX_SCORE then
                finishes game
            ]]
            -- transition to finish state
            gameState = GAME_STATES["finish"]
            infoText = "Congratulations, ";
            infoText = (PLAYERS_SCORE[1] == MAX_SCORE) and string.format("%s%s", infoText, "Player1!") or string.format("%s%s", infoText, "Player2!") 
            infoText = string.format("%s%s", infoText, "\nPress ENTER to start again\nPress ESC to quit")
        end
    end
end

--[[ 
    detectCollisionAndUpdate(playerObject)
    Arguments: Paddle playerObject - pad
    Description: detects collision with specified pad and if there was collision then
        updates pad properties and ball speed
]]
function detectCollisionAndUpdate(playerObject)
    local isBallCollidedPad = false;
    if (ball:collidesSide(playerObject)) then
        -- if ball collided side of the pad
        isBallCollidedPad = true;
        -- changes pad speed and height
        -- if ball horizontal speed (dx) is 1.3 times greater than vertical speed (dy) then
        -- pad speed takes dx as base for it's [pad's] speed 
        -- otherwise pad takes vertical speed (dy)
        playerObject:updateSpeedAndHeight((math.abs(ball.dx / ball.dy) < 1.3) and math.abs(ball.dy) or math.abs(ball.dx))
        -- if collision detected then this means that ball actually is IN the pad
        -- next block moves ball to the pad boundary 
        if (ball.dx > 0) then
            ball.x = playerObject.x - ball.width
        else 
            ball.x = playerObject.x + playerObject.width
        end
        -- change ball direction toward opponent
        ball:setNewDx(-ball.dx)
        -- calculates coeff for ball dy (vertical speed)
        -- dx is continuously increases by 4% of current speed
        local speedMultiplier = 0.03
        if (math.abs(ball.dy) > math.abs(playerObject.dy + ball.dy)) then
            -- if pad moves in opposite direction of ball then coeff is negative
            -- ball slows a bit (by 4% of current speed) 
            speedMultiplier = -speedMultiplier - 0.1
        elseif (math.abs(ball.dy) < math.abs(playerObject.dy + ball.dy)) then
            -- if pad moves in the direction of ball then coeff is positive
            -- ball is accelerated by 8% of current speed 
            speedMultiplier = speedMultiplier + 0.05
        end
        if (math.abs(ball.dx) <= 1.3 * (ball.superSpeed) and math.abs(ball.dx / ball.dy) <= 1.3) then
            -- if ball vertical speed (dy) is 1.3 times less than horizontal speed (dx) and 
            -- dx less or equals 1.3 times of max speed
            -- then dx is increased by 4%
            ball:setNewDx(ball.dx + ball.dx * 0.04)
        end
        if (math.abs(ball.dy) <= ball.superSpeed) then
            -- if ball vertical speed (dy) is less than max speed
            -- then dy is increased by coeff
            ball:setNewDy(ball.dy + ball.dy * speedMultiplier)
        end
    elseif (ball:collidesTop(playerObject)) then
        -- if ball collided top then horizontal direction is not changed
        -- ball just bounces out of top side of pad going out of screen boundaries
        isBallCollidedPad = true;
        playerObject:updateSpeedAndHeight((math.abs(ball.dx / ball.dy) < 1.3) and math.abs(ball.dy) or math.abs(ball.dx))
        ball.y = playerObject.y - ball.width
        ball:setNewDy(-ball.dy)
    elseif (ball:collidesBot(playerObject)) then
        isBallCollidedPad = true;
        playerObject:updateSpeedAndHeight((math.abs(ball.dx / ball.dy) < 1.3) and math.abs(ball.dy) or math.abs(ball.dx))
        ball.y = playerObject.y + playerObject.height + ball.width
        ball:setNewDy(-ball.dy)
    end
    -- plays sound if collided pad
    if (isBallCollidedPad) then
        sounds['padSound']:play()
    end
    return isBallCollidedPad
end
--
-- Called each frame for drawing things
--
function love.draw()
    -- using push to make pixel style graphics
    push:apply('start')
    love.graphics.setFont(titleFont)
    -- print text
    love.graphics.printf(
        infoText,
        0, 
        20,
        WINDOWS_SIZE.virtual.width,
        'center'
    )
    -- draws ball trajectory if speed is high
    --if (math.abs(ball.dx + ball.dy) > ball.superSpeed ) then
    if (ball.dx ~= 0 and ball.dy ~= 0) then
        drawTrace()
    end
    --end
    -- draws players score
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(PLAYERS_SCORE[1]), WINDOWS_SIZE.virtual.width / 2 - 65, WINDOWS_SIZE.virtual.height / 3)
    love.graphics.print(tostring(PLAYERS_SCORE[2]), WINDOWS_SIZE.virtual.width / 2 + 50, WINDOWS_SIZE.virtual.height / 3)
    -- draws pads
    player1Obj:render()
    player2Obj:render()
    -- draws debug info about collision pad with ball
    if (DEBUG) then
        love.graphics.setFont(smallFont)
        love.graphics.setColor(0, 170 / 255, 60 / 255, 1)
        love.graphics.print(tostring(ball:collides(player1Obj)), player1Obj.x + player1Obj.width + 5, player1Obj.y)
        love.graphics.print(tostring(ball:collides(player2Obj)), player2Obj.x - 25, player2Obj.y)
        love.graphics.print(tostring(player1Obj.speed), player1Obj.x + player1Obj.width + 5, player1Obj.y + 10)
        love.graphics.print(tostring(player2Obj.speed), player2Obj.x - 25, player2Obj.y + 10)
    end
    -- draws ball on top of everything
    ball:render()
    push:apply('end')
end
--[[ 
    drawTrace()
    Description: calculates and draws trajectory of ball 
]]
function drawTrace()  
    local coeff = 0
    local dy = ball.dy
    -- array of calculated positions of ball
    local points = {}
    -- start point from which next position will be calculated
    local startPoint = {ball.x + ball.width / 2, ball.y + ball.height / 2}
    
    table.insert(points, startPoint[1])
    table.insert(points, startPoint[2])
    -- while startPoint is within screen and number of calculated points is less than TRACE_LINES_LIMIT
    while (startPoint[1] >= 0 and startPoint[1] <= WINDOWS_SIZE.virtual.width 
            and table.getn(points) < TRACE_LINES_LIMIT * 2) do
        -- next point coordinates: {x, y}
        local nextPoint = {startPoint[1], startPoint[2]}
        -- vertical direction is the only direction which will be changed in course of calculations
        if (dy < 0) then
            -- if moving up
            -- TODO: think about explanation. there is prob system of equations
            -- calculates coeff to satisfy equation x = y / a , (x, y from prev point)
            -- where y is whether 0 or WINDOWS_SIZE.virtual.height
            coeff = (startPoint[2]) / dy
            nextPoint[2] = ball.height / 2
        elseif (dy > 0) then
            coeff = (WINDOWS_SIZE.virtual.height - startPoint[2]) / dy
            nextPoint[2] = WINDOWS_SIZE.virtual.height - ball.height / 2
        else
            -- impossible case when dy is 0
            -- aborting calculating trajectory
            break 
        end
        -- changing direction of moving because of hit of top/bot of screen
        dy = -dy;
        nextPoint[1] =  startPoint[1] + math.abs(coeff) * ball.dx
        table.insert(points, nextPoint[1])
        table.insert(points, nextPoint[2])
        startPoint = {nextPoint[1], nextPoint[2]}
    end
    
    -- if trajectory array contains even number of points then draw connections between each calculated position
    if (table.getn(points) > 3 and table.getn(points) % 2 == 0) then
        love.graphics.setColor(0.09, 0.09, 0.09, (math.abs(ball.dx) + math.abs(ball.dy)) / (3.5 * ball.superSpeed))
        love.graphics.setLineWidth(ball.width)
        love.graphics.line(points)
        love.graphics.setColor(0.2, 0.2, 0.2, (math.abs(ball.dx) + math.abs(ball.dy)) / (3 * ball.superSpeed))
        love.graphics.setLineWidth(1)
        love.graphics.line(points)
    end
end