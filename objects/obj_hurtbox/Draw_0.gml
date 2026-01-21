// Only draw if debug mode is enabled
if (debug_show)
{
    // Determine color (hit flash overrides normal color)
    var _currentColor = debug_color;
    if (hit_flash_timer > 0)
    {
        _currentColor = hit_flash_color;
    }
    
    // Draw filled rectangle (semi-transparent)
    draw_sprite_ext(
        sprite_index, 
        image_index,
        x, y,
        image_xscale,
        image_yscale,
        image_angle,
        _currentColor,
        debug_alpha
    );
    
    // Draw outline (solid)
    draw_sprite_ext(
        sprite_index,
        image_index,
        x, y,
        image_xscale,
        image_yscale,
        image_angle,
        _currentColor,
        1.0
    );
}