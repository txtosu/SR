event_inherited();

sprite_index = fx_backStepDustSpr;

// Configuration
followOwner = false;        // Static spawn
followX = false;
followY = false;

spawnPointType = "feet";
offsetX = 4;                // Spawn in FRONT (dust kicks forward)
offsetY = 2;

directionMode = "match_face";  // Faces same direction as player
flipSprite = true;

lifetimeType = "animation_end";

image_speed = 1;

depthOffset = 1;  // Behind player