BLOCK_WIDTH = 50
BLOCK_HEIGHT = 15
BLOCK_GAP = 10

BALL_RADIUS = 8

BAT_SPEED = 400

function love.load()
  wf = require "libraries/windfield"
  
  world = wf.newWorld(0, 0)
  
  world:addCollisionClass('block')
  world:addCollisionClass('ball')
  world:addCollisionClass('bounds')
  world:addCollisionClass('goal')
  
  blocks = 0
  for y=1,10 do
    for x=1,14 do
      local block = world:newRectangleCollider(40 + x * (BLOCK_WIDTH + BLOCK_GAP),
        30 + y * (BLOCK_HEIGHT + BLOCK_GAP), BLOCK_WIDTH, BLOCK_HEIGHT)
      block:setType('static')
      block:setRestitution(0.9)
      block.tag = 10 * (11 - y)
      block:setCollisionClass('block')
      block:setObject(block)
      blocks = blocks + 1
    end
  end
  
  ball = world:newCircleCollider(400, 400, BALL_RADIUS)
  ball:setType('kinetic')
  ball:setRestitution(0.9)
  ball:setLinearVelocity(-100, -300)
  ball:setCollisionClass('ball')
  
  bat = world:newRectangleCollider(500, 550, 60, 15)
  bat:setType('kinetic')
  
  wall = world:newRectangleCollider(0, -10, 1024, 10)
  wall:setType('static')
  wall:setCollisionClass('bounds')

  wall = world:newRectangleCollider(0, 600, 1024, 610)
  wall:setType('static')
  wall:setCollisionClass('goal')

  wall = world:newRectangleCollider(-10, 0, 10, 600)
  wall:setType('static')
  wall:setCollisionClass('bounds')

  wall = world:newRectangleCollider(1024, 0, 1024 + 10, 600)
  wall:setType('static')
  wall:setCollisionClass('bounds')

  score = 0
  highest = 0
end

function inRange(value, range, offset)
  return (value > range - offset) and (value < range + offset)
end

function love.update(dt)
  -- adjust ball velocity and direction
  local x, y = ball:getLinearVelocity()
  local angle = math.atan2(y, x)
  
  if inRange(angle, 0, 0.1) then
    angle = 0.1
  elseif inRange(angle, math.pi / 2, 0.1) then
    angle = math.pi / 2 + love.math.random() - 0.5
  elseif inRange(angle, math.pi, 0.1) then
    angle = math.pi + love.math.random() - 0.5
  elseif inRange(angle, math.pi * 3 / 2, 0.1) then
    angle = math.pi * 3 / 2 + love.math.random() - 0.5
  end
  
  x = math.cos(angle) * 400
  y = math.sin(angle) * 400
  ball:setLinearVelocity(x, y)
  
  -- adjust the bat
  x,y = bat:getPosition()
  if love.keyboard.isDown('left') then
    x = x - dt * BAT_SPEED
  end
  if love.keyboard.isDown('right') then
    x = x + dt * BAT_SPEED
  end
  bat:setPosition(x, 550)
  
  bat:setAngle(0)
  bat:setLinearVelocity(0, 0)
  
  if ball:enter('block') then
    local data = ball:getEnterCollisionData('block')
    local block = data.collider:getObject()
    if block then
      score = score + block.tag
      if score > highest then
        highest = score
      end
      block:destroy()
    end
  end
  
  if ball:enter('goal') then
    score = 0
  end
    
  world:update(dt)
end

function love.draw(dt)
  love.graphics.print("FPS: "..love.timer.getFPS(), 1024 - 70, 10)
  love.graphics.print("Score: "..score, 10, 10)
  love.graphics.print("High: "..highest, 100, 10)
  world:draw()
end

