function generateQuads(atlas, tilewidth, tileheight)
  local sheetWidth = atlas:getWidth() / tilewidth
  local sheetHeight = atlas:getHeight() / tileheight

  local sheetCounter = 1
  local quads = {}

  for y = 0, sheetHeight - 1 do
    for x = 0, sheetWidth - 1 do
      quads[sheetCounter] = love.graphics.newQuad(
        x * tilewidth,
        y * tileheight,
        tilewidth,
        tileheight,
        atlas:getDimensions()
      )
      sheetCounter = sheetCounter + 1
    end
  end

  return quads
end

function polygonCollision(vertices, px, py)
  local collision = false
  local next = 1
  for current = 1, #vertices do
    next = current + 1
    if (next > #vertices) then
      next = 1
    end
    local vc = vertices[current]
    local vn = vertices[next]
    if (((vc.y >= py and vn.y < py) or (vc.y < py and vn.y >= py)) and
      (px < (vn.x-vc.x) * (py-vc.y) / (vn.y-vc.y) + vc.x)) then
        collision = not(collision)
    end
  end
  return collision
end

function circleCollision(circle_x, circle_y, rad, x, y)
  if ((x - circle_x) * (x - circle_x) + (y - circle_y) * (y - circle_y) <= rad * rad) then
    return true
  end

  return false
end
