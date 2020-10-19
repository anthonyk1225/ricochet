push = require './push/push'

Joystick = Class{}

function Joystick:init(map, player)
  self.map = map
  self.player = player

  self.leftDPad = {
    xPoint = 20,
    yPoint = 40
  }

  self.rightDPad = {
    xPoint = 80,
    yPoint = 40
  }

  self.left = false
  self.right = false
  self.attack = false
  self.jump = false
end

function Joystick:setRightDPad()
  self.rightDPad.verticesOutter = {
    self.map.camX + (self.rightDPad.xPoint * 1.5 + 5), -- first x 3
    VIRTUAL_HEIGHT - 85 + self.rightDPad.yPoint * 1.5, -- first y x 1.5

    self.map.camX + (self.rightDPad.xPoint - 3), -- second x x 1
    VIRTUAL_HEIGHT - 85 + self.rightDPad.yPoint - 5, -- second y x 1

    self.map.camX + (self.rightDPad.xPoint - 3), -- third x x 1
    VIRTUAL_HEIGHT - 85 + self.rightDPad.yPoint * 2 + 5 -- third y x 2
  }

  self.rightDPad.verticesInner = {
    self.map.camX + (self.rightDPad.xPoint * 1.5), -- first x 3
    VIRTUAL_HEIGHT - 85 + self.rightDPad.yPoint * 1.5, -- first y x 1.5

    self.map.camX + (self.rightDPad.xPoint), -- second x x 1
    VIRTUAL_HEIGHT - 85 + self.rightDPad.yPoint, -- second y x 1

    self.map.camX + (self.rightDPad.xPoint), -- third x x 1
    VIRTUAL_HEIGHT - 85 + self.rightDPad.yPoint * 2 -- third y x 2
  }

  self.rightDPad.verticesOutterCollision = {}
  self.rightDPad.verticesOutterCollision[1] = {
    x = self.map.camX + (self.rightDPad.xPoint * 1.5 + 5), -- first x 3
    y = VIRTUAL_HEIGHT - 85 + self.rightDPad.yPoint * 1.5, -- first y x 1.5
  }
  self.rightDPad.verticesOutterCollision[2] = {
    x = self.map.camX + self.rightDPad.xPoint - 3, -- second x x 1
    y = VIRTUAL_HEIGHT - 85 + self.rightDPad.yPoint - 5, -- second y x 1
  }
  self.rightDPad.verticesOutterCollision[3] = {
    x = self.map.camX + self.rightDPad.xPoint - 3, -- third x x 1
    y = VIRTUAL_HEIGHT - 85 + self.rightDPad.yPoint * 2 + 5 -- third y x 2
  }
end

function Joystick:setLeftDPad()
  self.leftDPad.verticesOutter = {
    self.map.camX + self.leftDPad.xPoint - 5, -- first x x 1
    VIRTUAL_HEIGHT - 85 + self.leftDPad.yPoint * 1.5, -- first y x 1.5

    self.map.camX + self.leftDPad.xPoint * 3 + 3, -- second x x 3
    VIRTUAL_HEIGHT - 85 + self.leftDPad.yPoint - 5, -- second y x 1

    self.map.camX + self.leftDPad.xPoint * 3 + 3, -- third x x 3
    VIRTUAL_HEIGHT - 85 + self.leftDPad.yPoint * 2 + 5 -- third y x 2
  }

  self.leftDPad.verticesInner = {
    self.map.camX + self.leftDPad.xPoint, -- first x x 1
    VIRTUAL_HEIGHT - 85 + self.leftDPad.yPoint * 1.5, -- first y x 1.5

    self.map.camX + self.leftDPad.xPoint * 3, -- second x x 3
    VIRTUAL_HEIGHT - 85 + self.leftDPad.yPoint, -- second y x 1

    self.map.camX + self.leftDPad.xPoint * 3, -- third x x 3
    VIRTUAL_HEIGHT - 85 + self.leftDPad.yPoint * 2 -- third y x 2
  }
  
  self.leftDPad.verticesOutterCollision = {}
  self.leftDPad.verticesOutterCollision[1] = {
    x = self.map.camX + self.leftDPad.xPoint - 5, -- first x x 1
    y = VIRTUAL_HEIGHT - 85 + self.leftDPad.yPoint * 1.5, -- first y x 1.5 
  }
  self.leftDPad.verticesOutterCollision[2] = {
    x = self.map.camX + self.leftDPad.xPoint * 3 + 3, -- second x x 3
    y = VIRTUAL_HEIGHT - 85 + self.leftDPad.yPoint - 5, -- second y x 1
  }
  self.leftDPad.verticesOutterCollision[3] = {
    x = self.map.camX + self.leftDPad.xPoint * 3 + 3, -- third x x 3
    y = VIRTUAL_HEIGHT - 85 + self.leftDPad.yPoint * 2 + 5 -- third y x 2
  }
