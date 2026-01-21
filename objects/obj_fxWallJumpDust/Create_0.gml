event_inherited();

sprite_index = fx_wallJumpDustSpr;

// Configuration
followOwner = false;        // Static spawn
followX = false;
followY = false;

spawnPointType = "wallside";  // Spawn at the wall
offsetX = 8;                  // On the wall side
offsetY = 0;                  // Center height

directionMode = "match_wall";  // Faces toward the wall player jumped from
flipSprite = true;

lifetimeType = "animation_end";

image_speed = 1;

depthOffset = 1;  // Behind player