--===============================================================================--
pitch = 0 --pitch
roll = 0 --roll
yaw = 0 --yaw
rss1 = 0 --Connection quality
rss2 = 0 --Connection quality
flight_mode = 0 --Flightmode
tx_voltage = 0 --Your transmitter voltage
fuel = 0 --Remaining charge as a percentage
capa = 0 --Used battery capacity
bat_voltage = 0 --Battery voltage 
current = 0 --Current in the power supply circuit
tpw = 0 --signal power
t_qly = 0 --transmission quality 
gpsLatLon = 0 --GPS data in latitude Longitude
GSpd = 0 --Ground speed by GPS 
Hdg = 0 --Current heading by GPS
Alt = 0 --Current altitude by barometer
Sats = 0 --Number in avalibale satellites
Vspd = 0 --Vertical speed by barometer 

alt_max = 0
old_fm = ""
--===============================================================================--
-- There are you plane parameters 
bat_min = 3.5 --minimum battery voltage by cell
max_cap = 1350 --maximum battery capability
alt_alarm = 10 --minimum safe altitude 

spd_alarm = 40 --minimum speed
climb_alarm = 10 --maximum climb speed
decline_alarm = 20 --maximum decline speed

min_t_qly = 20 --minimum transmission quality
--===============================================================================--

local function drawCircle(xCenter, yCenter, radius)
	local y, x
	for y=-radius, radius do
		for x=-radius, radius do
			if(x*x+y*y <= radius*radius) then
				lcd.drawPoint(xCenter+x, yCenter+y)
				end
			end
		end
	end

local function drawFrame()
  --Draw main frame on screen. LCD width 127, height 63
  --[[
        __________________________8          ____x pos  y pos
		0     40   		87     127                        |
		|     |    		 |      |                         |
		|     |-43    84-|23    |
		|     |__________|      |
		|     |    		 |45    |
		|     |    		 |      |
  ]]
  lcd.drawLine(40,8,40,63,SOLID,FORCE)
  lcd.drawLine(87,8,87,63,SOLID,FORCE)
  lcd.drawLine(40,27,43,27,SOLID,FORCE)
  lcd.drawLine(84,27,87,27,SOLID,FORCE)
  lcd.drawLine(40,45,87,45,SOLID,FORCE)
  
end

local function drawBatteryData(xz, yz)
  
  lcd.drawGauge(xz+1,yz+9,xz+37,yz+8,fuel,100)
  lcd.drawLine(xz+38,yz+12,xz+38,yz+13,SOLID,FORCE)
  
  lcd.drawText(xz+1,yz+19,"Bt",SMLSIZE)
  lcd.drawNumber(lcd.getLastPos(),yz+19,10*bat_voltage,PREC1+SMLSIZE)
  lcd.drawText(lcd.getLastPos(),yz+19,"V",SMLSIZE)
  
  lcd.drawText(xz+1,yz+27,"Cp",SMLSIZE)
  lcd.drawNumber(lcd.getLastPos(),yz+27,capa,SMLSIZE)
  
  lcd.drawText(xz+1,yz+35,"Cur",SMLSIZE)
  lcd.drawNumber(lcd.getLastPos(),yz+35,current*10,PREC1+SMLSIZE)
  lcd.drawText(lcd.getLastPos(),yz+35,"A",SMLSIZE)
  
  lcd.drawText(xz+1,yz+43,"Tx",SMLSIZE)
  lcd.drawNumber(lcd.getLastPos()+2,yz+43,100*getValue("tx-voltage"),SMLSIZE+PREC2)
  lcd.drawText(lcd.getLastPos(),yz+43,"V",SMLSIZE)
  
end  

local function drawOtherData(zx,zy)
  
  lcd.drawText(zx+2, zy+9,"TQ",SMLSIZE)
  lcd.drawNumber(lcd.getLastPos()+2, zy+9,t_qly, SMLSIZE)
  lcd.drawText(lcd.getLastPos(), zy+9,"%",SMLSIZE)
  
  lcd.drawText(zx+2, zy+16,"SP",SMLSIZE)
  lcd.drawNumber(lcd.getLastPos()+2, zy+16,tpw, SMLSIZE)
  lcd.drawText(lcd.getLastPos(), zy+16,"mW",SMLSIZE)
  
  lcd.drawText(zx+2, zy+24, "Sat", SMLSIZE)
  lcd.drawNumber(lcd.getLastPos()+2, zy+24, Sats, SMLSIZE)
  
	if (type(gpsLatLon) == "table") then
		gpsLat = gpsLatLon["lat"]
		gpsLon = gpsLatLon["lon"]
	else 
		gpsLat = "Not GPS"
		gpsLon = "Not GPS"
	end
	
	if (gpsLat == "0") then 
		gpsLat = "Not GPS"
		end
		
	if (gpsLon == "0") then 
		gpsLon = "Not GPS"
		end
	
	lcd.drawText(zx+2,zy+40,gpsLat,SMLSIZE)
	lcd.drawText(lcd.getLastPos()+2, zy+40, "N", SMLSIZE)
	
	lcd.drawText(zx+2,zy+48,gpsLon,SMLSIZE)
	lcd.drawText(lcd.getLastPos()+2, zy+48, "E", SMLSIZE)
	
