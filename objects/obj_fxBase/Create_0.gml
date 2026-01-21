// === CORE FX PROPERTIES ===
owner = noone;              
sprite_index = -1;          

// === POSITION & FOLLOWING ===
followOwner = false;        
followX = false;            
followY = false;            

spawnPointType = "center";  
offsetX = 0;                
offsetY = 0;

// === DIRECTION & FLIPPING ===
directionMode = "match_face";  
fixedDirection = 1;            
flipSprite = true;             
fxDirection = 1;               

// === LIFETIME & BEHAVIOR ===
lifetimeType = "animation_end";  
lifetimeDuration = 0;            
lifetimeTimer = 0;

loopCondition = "";              
alreadySpawned = false;          

// === ANIMATION ===
image_speed = 1;
image_alpha = 1;

// === SETUP ===
depth = -10;  // Default depth (will be set after owner is assigned)

// ============================================
// === USER DEFINED FUNCTIONS ===
// ============================================

// === CALCULATE DIRECTION ===
function calculateDirection()
{
    if (!instance_exists(owner)) return;
    
    switch (directionMode)
    {
        case "match_face":
            if (variable_instance_exists(owner, "face"))
            {
                fxDirection = owner.face;
            }
            break;
            
        case "opposite_face":
            if (variable_instance_exists(owner, "face"))
            {
                fxDirection = -owner.face;
            }
            break;
            
        case "match_wall":
            if (variable_instance_exists(owner, "wallDir"))
            {
                fxDirection = owner.wallDir;
            }
            break;
            
        case "velocity":
            if (variable_instance_exists(owner, "xspd"))
            {
                fxDirection = sign(owner.xspd);
                if (fxDirection == 0) fxDirection = 1;
            }
            break;
            
        case "fixed":
            fxDirection = fixedDirection;
            break;
    }
}

// === CALCULATE SPAWN POSITION ===
function calculateSpawnPosition()
{
    if (!instance_exists(owner)) return;
    
    var _pos = getSpawnPoint(owner, spawnPointType, offsetX, offsetY, fxDirection);
    x = _pos[0];
    y = _pos[1];
}

// === INITIALIZE FX ===
// Call this AFTER owner is set (from child Create Event)
function initializeFX()
{
    if (instance_exists(owner))
    {
        depth = owner.depth + 1;  // Set depth relative to owner
    }
    
    calculateDirection();
    calculateSpawnPosition();
}

// NOTE: initializeFX() will be called by child objects after setting owner