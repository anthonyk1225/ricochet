require 'actors/Character'

Enemy = Class{__includes = Character}

function Enemy:hasBeenHit(projectile)
  -- we have the x and y position of the projectile
  -- we also have the height and width of the projectile
  -- with this information, we should figure out if there's
  -- a collision at any point with the enemy
  projectileMinX = projectile.x
  projectileMaxX = projectile.x + projectile.width

  projectileMinY = projectile.y + projectile.offsetHeight
  projectileMaxY = projectile.y + projectile.height - projectile.offsetHeight

  -- we cam take the front of the slime and the back of the slime
  -- on each side we search for
  slimeMinX = self.x + self.offsetStandingWidth
  slimeMaxX = self.x + (self.width - self.offsetStandingWidth) - 1

  slimeMinY = self.y + self.offsetStandingHeight
  slimeMaxY = self.y + (self .height - self.offsetStandingHeight)

  local conditionXA = slimeMinX >= projectileMinX and slimeMinX <= projectileMaxX
  local conditionXB = slimeMaxX >= projectileMinX and slimeMaxX <= projectileMaxX
  local conditionXC = slimeMinX >= projectileMinX and slimeMaxX <= projectileMaxX

  local conditionYA = slimeMinY >= projectileMinY and slimeMinY <= projectileMaxY
  local conditionYB = slimeMaxY >= projectileMinY and slimeMaxY <= projectileMaxY
  local conditionYC = slimeMinY <= projectileMinY and slimeMaxY >= projectileMaxY

  if conditionXA or conditionXB or conditionXC then
    if conditionYA or conditionYB or conditionYC then
      -- ur dead
      projectile:stash()
      self:dead()
      sounds["explosion"]:play()
    end
  end
end

function Enemy:collidesWithHero(hero)
  local heroXMin = hero.x + hero.offsetStandingWidth
  local heroXMax = hero.x + hero.width - hero.offsetStandingWidth
  local heroYMin = hero.y
  local heroYMax = hero.y + hero.height

  local selfXMin = self.x + self.offsetStandingWidth
  local selfXMax = self.x + self.width - self.offsetStandingWidth
  local selfYMin = self.y
  local selfYMax = self.y + self.height

  if selfXMin >= heroXMin and selfXMin <= heroXMax then
    if selfYMin >= heroYMin and selfYMin <= heroYMax then
      -- ur dead
      sounds["death"]:play()
      sounds["backgroundmusic"]:stop()
      hero:dead()
    end
  elseif slimeMaxX >= heroXMin and slimeMaxX <= heroXMax then
    if slimeMaxY >= heroYMin and slimeMaxY <= heroYMax then
      -- ur dead
      sounds["death"]:play()
      sounds["backgroundmusic"]:stop()
      hero:dead()
    end
  end
end

function Enemy:patrol(speed)
  if self.x <= 0 then
    self.direction = "left"
    self.dx = speed
  elseif self.x + 40 >= self.map.mapWidthPixels then
    self.direction = "right"
    self.dx = -speed
  end
end
