xspd = dir*spd;
if place_meeting( x + xspd, y, obj_wall ) 
{ 
	dir *= -1;
	xspd = 0; 
} 
	
x += xspd;