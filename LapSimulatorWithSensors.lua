-- RPM Sweet Lap Simulator by P.Monaghan
-- Based on Lap Siimulator by B.Picaso and RPM Demo by B.Picaso and F.Mirandola 
--Lap Simulator
--this script adequately simulates varying speeds and periodic pit stops
--Creates a static set of common sensors  oil temp, oil pressure, fuel level, and Engine temp
--Sweeps RPM values from x to Y, see below to adjust those values
--disable all GPS channels
--disable lap timing

dist = 0
speed = 30
speedDir = 0
maxSpeedDir = 2
minSpeedDir = -2
lapCount = 0
currentLap = 1
lapTime = 0
sessionTime = 0
elapsedTime = 0
onPitStopLap = 0
pitStopLaps = 4 --how often we stop for a pit stop
pitStopTime = 0
pitStopStart = 0
basePitStopTime = 20000
rpm = 0
coolantTemp = 50

 --Low RPM threshold for change direction edit this to set your low RPM Point
thrRpmLo = 1500
--Low RPM threshold for change direction edit this to set your shift or redline point
thrRpmHi = 6000
--Step between each RPM increment/decrement, will affect the speed, higher = faster - set this to set the speed of update
incrementRpm = 200

--Low Engine temp threshold for change direction edit this to set your low engine temp Point
thrEngTmpLo = 70
--High enginer temp threshold for change direction edit this to set your high engine temp point
thrEngTmpHi = 300
--Step between each engine temp increment/decrement, will affect the speed, higher = faster - set this to set the speed of update
incrementTemp = 10

maxDist = 3
tickRate = 10
tickInterval = 1/tickRate
minSpeed = 25
maxSpeed = 100

speedId = addChannel("Speed", 10, 1, 0, 150)
distId = addChannel("Distance", 10, 2,0.1, 4)
lapCountId = addChannel("LapCount", 10)
currentLapId = addChannel("CurrentLap", 10)
lapTimeId = addChannel("LapTime", 10, 4)
elapsedTimeId = addChannel("ElapsedTime", 10, 4)
predTimeId = addChannel("PredTime", 10, 4)
sessionTimeId = addChannel("SessionTime", 10, 4)

-- Simulated Sensors (these are static)
rpmId = addChannel("RPMTmp", 10, 0, 0, 6000)
tmpId = addChannel("EngineTmp", 10, 0, 0, 250)
oilId = addChannel("OilTmp", 10, 0, 0, 220)
pressId = addChannel("OilP", 10, 0, 0, 250)
fuelLvlID = addChannel("FuelLvl", 10, 0, 0, 80)



setChannel(oilId, 210)
setChannel(pressId, 250)
setChannel(fuelLvlID,9)

setChannel(lapCountId, lapCount)
setChannel(currentLapId, currentLap)

direction = 0
coolantDir = 0

function rpmSweep()
  setChannel(rpmId, rpm)

    if (rpm<=thrRpmHi and direction == 0 ) then rpm = rpm + incrementRpm  
        elseif (rpm>=thrRpmLo and direction == 1 ) then rpm = rpm - incrementRpm
  end

  if (rpm>thrRpmHi) then direction = 1
    elseif (rpm<thrRpmLo) then direction = 0
  end

end

function sensorSweep()
    setChannel(tmpId, coolantTemp)

     if (coolantTemp<=thrEngTmpHi and coolantDir == 0 ) then coolantTemp = coolantTemp + incrementTemp  
           elseif (coolantTemp>=thrEngTmpLo and coolantDir == 1 ) then coolantTemp = coolantTemp - incrementTemp
    end
 
        if (coolantTemp>thrEngTmpHi) then coolantDir = 1
       elseif (coolantTemp<thrEngTmpLo) then coolantDir = 0
    end
 
 end


function updateSpeed()
if speedDir > maxSpeedDir then speedDir = maxSpeedDir end
if speedDir < minSpeedDir then speedDir = minSpeedDir end
if speed > maxSpeed and speedDir > 0 then speedDir = -speedDir end
if onPitStopLap == 0 and speed < minSpeed and speedDir < 0 then speedDir = -speedDir end
if onPitStopLap == 1 then
  speedDir = -1
end
speedDir = speedDir + (math.random() * 2) - 1
speed = speed + speedDir
if onPitStopLap > 0 and speed < 0 then speed = 0 end
if onPitStopLap > 0 then
  if getUptime() > pitStopStart + pitStopTime then
    onPitStopLap = 3
    speedDir = 1
    println('leaving pit stop')
  end
end
setChannel(speedId, speed)
end

function updateDistance()
--convert miles per second to miles per hour
dist = dist + speed * (tickInterval * 0.00277778)
--println(speedDir ..' ' ..speed ..' ' ..dist)
setChannel(distId, dist)
end

function checkNewLap()
  elapsedTime = elapsedTime + tickInterval
  sessionTime = sessionTime + tickInterval
  if dist > maxDist then
    dist = 0
    speedDir = 0
    currentLap = currentLap + 1
    lapCount = lapCount + 1
    lapTime = elapsedTime
    elapsedTime = 0
    speedDir = 0
    onPitStopLap = 0
  end
  setChannel(lapCountId, lapCount)
  setChannel(currentLapId, currentLap)
  setChannel(lapTimeId, lapTime / 60)
  setChannel(predTimeId, ((lapTime + (math.random(1,10) / 10)) / 60))
  setChannel(elapsedTimeId, elapsedTime / 60)
  setChannel(sessionTimeId, sessionTime / 60)
end

function checkPitStop()
  if lapCount > 0 and onPitStopLap == 0 and lapCount % pitStopLaps == 0 then
    onPitStopLap = 1
    pitStopStart = getUptime()
    pitStopTime = basePitStopTime + (math.random() * 1000)
    println('on pit stop for ' ..pitStopTime ..' sec.')
  end
  
end

function onTick()
checkNewLap()
rpmSweep()
sensorSweep()
updateSpeed()
updateDistance()
checkPitStop()
end

setTickRate(tickRate)