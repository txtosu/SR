event_inherited();

// Set sprite
sprite_index = fx_dashDustSpr;

// Configuration
followOwner = false;        
followX = false;
followY = false;

spawnPointType = "feet";
offsetX = -4;               
offsetY = 2;                

directionMode = "match_face";
flipSprite = true;

lifetimeType = "animation_end";

image_speed = 1;

// NOTE: owner will be set by player, then player should call initializeFX()