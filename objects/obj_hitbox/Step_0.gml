// Destroy if owner is destroyed
if (!instance_exists(owner))
{
    instance_destroy();
    exit;
}

// Calculate hitbox bounding box
var _hbLeft, _hbRight, _hbTop, _hbBottom;

if (followOwner)
{
    // Simply multiply X values by face direction - works for both sides
    var _nearEdge = owner.x + (offsetX * owner.face);
    var _farEdge  = _nearEdge + (hitboxWidth * owner.face);
    
    // Ensure left < right regardless of direction
    _hbLeft  = min(_nearEdge, _farEdge);
    _hbRight = max(_nearEdge, _farEdge);
    
    _hbTop    = owner.y + offsetY;
    _hbBottom = owner.y + offsetY + hitboxHeight;
}
else
{
    // Independent hitbox (projectiles, etc.)
    _hbLeft   = x;
    _hbRight  = x + hitboxWidth;
    _hbTop    = y;
    _hbBottom = y + hitboxHeight;
}

// Store bounds for drawing and collision
hbLeft   = _hbLeft;
hbRight  = _hbRight;
hbTop    = _hbTop;
hbBottom = _hbBottom;

// Update position for drawing (center of hitbox)
x = (_hbLeft + _hbRight) / 2;
y = (_hbTop + _hbBottom) / 2;

// Scale is always positive
image_xscale = hitboxWidth;
image_yscale = hitboxHeight;

// Lifetime countdown
if (lifetime > 0)
{
    lifetimeTimer++;
    if (lifetimeTimer >= lifetime)
    {
        instance_destroy();
        exit;
    }
}

// --- COLLISION DETECTION ---
// Use collision_rectangle for precise, origin-independent collision
var _hitHurtbox = collision_rectangle(_hbLeft, _hbTop, _hbRight, _hbBottom, obj_hurtbox, false, true);

if (_hitHurtbox != noone)
{
    // Filter: Don't hit your own hurtbox
    if (_hitHurtbox.owner != owner)
    {
        // Check if we've already hit this target
        var _alreadyHit = false;
        for (var i = 0; i < ds_list_size(hitList); i++)
        {
            if (hitList[| i] == _hitHurtbox.owner)
            {
                _alreadyHit = true;
                break;
            }
        }
        
        // If not already hit, deal damage
        if (!_alreadyHit)
        {
            // Add to hit list
            ds_list_add(hitList, _hitHurtbox.owner);
            
            // Deal damage to the owner (if they have the function)
            if (instance_exists(_hitHurtbox.owner) && variable_instance_exists(_hitHurtbox.owner, "take_damage"))
            {
                _hitHurtbox.owner.take_damage(damage, knockbackX * owner.face, knockbackY);
            }
            
            // Destroy hitbox if set to destroy on hit
            if (destroyOnHit)
            {
                instance_destroy();
                exit;
            }
        }
    }
}
// --- END COLLISION DETECTION ---
