require 'Animation'

Projectile = Class{}

local PROJECTILE_SPEED = 250

-- TODO: stash the instance if it goes off the map

function Projectile:init(player, map)
  self.player = player
  self.map = map
  self.width = 32
  self.height = 32

  self.actualHeight = 24

  self.offsetHeight = math.ceil((self.height - self.actualHeight) / 2)

  self.x = -1000
  self.y = -1000

  self.dy = 0
  self.dx = 0

  self.distanceTraveled = 0

  self.texture = love.graphics.newImage("graphics/spritesheet.png")
  self.frames = generateQuads(self.texture, self.width, self.height)

  self.animations = {
    ["moving"] = Animation {
      texture = self.texture,
      frames = {
        self.frames[1], self.frames[2], self.frames[3], self.frames[4], self.frames[5], self.frames[6], self.frames[7], self.frames[8], self.frames[9],
        self.frames[10], self.frames[11], self.frames[12], self.frames[13], self.frames[14], self.frames[15], self.frames[16], self.frames[17], self.frames[18], self.frames[19],
        self.frames[20], self.frames[21], self.frames[22], self.frames[23], self.frames[24], self.frames[25], self.frames[26], self.frames[27], self.frames[28], self.frames[29],
        self.frames[30], self.frames[31], self.frames[32], self.frames[33], self.frames[34], self.frames[35], self.frames[36], self.frames[37], self.frames[38], self.frames[39],
        self.frames[40], self.frames[41], self.frames[42], self.frames[43], self.frames[44], self.frames[45], self.frames[46], self.frames[47], self.frames[48], self.frames[49],
        self.frames[50], self.frames[51], self.frames[52], self.frames[53], self.frames[54], self.frames[55], self.frames[56], self.frames[57], self.frames[58], self.frames[59],
        self.frames[60]
      },
      interval = 0.10
    }
  }

  self.animation = self.animations["moving"]
end

function Projectile:fire()
  local offset
  if self.player.direction == "right" then
    offset = 32
    self.dx = PROJECTILE_SPEED
  else
    offset = -52
    self.dx = -PROJECTILE_SPEED
  end

  self.x = self.player.x + offset
  self.y = self.player.y
end

function Projectile:stash()
  self.dx = 0
  self.dy = 0
  self.x = -500
  self.y = -500
  self.distanceTraveled = 0
end

function Projectile:update(dt)
  self.animation:update(dt)
  self.x = self.x + self.dx * dt
  self.y = self.y + self.dy * dt
  self.distanceTraveled = self.distanceTraveled + self.dx

  if self.distanceTraveled >= 10000 then
    self:stash()
  end
end

function Projectile:render()
  love.graphics.draw(
    self.texture,
    self.animation:getCurrentFrame(),
    math.floor(self.x + self.width / 2),
    math.floor(self.y + self.height / 2),
    0,
    1,
    1,
    self.width / 2,
    self.height / 2
  )
end
