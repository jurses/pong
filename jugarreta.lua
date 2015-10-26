function agarrar(colisiona)
   if colisiona and love.keyboard.isDown("a") then
      return true
   else 
      return false
   end
   print("Agarró")
end

