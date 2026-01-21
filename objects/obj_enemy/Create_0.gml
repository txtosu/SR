 // Basic enemy variables
face = 1;
hp = 50;
hpMax = 50;

// Spawn hurtbox (same as player!)
myHurtbox = instance_create_depth(x, y, depth + 1, obj_hurtbox);
myHurtbox.owner = id;
myHurtbox.debug_show = true;
myHurtbox.debug_color = c_lime;  // Green for enemies

// Damage function (simple for now)
function take_damage(_amount, _knockbackX = 0, _knockbackY = 0)
{
    hp -= _amount;
    hp = max(0, hp);
    
    // Visual feedback - flash the hurtbox blue
    if (instance_exists(myHurtbox))
    {
        myHurtbox.hit_flash_timer = 20;  // Flash for 20 frames
        myHurtbox.hit_flash_color = c_blue;
    }
    
    // Die if no HP
    if (hp <= 0)
    {
        instance_destroy();
    }
    
    return true;
}