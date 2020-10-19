require 'Animation'
require 'Projectile'
require 'Joystick'
require 'actors/Character'

Hero = Class{__includes = Character}

local MOVEMENT_SPEED = 150
local GRAVITY = 20

function Hero:init(map)
  self.map = map
  self.width = 50
  self.height = 37

  self.readyToRestart = false

  self.standingWidth = 18
  self.standingHeight = 31

  self.offsetStandingWidth = math.ceil((self.width - self.standingWidth) / 2) -- will be the offset on the left or right
  self.offsetStandingHeight = math.ceil((self.height - self.standingHeight) / 2) -- will be the offset above or underneath

  self.x = self.map.tileWidth * 5 -- 10 tiles to the right
  self.y = self.map.floor - self.height

  self.dy = 0
  self.dx = 0

  self.texture = love.graphics.newImage("graphics/adventurer.png")
  self.frames = generateQuads(self.texture, self.width, self.height)

  self.state = "idle"
  self.direction = "right"

  self.projectile = Projectile(self, self.map)

  self.animations = {
    ["idle"] = Animation {
      texture = self.texture,
      frames = {
        self.frames[1], self.frames[2], self.frames[3], self.frames[4]
      },
      interval = 0.20
    },
    ["running"] = Animation {
      texture = self.texture,
      frames = {
        self.frames[9], self.frames[10], self.frames[11],
        self.frames[12], self.frames[13], self.frames[14]
      },
      interval = 0.10
    },
    ["jumping"] = Animation {
      texture = self.texture,
      frames = {
        self.frames[15], self.frames[16], self.frames[17], self.frames[18], self.frames[19],
        self.frames[20],self.frames[21], self.frames[22], self.frames[23], self.frames[24],
        interval = 0.20
      },
    },
    ["attacking"] = Animation {
      texture = self.texture,
      frames = {
        self.frames[43], self.frames[44], self.frames[45],
        self.frames[46], self.frames[47], self.frames[48],
      },
      interval = 0.10
    },
    ["dying"] = Animation {
      texture = self.texture,
      frames = {
        self.frames[67], self.frames[68]
      },
      interval = 0.30
    },
    ["restarting"] = Animation {
      texture = self.texture,
      frames = {
        self.frames[1], self.frames[2], self.frames[3], self.frames[4]
      },
      interval = 0.20
    },
  }

  self:changeAnimation()

  self.behaviors = {
    ["idle"] = function(dt)
      self:lateralMovement(dt)
      self:jumpAttempt(dt)
      self:isAttacking(dt)
    end,
    ["running"] = function(dt)
      self:lateralMovement(dt)
      self:jumpAttempt(dt)
      self:hasCollision(10)
      self:isAttacking(dt)
      if self:isFalling() then
        self.state = "jumping"
        self:changeAnimation()
      end
    end,
    ["jumping"] = function(dt)
      self:lateralMovement(dt)
      self:hasCollision(10)
      self.dy = self.dy + GRAVITY

      if self.joystick.attack or love.keyboard.wasPressed("l") then
        sounds["shoot"]:play()
        self.projectile:fire()
      end

      if self.y + self.height > VIRTUAL_HEIGHT + 50 then
        sounds["death"]:play()
        sounds["backgroundmusic"]:stop()
        self:dead()
      end

      -- if not self:isFalling() then -- jumps twice when landing if I use this function
      -- end
      if self.map:collides(self.map:tileAt(self.x + self.offsetStandingWidth, self.y + self.height)) or
        self.map:collides(self.map:tileAt(self.x + (self.width - self.offsetStandingWidth) - 1, self.y + self.height)) then
          self.dy = 0
          self.state = "idle"
          self:changeAnimation()
          self.y = (self.map:tileAt(self.x, self.y + self.height).y - 1) * self.map.tileHeight - self.height
      end
    end,
    ["attacking"] = function(dt)
      if self.dx < 0 then
        self:preventOutOfBounds("a")
      elseif self.dx > 0 then
        self:preventOutOfBounds("d")
      end
      self:hasCollision(10)
      self:jumpAttempt(dt)
      if self:isFalling() then
        self.state = "jumping"
        self:changeAnimation()
      end

      self:fireProjectile()

      if self.animations[self.state].currentFrame == 6 then
        if self.dx >= 0 then
          self.state = "running"
        else
          self.state = "idle"
        end
        self:changeAnimation()
      end
    end,
    ["dying"] = function(dt)
      self.dy = 0
      self.dx = 0
      if love.keyboard.isDown("n") then
        self.state = "restarting"
        self:changeAnimation()
      end

      local touches = love.touch.getTouches()

      if #touches > 0 then
        for i, id in ipairs(touches) do
          local x, y = love.touch.getPosition(id)
          x, y = push:toGame(x, y)
          y = y + self.map.camY
    
          if y < self.map.floor then
            self.state = "restarting"
            self:changeAnimation()
          end
        end
      end
    end,
    ["restarting"] = function(dt)
      local yIsGood = false
      local xIsGood = false

      if self.y - (self.map.floor - self.height) < 20 then
        yIsGood = true
        self.dy = 0
        self.y = self.map.floor - self.height
      elseif self.y > self.map.floor - self.height then
        self.dy = -500
      elseif self.y < self.map.floor - self.height then
        self.dy = 500
      end

      if self.x - self.map.tileWidth * 5 < 20 then
        self.dx = 0
        xIsGood = true
        self.x = self.map.tileWidth  * 5
      elseif self.x > self.map.tileWidth * 5 then
        self.dx = -500
      elseif self.x < self.map.tileWidth * 5 then
        self.dx = 500
      end

      if yIsGood and xIsGood then
        sounds["backgroundmusic"]:setLooping(true)
        sounds["backgroundmusic"]:play()
        if self.map.slimeCount == 0 then
          self.map:newGame(self.map.level + 1)
        else
          self.map:newGame(1)
        end
      end
    end
  }

  self.joystick = Joystick(self.map, self)
