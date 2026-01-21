// Destroy if owner is destroyed
if (!instance_exists(owner))
{
    instance_destroy();
    exit;
}

// === UPDATE DIRECTION (if needed) ===
if (followOwner)
{
    calculateDirection();  // Recalculate direction every frame
}

// === UPDATE POSITION (if following) ===
if (followOwner)
{
    // Recalculate spawn position with updated direction
    calculateSpawnPosition();
}

// === LIFETIME MANAGEMENT ===
if (lifetimeType == "animation_end")
{
    // Destroy when animation completes
    if (image_index >= image_number - 1)
    {
        instance_destroy();
    }
}
else if (lifetimeType == "loop_while_active")
{
    // Wall slide is managed by player - don't auto-destroy
    // Player will destroy myWallSlideFX when condition ends
}
else if (lifetimeType == "timed")
{
    lifetimeTimer++;
    if (lifetimeTimer >= lifetimeDuration)
    {
        instance_destroy();
    }
}