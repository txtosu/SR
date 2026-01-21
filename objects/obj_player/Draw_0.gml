// Draw flipped sprite only
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * face, image_yscale, image_angle, image_blend, image_alpha);

// --- GRAPPLE ROPE ---
if (grappling && instance_exists(grappleTarget)) {
    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_line_width(x, y, grappleTarget.x, grappleTarget.y, 2);
}

#region Grapple Scan Visualizer
if (debug_grapple_show)
{
    var r = grapple_get_scan_rect();
    var left   = r[0];
    var top    = r[1];
    var right  = r[2];
    var bottom = r[3];
    
    // Draw scan box background
    draw_set_alpha(0.2);
    draw_set_color(c_lime);
    draw_rectangle(left, top, right, bottom, false);
    
    // Draw scan box outline
    draw_set_alpha(1);
    draw_set_color(c_green);
    draw_rectangle(left, top, right, bottom, true);
    
    // Draw facing direction indicator
    draw_line(x, y, x + face * (grappleScanWidth * 0.5 + 8), y);
    
    // Draw all grapple points in scan area
    var list = ds_list_create();
    var n = collision_rectangle_list(left, top, right, bottom, obj_grapplePoint, false, false, list, false);
    
    for (var i = 0; i < n; i++)
    {
        var gp = list[| i];
        
        // Skip points behind player
        if ((gp.x - x) * face <= 0) continue;
        
        // Skip points below player
        if (gp.y > y) continue;
        
        // Highlight current target
        if (instance_exists(grappleTarget) && gp == grappleTarget)
        {
            draw_set_colour(c_yellow);
            draw_circle(gp.x, gp.y, 6, false);
            draw_circle(gp.x, gp.y, 3, false);
        }
        else
        {
            // Draw available points
            draw_set_colour(c_aqua);
            draw_rectangle(gp.x - 3, gp.y - 3, gp.x + 3, gp.y + 3, false);
        }
    }
    
    ds_list_destroy(list);
    
    draw_set_colour(c_white);
    draw_set_alpha(1);
}
#endregion

// Restore defaults
draw_set_alpha(1);
draw_set_colour(c_white);