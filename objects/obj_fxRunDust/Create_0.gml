event_inherited();

sprite_index = fx_runDustSpr;

// Configuration
followOwner = false;        // Static spawn (leaves trail)
followX = false;
followY = false;

spawnPointType = "feet";
offsetX = -5.5;               // Spawn behind the player
offsetY = 2;                // Slightly below feet

directionMode = "opposite_face";  // Dust kicks backward
flipSprite = true;

lifetimeType = "animation_end";

image_speed = 1;

depthOffset = 1;  // Behind player