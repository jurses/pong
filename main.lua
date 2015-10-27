function love.load()
   gr = love.graphics
   kb = love.keyboard
   width = gr.getWidth()
   height = gr.getHeight()

   p1 = {}
   p1.score = 0
   p1.dim = {x = 50, y = 150}
   p1.pos ={x = 0, y = 50}
   p1.vel = 600
   p1.move = false      --¿Se están moviendo?, al principio no pero cuando pulsas 'w' o 's' sí.
   p1.canMove = true    --¿Se puede mover?, sí.
   p1.dir = nil         --Valor Bool, True indica que se mueve '+', false indica '-'.

   p2 = {}
   p2.score = 0
   p2.dim = {x = 50, y = 150}
   p2.pos = {x = width - p2.dim.x, y = 40}
   p2.vel = 600
   p2.move = false
   p2.canMove = true
   p1.dir = nil

   pelota = {}
   pelota.dim = {x = 40 , y = 40}
   pelota.velG = 600
   pelota.ang = 5/4 * math.pi --225º dirección: 45º en el 3º cuadrante
   pelota.vel = {x = pelota.velG * math.pow(math.cos(pelota.ang), 2),
                 y = pelota.velG * math.pow(math.sin(pelota.ang), 2)}
   pelota.pos = { x = width/2 - pelota.dim.x/2, y = height/2 - pelota.dim.y/2 }

   fuenteGrande = gr.newFont(32)
   fuenteDebug = gr.newFont(12)

      --PRUEBAS--
   vel={}
   vel.x = pelota.vel.x
   vel.y = pelota.vel.y
   pelotaStop = false
end

function invPelota()
   pelota.pos = { x = width/2 - pelota.dim.x/2, y = height/2 - pelota.dim.y/2 }
   pelota.vel = {x = 300, y = 300}
end

function angPelota(pala, altura) --CORRECTO
   return ((2 * (((pala - (pelota.pos.y + pelota.dim.y / 2)) / altura) + 0.5)) * 1/4 * math.pi) -- Va desde +1 hasta -1
end

function agarrar(pala)
   local dt = love.timer.getDelta()
   vel.x = pelota.vel.x
   vel.y = pelota.vel.y
   pelota.vel.x = 0 
   pelota.vel.y = 0
   if pala.move and pala.dir then
      pelota.pos.y = pelota.pos.y - (pala.vel * dt)
   elseif pala.move and not pala.dir then
      pelota.pos.y = pelota.pos.y + (pala.vel * dt)
   end
end

function colision1()
   if p1.pos.x + p1.dim.x > pelota.pos.x then 
      if (p1.pos.y < pelota.pos.y + pelota.dim.y) and 
         (p1.pos.y + p1.dim.y > pelota.pos.y)   then
      return true
      end
   end
end

function colision2() 
   if p2.pos.x - p2.dim.x < pelota.pos.x then 
      if (p2.pos.y < pelota.pos.y + pelota.dim.y) and 
         (p2.pos.y + p2.dim.y > pelota.pos.y)   then
      return true
      end
   end 
end

function muerte()
   if pelota.pos.x + pelota.dim.x < 0 or pelota.pos.x > width then
      return true
   end
end

function puntuar()
   if pelota.pos.x + pelota.dim.x < 0 then
      p2.score = p2.score + 1
   elseif pelota.pos.x > width then
      p1.score = p1.score + 1
   end
end

function love.keypressed(key)
   if key == "p" and not (pelota.vel.x == 0 and pelota.vel.y == 0) then
      vel.x = pelota.vel.x
      vel.y = pelota.vel.y
      pelota.vel.x = 0
      pelota.vel.y = 0
      pelotaStop = true
   end

   if key == "o" then
      pelota.vel.x = vel.x
      pelota.vel.y = vel.y
      pelotaStop = false
   end
end

