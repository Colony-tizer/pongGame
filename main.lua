push = require "push"

PAD_SIZE = 50;
PLAYERS_SCORE = { 0, 0 }
WINDOWS_SIZE = { 
    ["w"] = 1280, 
    ["h"] = 720, 
    ["vw"] = 432,
    ["vh"] = 243
}
PLAYERS_POS = { 
    {
        ["x"] = 5,
        ["y"] = 10
    },
    {
        ["x"] = WINDOWS_SIZE.vw - 15,
        ["y"] = WINDOWS_SIZE.vh - (PAD_SIZE + 10)                  
    }
}
BALL_POS = {
    ["w"] = 4,
    ["h"] = 4,
    ["x"] = WINDOWS_SIZE.vw / 2 + 1,
    ["y"] = WINDOWS_SIZE.vh / 2 - 1,
    ["dx"] = 0,
    ["dy"] = 0
}
gameState = 'start'

--
-- startup func
-- set vars etc.
--
function love.load()
    love.math.setRandomSeed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.graphics.clear(15 / 255, 15 / 255, 35 / 255, 255 / 255);

    titleFont = love.graphics.setNewFont("font.ttf", 8)

    scoreFont = love.graphics.setNewFont("font.ttf", 32)

    print(WINDOWS_SIZE.vw, WINDOWS_SIZE.vh, WINDOWS_SIZE.w, WINDOWS_SIZE.h)
    push:setupScreen(WINDOWS_SIZE.vw, WINDOWS_SIZE.vh, WINDOWS_SIZE.w, WINDOWS_SIZE.h, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
end
--[[
    Function to handle keypressing
]]
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
    if (key == 'enter' or key == 'return') then
        if (gameState == 'start') then
            gameState = 'game'
            BALL_POS.dx = love.math.random(2) == 1 and 100 or -100 
            BALL_POS.dy = love.math.random(-100, 100) * 1.5
        else 
            gameState = 'start'
            BALL_POS.x =  WINDOWS_SIZE.vw / 2 + 1
            BALL_POS.y = WINDOWS_SIZE.vh / 2 - 1
        end
    end
end
--
-- Update func dt how many ms past from the last update
--
function love.update(dt) 
    if love.keyboard.isDown('w') then
        PLAYERS_POS[1].y = math.max(0, PLAYERS_POS[1].y - 200 * dt)
    end
    if love.keyboard.isDown('s') then
        PLAYERS_POS[1].y = math.min(WINDOWS_SIZE.vh - PAD_SIZE, PLAYERS_POS[1].y + 200 * dt)
    end
    if love.keyboard.isDown('up') then
        PLAYERS_POS[2].y = math.max(0, PLAYERS_POS[2].y - 200 * dt)
    end
    if love.keyboard.isDown('down') then
        PLAYERS_POS[2].y = math.min(WINDOWS_SIZE.vh - PAD_SIZE, PLAYERS_POS[2].y + 200 * dt)
    end
    if (gameState == 'game') then
        BALL_POS.x = BALL_POS.x + BALL_POS.dx * dt
        BALL_POS.y = BALL_POS.y + BALL_POS.dy * dt
    end
end
--
-- Called each frame for drawing things
--
function love.draw()
    push:apply('start')
    love.graphics.setFont(titleFont)
    love.graphics.printf(
        "Hello, world!",
        0, 
        37,
        WINDOWS_SIZE.vw,
        'center'
    )
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(PLAYERS_SCORE[1]), WINDOWS_SIZE.vw / 2 - 65, WINDOWS_SIZE.vh / 3)
    love.graphics.print(tostring(PLAYERS_SCORE[2]), WINDOWS_SIZE.vw / 2 + 50, WINDOWS_SIZE.vh / 3)

    love.graphics.rectangle('fill', PLAYERS_POS[1].x, PLAYERS_POS[1].y, 5, PAD_SIZE)
    love.graphics.rectangle('fill', PLAYERS_POS[2].x, PLAYERS_POS[2].y, 5, PAD_SIZE)
    
    love.graphics.rectangle('fill', BALL_POS.x, BALL_POS.y, BALL_POS.w, BALL_POS.h)
    push:apply('end')
end