// Destroy if owner is destroyed
if (!instance_exists(owner))
{
    instance_destroy();
    exit;
}
#region Size parameters
	// Get owner's MASK sprite info (not visual sprite)
	var _ownerMask = owner.mask_index;
	
	// If no mask set, use sprite_index as fallback
	if (_ownerMask == -1)
	{
	    _ownerMask = owner.sprite_index;
	}
	
	var _maskWidth = sprite_get_width(_ownerMask);
	var _maskHeight = sprite_get_height(_ownerMask);
	// Get owner's mask origin offset (in pixels from top-left)
	var _ownerOriginX = sprite_get_xoffset(_ownerMask);
	var _ownerOriginY = sprite_get_yoffset(_ownerMask);

	// Get our hurtbox sprite origin
	var _hurtboxOriginX = sprite_get_xoffset(sprite_index);
	var _hurtboxOriginY = sprite_get_yoffset(sprite_index);

	// Calculate position to align origins
	var _offsetX = (_ownerOriginX - _hurtboxOriginX);
	var _offsetY = (_ownerOriginY - _hurtboxOriginY);

	// Account for owner's facing direction if they have it
	if (variable_instance_exists(owner, "face"))
	{
	    // When facing left, flip the X offset
	    if (owner.face < 0)
	    {
	        _offsetX = _maskWidth - _ownerOriginX - _hurtboxOriginX;
	    }
	}

	// Position hurtbox to align with owner's mask canvas
	x = owner.x - _offsetX;
	y = owner.y - _offsetY;

	// Scale to match owner's MASK size
	image_xscale = _maskWidth;
	image_yscale = _maskHeight;

	// Match owner's rotation and alpha
	image_angle = owner.image_angle;
	image_alpha = owner.image_alpha;
#endregion

#region Hit Detection
// Countdown hit flash timer
if (hit_flash_timer > 0)
{
    hit_flash_timer--;
}
#endregion