end

function Joystick:setJumpButton()
  self.jumpButton = {
    outter = {
      x = VIRTUAL_WIDTH - 40 + self.map.camX,
      y = VIRTUAL_HEIGHT - 25 + self.map.camY, -- 218
      radius = 24,
      segments = 100,
    },
    inner = {
      x = VIRTUAL_WIDTH - 40 + self.map.camX,
      y = VIRTUAL_HEIGHT - 25 + self.map.camY, -- 218
      radius =  22,
      segments = 100,
    },
  }
end

function Joystick:createJumpButton()
  -- JUMP BUTTON
  love.graphics.setColor(1, 1, 1)
  love.graphics.circle(
    "fill",
    self.jumpButton.outter.x,
    self.jumpButton.outter.y, -- 218
    self.jumpButton.outter.radius,
    self.jumpButton.outter.segments
  )
  love.graphics.setColor(149 / 255, 175 / 255, 166 / 255, 1.0)
  love.graphics.circle(
    "fill",
    self.jumpButton.inner.x,
    self.jumpButton.inner.y, -- 218
    self.jumpButton.inner.radius,
    self.jumpButton.inner.segments
  )
end

function Joystick:setAttackButton()
  self.attackButton = {
    outter = {
      x = VIRTUAL_WIDTH - 100 + self.map.camX,
      y = VIRTUAL_HEIGHT - 25 + self.map.camY, -- 218
      radius = 24,
      segments = 100
    },
    inner = {
      x = VIRTUAL_WIDTH - 100 + self.map.camX,
      y = VIRTUAL_HEIGHT - 25 + self.map.camY, -- 218
      radius =  22,
      segments = 100
    }
  }
end

function Joystick:createAttackButton()
  -- ATTACK BUTTON
  love.graphics.setColor(1, 1, 1)
  love.graphics.circle(
    "fill",
    self.attackButton.outter.x,
    self.attackButton.outter.y,
    self.attackButton.outter.radius,
    self.attackButton.outter.segments
  )
  love.graphics.setColor(149 / 255, 165 / 255, 166 / 255, 1.0)
  love.graphics.circle(
    "fill",
    self.attackButton.inner.x,
    self.attackButton.inner.y,
    self.attackButton.inner.radius,
    self.attackButton.inner.segments
  )
end

function Joystick:createLeftDPad()
  -- left D - PAD
  love.graphics.setColor(1, 1, 1)
  love.graphics.polygon(
    'fill',
    self.leftDPad.verticesOutter
  )
  love.graphics.setColor(149 / 255, 165 / 255, 166 / 255, 1.0)
  love.graphics.polygon(
    'fill',
    self.leftDPad.verticesInner
  )
end

function Joystick:createRightDPad()
  -- right D - PAD
  love.graphics.setColor(1, 1, 1)
  love.graphics.polygon(
    'fill',
    self.rightDPad.verticesOutter
  )
  love.graphics.setColor(149 / 255, 165 / 255, 166 / 255, 1.0)
  love.graphics.polygon(
    'fill',
    self.rightDPad.verticesInner
  )
end

function Joystick:update(dt)
  if self.rightDPad.verticesInner then
    local touches = love.touch.getTouches()

    local left = false
    local right = false
    local jump = false
    local attack = false

    for i, id in ipairs(touches) do
      local x, y = love.touch.getPosition(id)
      x, y = push:toGame(x, y)
      if x == nil or y == nil then
        return
      end
      x = x + self.map.camX
      y = y + self.map.camY

      if polygonCollision(self.rightDPad.verticesOutterCollision, x, y) == true then
        -- go right
        right = true
      elseif polygonCollision(self.leftDPad.verticesOutterCollision, x, y) == true then
        -- go left
        left = true
      elseif circleCollision(self.jumpButton.outter.x, self.jumpButton.outter.y, self.jumpButton.outter.radius, x, y) == true then
        -- jump
        jump = true
      elseif circleCollision(self.attackButton.outter.x, self.attackButton.outter.y, self.attackButton.outter.radius, x, y) == true then
        -- attack
        attack = true
      end
    end

    self.left = left
    self.right = right
    self.jump = jump
    self.attack = attack
  end
end

function Joystick:render()
  self:setAttackButton()
  self:createAttackButton()

  self:setJumpButton()
  self:createJumpButton()

  self:setLeftDPad()
  self:createLeftDPad()

  self:setRightDPad()
  self:createRightDPad()

  love.graphics.setColor(1, 1, 1)
end
