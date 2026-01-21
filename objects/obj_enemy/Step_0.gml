// Enemy AI would go here later
// Face towards the player
if (instance_exists(obj_player))
{
    var _dirToPlayer = sign(obj_player.x - x);
    
    // Only update face if player isn't at exact same x position
    if (_dirToPlayer != 0)
    {
        face = _dirToPlayer;
    }
}