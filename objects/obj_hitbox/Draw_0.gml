// Only draw if debug mode is enabled
if (debug_show)
{
    // Draw filled rectangle (semi-transparent)
    draw_sprite_ext(
        sprite_index, 
        image_index,
        x, y,
        image_xscale,
        image_yscale,
        image_angle,
        debug_color,
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
        debug_color,
        1.0
    );
}