end

local function drawBird(zx,zy,roll,pitch)

	if(t_qly > 0) then
	
		local y0 = zy+27 - 17*math.sin(pitch)
		local x0 = zx+24 
		local leng = 17

		x1 = x0+leng*math.cos(roll)
		x2 = x0-leng*math.cos(roll)
		
		y1 = y0+leng*math.sin(roll)
		if (y1 > 45) then 
			y1 = 45
		end
		
		y2 = y0-leng*math.sin(roll)
		if (y2 > 45) then 
			y2 = 45
		end
		
		lcd.drawLine(x0,y0,x1,y1,SOLID,FORCE)
		lcd.drawLine(x0,y0,x2,y2,SOLID,FORCE)
		drawCircle(x0,y0,2)
		
		
		if (math.abs(roll) > math.pi/2) then 
			lcd.drawText(zx+10, zy+35, "invert", BLINK, SMLSIZE)
		end
		lcd.drawNumber(zx+2,zy+9, GSpd, SMLSIZE)
		lcd.drawText(lcd.getLastPos(),zy+9, "K", SMLSIZE)
		
		lcd.drawNumber(zx+30,zy+9, Alt, SMLSIZE)
		lcd.drawText(lcd.getLastPos(),zy+9, "m", SMLSIZE)
	end 
	
	if(t_qly == 0) then
	
		lcd.drawText(60,25,"No",BLINK)
		lcd.drawText(42,33,"Tlemetry",BLINK)
	end
end

local function drawFM(xz, yz)

	lcd.drawText(xz+10,yz+5,flight_mode,SMLSIZE)
	
end

local function MasterWarning()

	if (Vspd < -decline_alarm) then 
		playFile("/SOUNDS/ru/dsnk.wav")
		playFile("/SOUNDS/ru/pullup.wav")
	end
	
	if (bat_voltage < bat_voltage or capa > max_cap) then
		playFile("SOUNDS/ru/batcrt.wav")
	end
	
	if (Alt < alt_alarm and alt_max > 5) then 
		playFile("/SOUNDS/ru/terra.wav")
		playFile("/SOUNDS/ru/alt.wav")
	end
	
		if (Vspd > climb_alarm) then
		playFile("/SOUNDS/ru/mons.wav")
	end
	
	if (GSpd < spd_alarm and alt_max > 5) then
		playFile("/SOUNDS/ru/mons.wav")
	end
	
	if(old_fm ~= flight_mode) then
		
		if(flight_mode == "ACRO" or flight_mode == "HORIZON" or flight_mode == "MANUAL") then
			playFile("/SOUNDS/ru/apoff.wav")
		end
		
		if(flight_mode == "HOLD" or flight_mode == "RTH") then
			playFile("/SOUNDS/ru/apon.wav")
		end
	end
	
	
	
end

local function drawMasterWarinig()
	
	if (bat_voltage < bat_voltage or capa > max_cap) then
		lcd.drawText(44, 48,"Bat",SMLSIZE+BLINK)
	end
	
	if(gpsLat == 0 or gpsLon == 0) then
		lcd.drawText(70, 48,"Gps",SMLSIZE+BLINK)
	end
	
	if(t_qly < min_t_qly) then
	lcd.drawText(44, 56,"Tlm",SMLSIZE+BLINK)
	end
	
	if (Alt < alt_alarm and alt_max > 5) then 
		lcd.drawText(70, 56,"Alt",SMLSIZE+BLINK)
	end
	
end



--======================================================================
--Edit this "parameters" like its write in you transmitter 
local function getTelemeryValue()
  pitch = getValue("Ptch")
  roll = getValue("Roll") 
  yaw = getValue("Yaw")
  rss1 = getValue("1RSS")
  rss2 = getValue("2RSS")
  flight_mode = getValue("FM")
  tx_voltage = getValue("tx-voltage")
  fuel = getValue("Bat_")
  capa = getValue("Capa")
  bat_voltage = getValue("RxBt")
  current =getValue("Curr")
  tpw = getValue("TPW2")
  t_qly = getValue("TQly")
  gpsLatLon = getValue("GPS")
  GSpd = getValue("GSpd")
  Hdg = getValue("Hdg")
  Alt = getValue("Alt")
  Sats = getValue("Sats")
  Vspd = getValue("VSpd")
end
--======================================================================


local function run_func(event)
	
	getTelemeryValue()
	
	lcd.clear() --clear lcd display
	  
	lcd.drawScreenTitle("INAV Telemetry",1,1) --put there current version
	  
	drawFrame()
	  
	drawBatteryData(0, 0)
	  
	drawOtherData(87,0)
	  
	drawBird(40,0,roll,pitch)
	  
	drawFM(40,35) --45
	  
	MasterWarning()
	
	drawMasterWarinig()
	  
	old_fm = flight_mode
	
	if(Alt > alt_max) then
	alt_max = Alt
	end
	
  if event == EVT_EXIT_BREAK then   --if "Exit" button pressed, stop program
    return 1 
  else
    return 0
  end
  
end


return { run=run_func } --looping the program