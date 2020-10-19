require 'actors/Enemy'

Slime = Class{__includes = Enemy}

local MOVING_SPEED = 100
local GRAVITY = 15

function Slime:init(id, map, hero)
  self.id = id
  self.map = map
  self.hero = hero
  self.width = 32
  self.height = 25

  self.standingWidth = 24
  self.standingHeight = 12

  self.offsetStandingWidth = (self.width - self.standingWidth) / 2
  self.offsetStandingHeight = (self.height - self.standingHeight) / 2

  self.x = self.map.tileWidth * math.random(24, 50) -- x tiles to the right
  self.y = self.map.floor - self.height

  self.dy = 0
  self.dx = -MOVING_SPEED

  self.isDead = false

  self.texture = love.graphics.newImage("graphics/slime.png")
  self.frames = generateQuads(self.texture, self.width, self.height)

  self.state = "running"
  self.direction = "right" -- right is left and left is right
  local randomDirection = math.random(2)
  if randomDirection == 1 then
    self.direction = "left"
    self.dx = MOVING_SPEED
  end

  self.animations = {
    ["idle"] = Animation {
      texture = self.texture,
      frames = {
        self.frames[1], self.frames[2], self.frames[3], self.frames[4],
      },
      interval = 0.20
    },
    ["running"] = Animation {
      texture = self.texture,
      frames = {
        self.frames[5], self.frames[6], self.frames[7], self.frames[8],
      },
      interval = 0.10
    },
    ["jumping"] = Animation {
      texture = self.texture,
      frames = {
        self.frames[5], self.frames[6], self.frames[7], self.frames[8],
      },
      interval = 0.10
    },
    ["dying"] = Animation {
      texture = self.texture,
      frames = {
        self.frames[14], self.frames[15], self.frames[16], self.frames[17],
        self.frames[18], self.frames[19], self.frames[20], self.frames[21]
      },
      interval = 0.15
    }
  }

  self.animation = self.animations[self.state]

  self.behaviors = {
    ["idle"] = function(dt)
    end,
    ["running"] = function(dt)
      self:hasBeenHit(hero.projectile)
      self:hasCollision(0)
      self:shouldJump()
      if self.hero.state ~= "dying" and self.hero.state ~= "restarting" then
        self:collidesWithHero(self.hero)
      end
      self:patrol(MOVING_SPEED)
      if self:isFalling() then
        self.state = "jumping"
        self:changeAnimation()
      end
    end,
    ["jumping"] = function(dt)
      self:hasBeenHit(hero.projectile)
      self:hasCollision(0)
      if self.hero.state ~= "dying" and self.hero.state ~= "restarting" then
        self:collidesWithHero(self.hero)
      end
      self:patrol(MOVING_SPEED)
      self.dy = self.dy + GRAVITY

      -- if not self:isFalling() then -- jumps twice when landing if I use this function
      -- end
      if self.y + self.height > VIRTUAL_HEIGHT + 50 then
        self:dead()
      end

      if self.map:collides(self.map:tileAt(self.x + self.offsetStandingWidth, self.y + self.height)) or
        self.map:collides(self.map:tileAt(self.x + (self.width - self.offsetStandingWidth) - 1, self.y + self.height)) then
          self.dy = 0
          self.state = "running"
          self.animation = self.animations[self.state]
          self.y = (self.map:tileAt(self.x, self.y + self.height).y - 1) * self.map.tileHeight - self.height
      end
    end,
    ["dying"] = function(dt)
      self.dx = 0
      self.dy = 0
      if self.animations[self.state].currentFrame == 8 then
        self.isDead = true
        self.x = -1000
        self.y = -1000
      end
    end
  }
end

function Slime:shouldJump()
  if self.direction == "left" then -- going right since it's backwards
    if self.map:tileAt(self.x + self.width - self.offsetStandingWidth - self.map.tileWidth, self.map.floor).id == PIT then
      sounds["slimejump"]:play()
      self:jumpingMovement()
    end
  elseif self.direction == "right" then -- going left since it's backwards
    if self.map:tileAt(self.x + self.offsetStandingWidth + self.map.tileWidth, self.map.floor).id == PIT then
      sounds["slimejump"]:play()
      self:jumpingMovement()
    end
  end
end

function Slime:hasCollision(offset)
  if self:hasRightCollision(offset) then
    -- reset velocity, position and change state
    if self.dy == 0 then
      sounds["slimejump"]:play()
      self:jumpingMovement()
    end

    self.x = (self.map:tileAt(self.x + self.width + offset, self.y).x - 1) * self.map.tileWidth - self.width
    return true
  elseif self:hasLeftCollision(offset) then
    -- reset velocity, position and change state
    if self.dy == 0 then
      sounds["slimejump"]:play()
      self:jumpingMovement()
    end

    self.x = self.map:tileAt(self.x - offset - 1, self.y).x * self.map.tileWidth
    return true
  end
  return false
end

function Slime:update(dt)
  self:handleUpdate(dt)
end

function Slime:render()
  self:handleRender()
end