end

function Hero:isAttacking(dt)
  if self.joystick.attack or love.keyboard.wasPressed("l") then
    self.state = "attacking"
    self:changeAnimation()
  end
end

function Hero:fireProjectile()
  if self.animations[self.state].currentFrame == 4 then
    sounds["shoot"]:play()
    self.projectile:fire()
  end
end

function Hero:hasCollision(offset)
  if self:hasRightCollision(offset) then
    -- reset velocity and position and change state
    self.dx = 0
    self.x = (self.map:tileAt(self.x + self.width + offset, self.y).x - 1) * self.map.tileWidth - self.width
    return true
  elseif self:hasLeftCollision(offset) then
    -- reset velocity and position and change state
    self.dx = 0
    self.x = self.map:tileAt(self.x - offset - 1, self.y).x * self.map.tileWidth
    return true
  end
  return false
end

function Hero:lateralMovement(dt)
  if self.joystick.left == true or love.keyboard.isDown("a") then -- left
    self.direction = "left"
    if self.state ~= "jumping" then
      self.state = "running"
      self.animation = self.animations[self.state] -- don't call changeAnimation on purpose
    end
    self:preventOutOfBounds("a")
  elseif self.joystick.right == true or love.keyboard.isDown("d") then -- right
    self.direction = "right"
    if self.state ~= "jumping" then
      self.state = "running"
      self.animation = self.animations[self.state] -- don't call changeAnimation on purpose
    end
    self:preventOutOfBounds("d")
  else
    if self.state == "jumping" then
      if self.x + 40 >= self.map.mapWidthPixels then
        self.dx = 0
      elseif self.x + 10 <= 0 then
        self.dx = 0
      end
    else
      self.state = "idle"
      self.animation = self.animations[self.state] -- don't call changeAnimation on purpose
      self.dx = 0
    end
  end
end

function Hero:jumpAttempt(dt)
  if self.joystick.jump == true or love.keyboard.wasPressed("space") then
    sounds["jump"]:play()
    self:jumpingMovement()
  end
end

function Hero:preventOutOfBounds(keyPressed)
  if keyPressed == "d" and self.x + 40 <= self.map.mapWidthPixels then
    self.dx = MOVEMENT_SPEED
  elseif keyPressed == "a" and self.x + 10 >= 0 then
    self.dx = -MOVEMENT_SPEED
  else
    self.dx = 0
  end
end

function Hero:update(dt)
  self.projectile:update(dt)
  -- self.joystick:update(dt)
  self:handleUpdate(dt)
end

function Hero:render()
  self.projectile:render()
  -- self.joystick:render()
  self:handleRender()
end
