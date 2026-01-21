event_inherited();

sprite_index = fx_wallSlideSpr;

// Configuration
followOwner = true;         
followX = false;            
followY = true;             

spawnPointType = "wallside";
offsetX = 4;                
offsetY = -4;               

directionMode = "match_wall";  
flipSprite = true;

lifetimeType = "loop_while_active";
loopCondition = "";  // REMOVE - we'll handle this manually

image_speed = 1;

depthOffset = -1;  // In front of player