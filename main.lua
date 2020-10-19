Class = require './hump/class'
push = require './push/push'

require 'util'
require 'Map'

-- close resolution to NES but 16:9
VIRTUAL_WIDTH = 432 -- width of screen
VIRTUAL_HEIGHT = 243 -- height of screen

-- actual window resolution. Not sure on this one
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

START_GAME = false
PAUSE_GAME = false

love.graphics.setDefaultFilter('nearest', 'nearest')

sounds = {
  ['explosion'] = love.audio.newSource("sounds/Explosion.wav", "static"),
  ['shoot'] = love.audio.newSource("sounds/Shoot.wav", "static"),
  ['jump'] = love.audio.newSource("sounds/Jump.wav", "static"),
  ['slimejump'] = love.audio.newSource("sounds/SlimeJump.wav", "static"),
  ['backgroundmusic'] = love.audio.newSource("sounds/BackgroundMusic.mp3", "static"),
  ['death'] = love.audio.newSource("sounds/Death.mp3", "static")
}

function love.load()
  math.randomseed(os.time())
  smallFont = love.graphics.newFont("/fonts/04B03.ttf", 8)
  largeFont = love.graphics.newFont("/fonts/04B03.ttf", 14)
  map = Map()

  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = true,
    resizable = true,
    vsync = true
  })

  background = love.graphics.newImage("graphics/background.png")

  love.window.setTitle('Ricochet')

  love.keyboard.keysPressed = {}
end

function love.keyboard.wasPressed(key)
  return love.keyboard.keysPressed[key]
end

-- called every frame
function love.update(dt)
  if START_GAME and PAUSE_GAME == false then map:update(dt) end

  love.keyboard.keysPressed = {}
end

-- called whenever window is resized
-- function love.resize(w, h)
--   push:resize(w, h)
-- end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end

  if key == "n" and START_GAME == false then
    sounds["backgroundmusic"]:setLooping(true)
    sounds["backgroundmusic"]:play()
    START_GAME = true
    map:newGame(1)
  end

  love.keyboard.keysPressed[key] = true
end

function love.touchpressed(id, x, y, dx, dy, pressure)
  if START_GAME == false then
    sounds["backgroundmusic"]:setLooping(true)
    sounds["backgroundmusic"]:play()
    START_GAME = true
    map:newGame(1)
  elseif PAUSE_GAME == false and START_GAME == true and map:getHeroState() ~= "dying" then
    x, y = push:toGame(x, y)
    y = y + map.camY

    if y < map.floor - 15 then PAUSE_GAME = true end
  elseif PAUSE_GAME == true then PAUSE_GAME = false end
end

function displayLevel()
  love.graphics.setColor(189, 195, 199, 1.0)
  love.graphics.setFont(smallFont)
  love.graphics.printf("Level " .. map.level, map.camX + 10, 10, VIRTUAL_WIDTH, "left")
  love.graphics.printf("Enemies - " .. map.slimeCount, map.camX, 10, VIRTUAL_WIDTH, "center")
end

function gameOver()
  if map:isHeroDead() == true then
    love.graphics.setColor(189, 195, 199, 1.0)
    love.graphics.setFont(largeFont)
    love.graphics.printf("Game Over", map.camX, 100, VIRTUAL_WIDTH, "center")
    love.graphics.setFont(smallFont)
    love.graphics.printf("Tap to start a new game", map.camX, 144, VIRTUAL_WIDTH, "center")
  end
end

function startGameScreen()
  love.graphics.setFont(largeFont)
  love.graphics.printf("Ricochet", map.camX, 100, VIRTUAL_WIDTH, "center")
  love.graphics.setFont(smallFont)
  love.graphics.printf("Tap to start", map.camX, 144, VIRTUAL_WIDTH, "center")
end

function loadingScreen()
  if START_GAME == true and map:getHeroState() == "restarting" then
    love.graphics.setFont(largeFont)
    love.graphics.printf("GET READY...", map.camX, 80, VIRTUAL_WIDTH, "center")
  end
end

function pauseScreen()
  if PAUSE_GAME == true then
    love.graphics.setFont(largeFont)
    love.graphics.printf("PAUSED", map.camX, 100, VIRTUAL_WIDTH, "center")
  end
end

function love.draw()
  push:apply('start')
  local w, h = love.window.getDesktopDimensions()
  push:resize(w, h)

  love.graphics.clear(112 / 255, 106 / 255, 96 / 255, 1.0)
  love.graphics.translate(-map.camX, -map.camY)

  if START_GAME == true then
    for i = 0, WINDOW_WIDTH / background:getWidth() do
      for j = 0, WINDOW_HEIGHT / background:getHeight() do
          love.graphics.draw(background, i * background:getWidth(), j * background:getHeight())
      end
    end
    map:render()
    displayLevel()
    gameOver()
  else
    for i = 0, WINDOW_WIDTH / background:getWidth() do
      for j = 0, WINDOW_HEIGHT / background:getHeight() - 3 do
          love.graphics.draw(background, i * background:getWidth(), j * background:getHeight())
      end
    end
    startGameScreen()
  end

  loadingScreen()
  pauseScreen()

  push:apply('end')
end
