local accel = 0.01
while true do
script.Parent.CFrame *= CFrame.new(0,0,1 + accel)
accel += 0.01
wait()
end

