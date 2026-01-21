event_inherited();

// Set sprite
sprite_index = fx_jumpDustSpr;

// Configuration
followOwner = false;        
followX = false;
followY = false;

spawnPointType = "feet";
offsetX = 0;                
offsetY = 0;

directionMode = "match_face";
flipSprite = true;

lifetimeType = "animation_end";

image_speed = 1;

// NOTE: owner will be set by player, then player should call initializeFX()