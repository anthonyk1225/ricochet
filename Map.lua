require 'actors/Hero'
require 'actors/Slime'

Map = Class{}

BLANK = 1
SPIKES = 82
PIT = 78
GRASS_BOTTOM = 22

local SCROLL_SPEED = 100

function Map:init()
  self.spritesheet = love.graphics.newImage("graphics/tileset.png")
  self.tileWidth = 16 -- pixels a tile's width contains
  self.tileHeight = 16 -- pixels a tile's height contains
  
  self.mapHeight = 26 -- tiles laid out on the y axis
  self.floor = self.tileHeight * (self.mapHeight / 2 - 1)
  self.tiles = {}

  self.camX = 0
  self.camY = 0

  -- take the spritesheet and set its width and height
  self.tileSprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)
end

function Map:newGame(level)
  self.level = level
  self.slimes = {}
  self.slimeCount = 0
  self.mapWidth = 55 + (self.level * 3)-- tiles laid out on the x axis
  self.mapWidthPixels = self.mapWidth * self.tileWidth -- total tiles laid out * their pixel width
  self.mapHeightPixels = self.mapHeight * self.tileHeight -- total tiles laid out * their pixel height
  self:createStageTemplate()

  self.hero = Hero(self)
  self:createSlimes()
  self:procGen()
end

function Map:createSlimes()
  for x = 1, self.level do
    local slime = Slime(x, self, self.hero)
    self.slimes[x] = slime
  end
end

function Map:createStageTemplate()
  -- filling the map with empty tiles
  for y = 1, self.mapHeight do
    for x = 1, self.mapWidth do
      self:setTile(x, y, BLANK)
    end
  end

  -- starts halfway down the map, populates with grass
  for y = self.mapHeight / 2, self.mapHeight do
    for x = 1, self.mapWidth do
      local tile = GRASS_BOTTOM
      self:setTile(x, y, tile)
    end
  end
end

function Map:isHeroDead()
  return self.hero.state == "dying"
end

function Map:procGen()
  local x = 8
  while x < self.mapWidth - 5 do
    local roll = math.random(15)
    if roll == 1 or roll == 2 then
      self:setTile(x, self.mapHeight / 2 - 1, SPIKES)
      x = x + 3
    elseif roll == 15 then
      for y = self.mapHeight / 2, self.mapHeight do
        self:setTile(x, y, PIT)
        self:setTile(x + 1, y, PIT)
        self:setTile(x + 2, y, PIT)
      end
      x = x + 6
    end
    x = x + 1
  end
end

function Map:setTile(x, y, tile)
  -- a slick way of taking a 1d array and transforming it into a 2d array
  self.tiles[(y - 1) * self.mapWidth + x] = tile
end

function Map:getTile(x, y)
  -- returning a value from a 1d array as if it were a 2d array
  return self.tiles[(y - 1) * self.mapWidth + x]
end

-- gets the tile at a given pixel coordinate
function Map:tileAt(x, y)
  return {
    x = math.floor(x / self.tileWidth) + 1,
    y = math.floor(y / self.tileHeight) + 1,
    id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
  }
end

function Map:collides(tile)
  local collidables = {
    SPIKES, GRASS_BOTTOM
  }

  for _, v in ipairs(collidables) do
    if tile.id == v then
      return true
    end
  end

  return false
end

function Map:updateDeadSlimes()
  local slimeCount = 0

  for x = 1, #self.slimes do
    if self.slimes[x].isDead == false then
      slimeCount = slimeCount + 1
    end
  end

  self.slimeCount = slimeCount

  if self.slimeCount == 0 and self.hero.state ~= "dying" then
    self.hero.state = "restarting"
    self.hero:changeAnimation()
  end
end

function Map:getHeroState()
  return self.hero.state
end

function Map:update(dt)
  self.camX = math.max(
    0, -- if a number is negative, it will always stay at 0
    math.min(
      (self.hero.x + 25) - VIRTUAL_WIDTH / 2, -- x - 216
      math.min(
        self.mapWidthPixels - VIRTUAL_WIDTH, -- 368
        (self.hero.x + 25) -- x
      )
    )
  )

  self:updateDeadSlimes()

  self.hero:update(dt)
  for x = 1, #self.slimes do
    self.slimes[x]:update(dt)
  end
end

function Map:render()
  for y = 1, self.mapHeight do
    for x = 1, self.mapWidth do
      love.graphics.draw(
        self.spritesheet,
        self.tileSprites[self:getTile(x, y)],
        (x - 1) * self.tileWidth,
        (y - 1) * self.tileHeight
      )
    end
  end

  self.hero:render()

  for x = 1, #self.slimes do
    self.slimes[x]:render(dt)
  end
end