function love.update(dt)
   if kb.isDown("w") and p1.pos.y > 0 and p1.canMove then
      p1.pos.y = p1.pos.y - p1.vel * dt
      p1.move = true
      p1.dir = true
   elseif kb.isDown("s") and p1.pos.y + p1.dim.y < height and p1.canMove then
      p1.pos.y = p1.pos.y + p1.vel * dt
      p1.move = true
      p1.dir = false
   else
      p1.move = false
   end
      

   if kb.isDown("up") and p2.pos.y > 0 and p2.canMove then
      p2.pos.y = p2.pos.y - p2.vel * dt
      p2.move = true
      p2.dir = true 
   elseif kb.isDown("down") and p2.pos.y + p2.dim.y < height and p2.canMove then
      p2.pos.y = p2.pos.y + p2.vel * dt
      p2.move = true
      p2.dir = false 
   else
      p2.move = false
   end

      --TECHO--
   if pelota.pos.y < 0 then
      pelota.vel.y = math.abs(pelota.vel.y)
   elseif (pelota.pos.y + pelota.dim.y) > height then
      pelota.vel.y = -math.abs(pelota.vel.y)
   end
      --TECHO--

   if colision1() then
      local LG = angPelota(p1.pos.y, p1.dim.y)
      print("Chocó con la pala1")
      local anguloR = (5/4 * math.pi)/LG
      pelota.vel.x = math.abs(pelota.velG * math.cos(anguloR))
      pelota.vel.y = pelota.velG * math.sin(anguloR)
      if kb.isDown("a") then
         agarrar(p1)
      end
   end

   if colision2() then
      local LG = angPelota(p2.pos.y, p2.dim.y)
      print("Chocó con la pala2")
      local anguloR = (5/4 * math.pi)/LG
      pelota.vel.x = -1 * math.abs(pelota.velG * math.cos(anguloR))
      pelota.vel.y = pelota.velG * math.sin(anguloR)
      if kb.isDown("right") then
         agarrar(p2)
      end
   end

   pelota.pos.x = pelota.pos.x + (pelota.vel.x * dt)
   pelota.pos.y = pelota.pos.y + (pelota.vel.y * dt)

   if muerte() then
      puntuar()
      invPelota()
      print("Ha muerto la pelota")
   end

   if pelotaStop then
      if kb.isDown("i") and pelota.pos.y > 0 then
         pelota.pos.y = pelota.pos.y - pelota.velG * dt
      elseif kb.isDown("k") and pelota.pos.y + pelota.dim.y < height then
         pelota.pos.y = pelota.pos.y + pelota.velG * dt
      elseif kb.isDown("j") and pelota.pos.x > 0 then
         pelota.pos.x = pelota.pos.x - pelota.velG * dt
      elseif kb.isDown("l") and pelota.pos.x + pelota.dim.x < width then
         pelota.pos.x = pelota.pos.x + pelota.velG * dt
      end
   end

end

function love.draw()
      --JUGADOR 1--
   gr.rectangle("fill", p1.pos.x, p1.pos.y, p1.dim.x, p1.dim.y)

      --JUGADOR 2--
   gr.rectangle("fill", p2.pos.x, p2.pos.y, p2.dim.x, p2.dim.y)

      --PELOTA--
   gr.rectangle("fill", pelota.pos.x, pelota.pos.y, pelota.dim.x, pelota.dim.y)

      --Resultados--
   gr.setFont(fuenteGrande)
   gr.printf("Jugador 1: " .. p1.score .. "\nJugador 2: " .. p2.score,0,0,width,"center")

      --PrintDebuj-- 
      --[[
   gr.setFont(fuenteDebug)
   gr.print("Ángulo de la pelota: " ..angPelota(p1.pos.y, p1.dim.y).. 
   "\n Velocidad X pelota: " ..pelota.vel.x..
   "\n Velocidad Y pelota: " ..pelota.vel.y,0,500)
      --]]
end

