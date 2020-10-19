Character = Class{}

JUMP_VELOCITY = 320

-- this will propel the character up
function Character:jumpingMovement()
  self.dy = -JUMP_VELOCITY
  self.state = "jumping"
  self:changeAnimation()
end

-- if the character is falling return true otherwise return false
function Character:isFalling()
  if not self.map:collides(self.map:tileAt(self.x + self.offsetStandingWidth, self.y + self.height)) and
  not self.map:collides(self.map:tileAt(self.x + (self.width - self.offsetStandingWidth) - 1, self.y + self.height + 1)) then
    return true
  end
  return false
end

-- restart the animation and set the new animation
function Character:changeAnimation()
  self.animations[self.state]:restart()
  self.animation = self.animations[self.state]
end

-- if the character is moving, we check to see if there's a collision to the right and return true / false
function Character:hasRightCollision(offset)
  if self.dx > 0 then
    if self.map:collides(self.map:tileAt(self.x + self.width - offset, self.y)) or
      self.map:collides(self.map:tileAt(self.x + self.width - offset, self.y + self.height - 1)) then
        return true
    end
  end
  return false
end

-- if the character is moving, we check to see if there's a collision to the left and return true / false
function Character:hasLeftCollision(offset)
  if self.dx < 0 then
    if self.map:collides(self.map:tileAt(self.x + offset - 1, self.y)) or
      self.map:collides(self.map:tileAt(self.x + offset - 1, self.y + self.height - 1)) then
        return true
    end
  end
  return false
end

function Character:dead()
  self.state = "dying"
  self:changeAnimation()
end

-- set the behavior accordingly, call update to animate, set x and y
function Character:handleUpdate(dt)
  self.behaviors[self.state](dt)
  self.animation:update(dt)
  self.x = self.x + self.dx * dt
  self.y = self.y + self.dy * dt
end

function Character:handleRender()
  local scaleX

  if self.direction == "right" then
    scaleX = 1
  elseif self.direction == "left" then
    scaleX = -1
  end

  love.graphics.draw(
    self.texture,
    self.animation:getCurrentFrame(),
    math.floor(self.x + self.width / 2),
    math.floor(self.y + self.height / 2),
    0,
    scaleX,
    1,
    self.width / 2,
    self.height / 2
  )
end
