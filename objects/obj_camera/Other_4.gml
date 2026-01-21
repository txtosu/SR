// Start at player position
if (instance_exists(obj_player))
{
    x = obj_player.x;
    y = obj_player.y;
    xTo = x;
    yTo = y;
}

// Disable sprite smoothing
gpu_set_texfilter(false);