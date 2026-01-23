//Get inputs
getControls();

// --- GRAPPLE INPUT EDGES ---
grappleJustReleased = false;

var _grappleHeld    = (grappleKey != 0);
var _grapplePressed = (_grappleHeld && !grappleKeyPrev);

if (!_grappleHeld && grappleKeyPrev) {
    grappleJustReleased = true;
}

grappleKeyPrev    = _grappleHeld;
grappleKeyPressed = _grapplePressed;

#region Dash/Backstep Input (NOT LOGIC)
// Get movement input
var _moveInput = (leftKey || rightKey);

// BACKSTEP INPUT (Ground only, no directional input, has dash charges)
if (!isDashing && !isBackStepping && onGround && dashCooldownTimer <= 0 
    && dashKey && !_moveInput && dashCharges > 0)
{
    // Enter backstep state
    isBackStepping = true;
    
    // Consume a dash charge
    dashCharges--;
    
    // Set backstep velocity (moves backward from facing direction)
    xspd = face * backStepSpeed;  // Negative speed = backward
    yspd = 0;
    
    // Lock inputs
    inputLockMove = backStepLockFrames;
    inputLockFace = backStepLockFrames;
    backStepLockTimer = backStepLockFrames;
    
    // Lock Y axis during backstep
    lockY = true;
}
// DASH INPUT (Forward dash with directional input)
else if (!isDashing && !isBackStepping && dashCooldownTimer <= 0 
         && dashKey && _moveInput && dashCharges > 0)
{
    // Enter dash state
    isDashing = true;
    
    // Consume a dash charge
    dashCharges--;
    
    // Determine dash direction (use input direction, or face if holding both)
    moveDir = rightKey - leftKey;
    dashDir = (moveDir != 0) ? moveDir : face;
    face = dashDir;
    
    // Track if this is an air dash
    dashWasAir = !onGround;
    
    // Set initial dash velocity
    xspd = dashDir * dashSpeed;
    yspd = 0; // Cancel vertical movement
    
    // Lock inputs
    inputLockMove = dashLockFrames;
    inputLockFace = dashLockFrames;
    dashLockTimer = dashLockFrames;
    
    // Lock Y axis during dash
    lockY = true;
}
#endregion

// --- PREEMPTIVE: INPUT LOCKS ---
if (inputLockMove > 0)
{
    // Ignore horizontal input while locked
    rightKey = 0;
    leftKey  = 0;
}

if (inputLockJump > 0)
{
    // Ignore all jump-related inputs while locked
    jumpKeyPressed  = 0;
    jumpKeyBuffered = 0;
    jumpKey         = 0;
}
// --- END PREEMPTIVE: INPUT LOCKS ---


//Get out of solid moving platforms that have positionted themselves into the player in the begin step
#region
    var _rightWall = noone;
    var _leftWall = noone;
    var _bottomWall = noone;
    var _topWall = noone;
    var _list = ds_list_create();
    var _listSize = instance_place_list( x, y, obj_movePlat, _list, false );

    //Loop through all colliding moveplats
    for( var i = 0; i <_listSize; i++ )
    {
        var _listInst = _list [| i];
    
        //Find closest walls in each direction
        //Right walls
        if _listInst.bbox_left - _listInst.xspd >= bbox_right-1
        {
            if !instance_exists(_rightWall) || _listInst.bbox_left < _rightWall.bbox_left
            {
                _rightWall = _listInst;
            }
        }
    
        //Left walls
        if _listInst.bbox_right - _listInst.xspd <= bbox_left+1
        {
            if !instance_exists(_leftWall) || _listInst.bbox_right > _leftWall.bbox_right
            {
                _leftWall = _listInst;
            }
        }
    
        //Bottom Wall
        if _listInst.bbox_top - _listInst.yspd >= bbox_bottom-1
        {
            if !instance_exists (_bottomWall) || _listInst.bbox_top < _bottomWall.bbox_top
            {
                _bottomWall = _listInst;
            }
        }
    
        //Top Wall
        if _listInst.bbox_bottom - _listInst.yspd <= bbox_top+1
        {
            if !instance_exists(_topWall) || _listInst.yspd <= bbox_top+1
            {
                _topWall = _listInst;
            }
        }
    }

    //destory the ds list to free memory
    ds_list_destroy(_list);

    //Get out of wall
        //Right wall
        if instance_exists(_rightWall)
        {
            var _rightDist = bbox_right - x;
            x = _rightWall.bbox_left - _rightDist;
        }

        //Left wall
        if instance_exists(_leftWall)
        {
            var _leftDist = x -  bbox_left ;
            x = _leftWall.bbox_right + _leftDist;
        }
    
        //Bottom Wall
        if instance_exists(_bottomWall)
        {
            var _bottomDist = bbox_bottom - y;
            y = _bottomWall.bbox_top - _bottomDist;
        }

        //Top Wall (includs, collision for polish and crouching features)
        if instance_exists(_topWall)
        {
            var _upDist = y - bbox_top;
            //for crouching
            var _targetY = _topWall.bbox_bottom + _upDist;
            //Check if there isnt a wall in the way
            if !place_meeting ( x, _targetY, obj_wall )
            {
                y = _targetY;
            }
        }
#endregion

//Dont get left behind by moveplat
earlyMoveplatXspd = false;
if instance_exists( myFloorPlat ) && myFloorPlat.xspd != 0 && !place_meeting (x, y + moveplatMaxYspd + 1, myFloorPlat )
{
    //Go ahead and move ourselves back onto that platform if there is no wall in the way
    if !place_meeting( x + myFloorPlat.xspd, y, obj_wall )
    {
        x += myFloorPlat.xspd;
        earlyMoveplatXspd = true;
    }
}

#region ATTACK INPUT
// GROUND ATTACKS (standing and crouch)
if (!isAttacking && !isDashing && !isClimbing && !grappling && onGround && attackKey)
{
    // Crouch attack
    if (downKey)
    {
        isAttacking = true;
        attackName = "crouch";
        attackFrame = 0;
        attackFrameMax = attack_crouch_frames;
        attack_crouch_hitboxSpawned = false;
        
        inputLockMove = attackFrameMax;
        inputLockFace = attackFrameMax;
        inputLockJump = attackFrameMax;
        
        xspd = 0;
    }
    // Standing attack
    else
    {
        isAttacking = true;
        attackName = "standingSwing1";
        attackFrame = 0;
        attackFrameMax = attack_standingSwing1_frames;
        attack_standingSwing1_hitboxSpawned = false;
        
        inputLockMove = attackFrameMax;
        inputLockFace = attackFrameMax;
        inputLockJump = attackFrameMax;
        
        xspd = 0;
    }
}

// AIR ATTACK (jump attack)
if (!isAttacking && !isDashing && !isClimbing && !grappling && !onGround && attackKey)
{
    isAttacking = true;
    attackName = "jump";
    attackFrame = 0;
    attackFrameMax = attack_jump_frames;
    attack_jump_hitboxSpawned = false;
    
    inputLockMove = attackFrameMax;
    inputLockFace = attackFrameMax;
    inputLockJump = attackFrameMax;
    
    // Optional: reduce air speed during attack
    xspd *= 0.5;
}
#endregion

#region X Movement (old, pre-wall jump)
/*
	//-----------X Movement-----------

	// Direction input (-1, 0, 1)
	moveDir = rightKey - leftKey;

	// Facing
	if (moveDir != 0 && inputLockFace <= 0) {
	    face = moveDir;
	}

	// Basic walk / run movement
	if (moveDir != 0) {
	    // 0 = walk, 1 = run (you already set this up in Create)
	    runType = runKey;
	    xspd = moveDir * moveSpd[runType];
	} else {
	    // Simple friction when no horizontal input
	    var fric = onGround ? stopDecelGround : stopDecelAir;
	    if (xspd > 0)      xspd = max(0, xspd - fric);
	    else if (xspd < 0) xspd = min(0, xspd + fric);
	}

	// --- PREEMPTIVE: X LOCK ---
	if (lockX) {
	    xspd = 0;
	}
	// --- END PREEMPTIVE: X LOCK ---
*/
#endregion

#region X Movement
	//-----------X Movement-----------

	// Skip normal movement if grappling (grapple controls movement)
	if (!grappling)
	{
		// Direction input (-1, 0, 1)
		moveDir = rightKey - leftKey;

		// Facing
		if (moveDir != 0 && inputLockFace <= 0) {
		    face = moveDir;
		}

		// Universal movement (works both ground and air - like old code)
		if (moveDir != 0 && inputLockMove <= 0)
		{
		    // Determine speed based on state
		    if (groundState == GroundState.G_CROUCH)
		    {
		        runType = 2;  // Crouch walk speed
		    }
		    else
		    {
		        runType = runKey;  // Walk (0) or Run (1)
		    }
		    
		    xspd = moveDir * moveSpd[runType];  // Direct speed setting
		}
		else if (inputLockMove <= 0)
		{
		    // Friction when no input (ground or air)
		    var fric = onGround ? stopDecelGround : stopDecelAir;
		    if (xspd > 0)      xspd = max(0, xspd - fric);
		    else if (xspd < 0) xspd = min(0, xspd + fric);
		}
		// If locked (dash/wall jump), apply appropriate friction
		else if (onGround)
		{
		    // Ground friction during locked states
		    if (xspd > 0)      xspd = max(0, xspd - stopDecelGround);
		    else if (xspd < 0) xspd = min(0, xspd + stopDecelGround);
		}
		// If locked in air, preserve momentum (no friction)

		// --- PREEMPTIVE: X LOCK ---
		if (lockX) {
		    xspd = 0;
		}
		// --- END PREEMPTIVE: X LOCK ---
	}
	// If grappling, velocity is set by grapple logic - don't interfere!
#endregion

#region X Collison
    //X collision
    //How close the player can get to a wall
    var _subPixel = .5;
    
    //Checks for a wall
    if place_meeting( x + xspd , y, obj_wall)
    {
        //Check for a slope to go up
        if !place_meeting( x + xspd, y-abs(xspd)-2, obj_wall)
        {
            while place_meeting( x + xspd, y, obj_wall) { y -= _subPixel; };
        }
        //Next, check for ceiling slopes, otherwise, do a regular collision
        else
        {
            //Ceiling Slopes
            if !place_meeting( x + xspd, y + abs(xspd)+1, obj_wall )
            {
                while place_meeting( x + xspd, y, obj_wall ) {y += _subPixel; };
            }
            //Normal Collision
            else
            {
                //Scott up to wall percisely 
                var _pixelCheck = _subPixel * sign(xspd);
                while !place_meeting( x + _pixelCheck, y, obj_wall ) {x += _pixelCheck;};
        
                //Set xspd to zero to "collide"
                xspd = 0;
            }
        }
    }

    //Go Down Slopes
    downSlopeSemiSolid = noone;
    if (yspd >= 0
    && !place_meeting(x + xspd, y + 1, obj_wall)
    && place_meeting(x + xspd, y + abs(xspd) + 3, obj_wall))

    {
        //Chec for a semisolid in the way
        downSlopeSemiSolid = checkForSemisolidPlatform( x + xspd, y + abs(xspd) + 1 );
        //Precisely mode down slope if there isn't a semisolid in the way
        if !instance_exists(downSlopeSemiSolid)
        {
            while !place_meeting( x + xspd, y + _subPixel, obj_wall ) { y += _subPixel; };
        }
    }
    
    //Move
    x += xspd;
#endregion

#region Dash State Logic
// Handle dash state (runs parallel to parent states)
if (isDashing)
{
    // Keep facing locked to dash direction
    face = dashDir;
    
    // Keep Y locked (no gravity during dash)
    lockY = true;
    yspd = 0;
    
    // Maintain dash velocity (friction will be applied in X Movement section)
    // No need to set xspd here - it's handled by the initial burst and friction
    
    // Count down dash timer
    if (dashLockTimer > 0)
    {
        dashLockTimer--;
    }
    else
    {
        // Dash timer expired - exit dash state
        isDashing = false;
        lockY = false;
        dashCooldownTimer = dashCooldownFrames;
        
        // If we were air dashing, let gravity take over
        // (Ground dash will just continue with momentum + friction)
    }
}
#endregion

#region Backstep State Logic
// Handle backstep state (runs parallel to parent states)
if (isBackStepping)
{
    // Keep Y locked (no gravity during backstep)
    lockY = true;
    yspd = 0;
    
    // Count down backstep timer
    if (backStepLockTimer > 0)
    {
        backStepLockTimer--;
    }
    else
    {
        // Backstep timer expired - exit backstep state
        isBackStepping = false;
        lockY = false;
        dashCooldownTimer = dashCooldownFrames;  // Share cooldown with dash
    }
}
#endregion

#region Grapple State Logic
// Handle grapple initiation
if (!grappling && !isClimbing && grappleKeyPressed)  // Add !isClimbing check
{
    var _target = grapple_find_best_target();
    
    if (instance_exists(_target))
    {
        grappling     = true;
        grappleTarget = _target;
        
        var tx = grappleTarget.x;
        var ty = grappleTarget.y + grappleHangOffsetY;
        
        var dx  = tx - x;
        var dy  = ty - y;
        var mag = max(0.0001, sqrt(dx*dx + dy*dy));
        
        grappleDirX = dx / mag;
        grappleDirY = dy / mag;
        
        // Initial impulse toward target
        var _impulse = min(grappleAccel * 2, grapplePullSpeed);
        xspd = grappleDirX * _impulse;
        yspd = grappleDirY * _impulse;
        
        setOnGround(false);
        
        // Reset air mobility (dash and jumps refresh naturally)
        isDashing = false;
        lockY = false;
    }
}

// Handle grapple travel
if (grappling)
{
    if (!instance_exists(grappleTarget))
    {
        // Target destroyed - cancel grapple
        grappling = false;
    }
    else
    {
        var tx = grappleTarget.x;
        var ty = grappleTarget.y + grappleHangOffsetY;
        
        var dx   = tx - x;
        var dy   = ty - y;
        var dist = sqrt(dx*dx + dy*dy);
        
        // Check if arrived at target
        if (dist <= grappleDetachDist)
        {
            // Normalize direction
            var nx = (dist > 0.0001) ? dx / dist : 0;
            var ny = (dist > 0.0001) ? dy / dist : 0;
            
            // Set velocity to pass through point
            xspd = nx * grappleApproachSpeed;
            yspd = ny * grappleApproachSpeed;
            
            // Snap to target if safe
            if (!place_meeting(tx, ty, obj_wall))
            {
                x = tx;
                y = ty;
            }
            
            // End grapple
            grappling = false;
        }
        else
        {
            // Travel toward target - SET VELOCITY EVERY FRAME
            var _step = min(grappleApproachSpeed, dist);
            var _nx   = dx / dist;
            var _ny   = dy / dist;
            
            xspd = _nx * _step;
            yspd = _ny * _step;
            
            // CRITICAL: Prevent gravity and friction from interfering
            setOnGround(false);
            coyoteHangTimer = 1;      // Prevents gravity
            gravityOverride = true;   // Extra safety
            
            // Optional: cancel with jump
            if (grappleCancelJump && jumpKeyPressed)
            {
                grappling = false;
                gravityOverride = false;  // Re-enable gravity when canceling
            }
        }
    }
}
else
{
    // Make sure gravity override is off when not grappling
    if (!isDashing && !isClimbing)
    {
        gravityOverride = false;
    }
}
#endregion

#region Climbing State Logic
	// Check if touching a ladder
	var _onLadder = place_meeting(x, y, obj_ladder);

	// ENTER climbing state
	if (!isClimbing && _onLadder)
	{
	    // Can only enter if:
	    // - In air and pressing up/down, OR
	    // - On ground and pressing up
	    if ((!onGround && (upKey || downKey)) || (onGround && upKey))
	    {
	        isClimbing = true;
        
	        // Lock to ladder's center X
	        var _ladder = instance_place(x, y, obj_ladder);
	        if (instance_exists(_ladder))
	        {
	            ladderX = _ladder.x;
	        }
        
	        // Cancel conflicting states
	        grappling = false;
	        isDashing = false;
	        isWallCling = false;
	        wallDir = 0;
	        lockY = false;
        
	        // Clear horizontal momentum
	        xspd = 0;
	    }
	}

	// CLIMBING state logic
if (isClimbing)
{
    // Lock X to ladder center
    x = ladderX;
    xspd = 0;
    
    // Vertical movement (direct control, no gravity)
    var _climbSpeed = runKey ? climbSpeedRun : climbSpeedWalk;
    yspd = (downKey - upKey) * _climbSpeed;
    
    // Override gravity and ground detection
    coyoteHangTimer = 1;  // Prevents gravity from applying
    gravityOverride = true;
    setOnGround(false);   // ADD THIS - force not grounded while climbing
	    // EXIT conditions
    
	// Exit A: Jump off ladder
    if (jumpKeyPressed)
    {
        isClimbing = false;
        gravityOverride = false;
        
        // Perform jump off ladder
        jumpCount = 1;  // Set to 1 (we're using our first jump)
        jumpHoldTimer = jumpHoldFrames[0];
        yspd = jspd[0];
        setOnGround(false);
        
        // Lock jump input to prevent the normal jump code from running this frame
        inputLockJump = 1;
        
        // Clear jump buffer to prevent double-trigger
        jumpKeyBuffered = false;
        jumpKeyBufferTimer = 0;
    }
	    // Exit B: On ground and holding down
	    else if (onGround && downKey)
	    {
	        isClimbing = false;
	        gravityOverride = false;
	    }
	    // Exit C: No longer touching ladder
	    else if (!_onLadder)
	    {
	        isClimbing = false;
	        gravityOverride = false;
	    }
	}
	else
	{
	    // Make sure gravity override is off when not climbing
	    if (!isDashing && !grappling)  // Don't interfere with other global states
	    {
	        gravityOverride = false;
	    }
	}
#endregion

#region ATTACK STATE LOGIC
	if (isAttacking)
	{
	    // Increment attack frame
	    attackFrame++;
    
	    #region StandingSwing_1 
	    if (attackName == "standingSwing1")
	{
	    // Spawn hitbox on animation frame 2
	    if (floor(image_index) == 2 && !attack_standingSwing1_hitboxSpawned)
	    {
	        myAttackHitbox = instance_create_depth(x, y, depth - 1, obj_hitbox);
	        myAttackHitbox.owner = id;
	        myAttackHitbox.followOwner = true;
	        myAttackHitbox.offsetX = 15;
	        myAttackHitbox.offsetY = -30;
	        myAttackHitbox.hitboxWidth = 20;
	        myAttackHitbox.hitboxHeight = 20;
	        myAttackHitbox.damage = 10;
	        myAttackHitbox.lifetime = 0;
	        myAttackHitbox.debug_color = c_yellow;
	        attack_standingSwing1_hitboxSpawned = true;
	    }
    
	    // Destroy hitbox on animation frame 4
	    if (floor(image_index) >= 4 && instance_exists(myAttackHitbox))
	    {
	        instance_destroy(myAttackHitbox);
	        myAttackHitbox = noone;
	    }
    
	    // End attack when animation reaches LAST frame
	    var _lastFrame = sprite_get_number(attackSwing1Spr) - 1;
	    if (floor(image_index) >= _lastFrame)
	    {
	        // STOP THE ANIMATION
	        image_speed = 0;
	        image_index = _lastFrame;
        
	        // Exit attack state
	        isAttacking = false;
	        attackName = "";
        
	        // Clean up
	        if (instance_exists(myAttackHitbox))
	        {
	            instance_destroy(myAttackHitbox);
	            myAttackHitbox = noone;
	        }  
}
       // End attack when ANIMATION ACTUALLY FINISHES (not game frames!)
var _spriteFrames = sprite_get_number(attackSwing1Spr);
if (image_index >= _spriteFrames - 0.1)  // 0.1 buffer for float precision
{
    isAttacking = false;
    attackName = "";
    attackFrame = 0;
    
    // Clean up hitbox if still exists
    if (instance_exists(myAttackHitbox))
    {
        instance_destroy(myAttackHitbox);
        myAttackHitbox = noone;
    }
}
    }
	#endregion
		// Handle crouch attack
if (attackName == "crouch")
{
    // CANCEL if left ground
    if (!onGround)
    {
        isAttacking = false;
        attackName = "";
        attack_crouch_hitboxSpawned = false;
        
        if (instance_exists(myAttackHitbox))
        {
            instance_destroy(myAttackHitbox);
            myAttackHitbox = noone;
        }
        exit;
    }
    
    // Spawn hitbox on animation frame 2
    if (floor(image_index) == 2 && !attack_crouch_hitboxSpawned)
    {
        myAttackHitbox = instance_create_depth(x, y, depth - 1, obj_hitbox);
        myAttackHitbox.owner = id;
        myAttackHitbox.followOwner = true;
        myAttackHitbox.offsetX = 15;
	    myAttackHitbox.offsetY = -30;
	    myAttackHitbox.hitboxWidth = 20;
	    myAttackHitbox.hitboxHeight = 20;
        myAttackHitbox.damage = 8;
        myAttackHitbox.lifetime = 0;
        myAttackHitbox.debug_color = c_orange;
        
        attack_crouch_hitboxSpawned = true;
    }
    
    // Destroy hitbox on animation frame 4
    if (floor(image_index) >= 4 && instance_exists(myAttackHitbox))
    {
        instance_destroy(myAttackHitbox);
        myAttackHitbox = noone;
    }
    
    // End attack when animation reaches LAST frame
    var _lastFrame = sprite_get_number(attackCrouchSpr) - 1;
    if (floor(image_index) >= _lastFrame)
    {
        image_speed = 0;
        image_index = _lastFrame;
        
        isAttacking = false;
        attackName = "";
        attack_crouch_hitboxSpawned = false;
        
        if (instance_exists(myAttackHitbox))
        {
            instance_destroy(myAttackHitbox);
            myAttackHitbox = noone;
        }
    }
}

// Handle jump attack
if (attackName == "jump")
{
    // CANCEL if hit ground
    if (onGround)
    {
        isAttacking = false;
        attackName = "";
        attack_jump_hitboxSpawned = false;
        
        if (instance_exists(myAttackHitbox))
        {
            instance_destroy(myAttackHitbox);
            myAttackHitbox = noone;
        }
        exit;
    }
    
    // Spawn hitbox on animation frame 2
    if (floor(image_index) == 2 && !attack_jump_hitboxSpawned)
    {
        myAttackHitbox = instance_create_depth(x, y, depth - 1, obj_hitbox);
        myAttackHitbox.owner = id;
        myAttackHitbox.followOwner = true;
        myAttackHitbox.offsetX = 15;
	    myAttackHitbox.offsetY = -30;
	    myAttackHitbox.hitboxWidth = 20;
	    myAttackHitbox.hitboxHeight = 20;
        myAttackHitbox.damage = 12;        // Stronger air attack
        myAttackHitbox.lifetime = 0;
        myAttackHitbox.debug_color = c_aqua;
        
        attack_jump_hitboxSpawned = true;
    }
    
    // Destroy hitbox on animation frame 4
    if (floor(image_index) >= 4 && instance_exists(myAttackHitbox))
    {
        instance_destroy(myAttackHitbox);
        myAttackHitbox = noone;
    }
    
    // End attack when animation reaches LAST frame
    var _lastFrame = sprite_get_number(attackAirSlashSpr) - 1;
    if (floor(image_index) >= _lastFrame)
    {
        image_speed = 0;
        image_index = _lastFrame;
        
        isAttacking = false;
        attackName = "";
        attack_jump_hitboxSpawned = false;
        
        if (instance_exists(myAttackHitbox))
        {
            instance_destroy(myAttackHitbox);
            myAttackHitbox = noone;
        }
    }
}
// Handle crouch attack
if (attackName == "crouch")
{
    // CANCEL if left ground
    if (!onGround)
    {
        isAttacking = false;
        attackName = "";
        attack_crouch_hitboxSpawned = false;
        
        if (instance_exists(myAttackHitbox))
        {
            instance_destroy(myAttackHitbox);
            myAttackHitbox = noone;
        }
        exit;
    }
    
    // Spawn hitbox on animation frame 2
    if (floor(image_index) == 2 && !attack_crouch_hitboxSpawned)
    {
        myAttackHitbox = instance_create_depth(x, y, depth - 1, obj_hitbox);
        myAttackHitbox.owner = id;
        myAttackHitbox.followOwner = true;
        myAttackHitbox.offsetX = 30;       // Low forward strike
        myAttackHitbox.offsetY = -10;      // Lower to ground
        myAttackHitbox.hitboxWidth = 50;
        myAttackHitbox.hitboxHeight = 30;  // Shorter hitbox
        myAttackHitbox.damage = 8;
        myAttackHitbox.lifetime = 0;
        myAttackHitbox.debug_color = c_orange;
        
        attack_crouch_hitboxSpawned = true;
    }
    
    // Destroy hitbox on animation frame 4
    if (floor(image_index) >= 4 && instance_exists(myAttackHitbox))
    {
        instance_destroy(myAttackHitbox);
        myAttackHitbox = noone;
    }
    
    // End attack when animation reaches LAST frame
    var _lastFrame = sprite_get_number(attackCrouchSpr) - 1;
    if (floor(image_index) >= _lastFrame)
    {
        image_speed = 0;
        image_index = _lastFrame;
        
        isAttacking = false;
        attackName = "";
        attack_crouch_hitboxSpawned = false;
        
        if (instance_exists(myAttackHitbox))
        {
            instance_destroy(myAttackHitbox);
            myAttackHitbox = noone;
        }
    }
}

// Handle jump attack
if (attackName == "jump")
{
    // CANCEL if hit ground
    if (onGround)
    {
        isAttacking = false;
        attackName = "";
        attack_jump_hitboxSpawned = false;
        
        if (instance_exists(myAttackHitbox))
        {
            instance_destroy(myAttackHitbox);
            myAttackHitbox = noone;
        }
        exit;
    }
    
    // Spawn hitbox on animation frame 2
    if (floor(image_index) == 2 && !attack_jump_hitboxSpawned)
    {
        myAttackHitbox = instance_create_depth(x, y, depth - 1, obj_hitbox);
        myAttackHitbox.owner = id;
        myAttackHitbox.followOwner = true;
        myAttackHitbox.offsetX = 25;       // Forward air strike
        myAttackHitbox.offsetY = -15;      // Mid-body
        myAttackHitbox.hitboxWidth = 45;
        myAttackHitbox.hitboxHeight = 45;
        myAttackHitbox.damage = 12;        // Stronger air attack
        myAttackHitbox.lifetime = 0;
        myAttackHitbox.debug_color = c_aqua;
        
        attack_jump_hitboxSpawned = true;
    }
    
    // Destroy hitbox on animation frame 4
    if (floor(image_index) >= 4 && instance_exists(myAttackHitbox))
    {
        instance_destroy(myAttackHitbox);
        myAttackHitbox = noone;
    }
    
    // End attack when animation reaches LAST frame
    var _lastFrame = sprite_get_number(attackAirSlashSpr) - 1;
    if (floor(image_index) >= _lastFrame)
    {
        image_speed = 0;
        image_index = _lastFrame;
        
        isAttacking = false;
        attackName = "";
        attack_jump_hitboxSpawned = false;
        
        if (instance_exists(myAttackHitbox))
        {
            instance_destroy(myAttackHitbox);
            myAttackHitbox = noone;
        }
    }
}
}
#endregion

#region State Machine Update
	// Decide Parent State first
	if (onGround && !isClimbing)
	{
	    parentState = ParentState.GROUND;
	}
	else
	{
	    parentState = ParentState.AIR;
	}

	// ----------- GROUND STATES -----------
	if (parentState == ParentState.GROUND)
	{
	    // While grounded, reset air-related variables
	    airState       = AirState.A_NONE;
	    isWallCling    = false;
	    wallDir        = 0;
	    prevWallDir    = 0;
	    wallStickTimer = 0;
	    wallJumpLockTimer = 0;

	   if (downKey)
	{
	    groundState = GroundState.G_CROUCH;
	    mask_index = crouchMaskSpr;  // Use crouch mask
	}
	else
	{
	    // Try to use normal mask
	    mask_index = maskSpr;
    
	    // Check if there's room to stand up
	    if (place_meeting(x, y, obj_wall))
	    {
	        // Not enough room - stay crouched
	        groundState = GroundState.G_CROUCH;
	        mask_index = crouchMaskSpr;  // Put crouch mask back
	    }
	    else
	    {
	        // Room to stand - normal movement
	        var _absX = abs(xspd);

	        if (_absX < 0.1)
	        {
	            groundState = GroundState.G_IDLE;
	        }
	        else
	        {
	            if (runKey)
	            {
	                groundState = GroundState.G_RUN;
	            }
	            else
	            {
	                groundState = GroundState.G_WALK;
	            }
	        }
	    }
	}
}
else
// ----------- AIR STATES -----------
{
    groundState = GroundState.G_IDLE; // placeholder
    
    // Detect wall contact this frame (always check, even when climbing)
    var _touchLeft  = place_meeting(x - 1, y, obj_wall);
    var _touchRight = place_meeting(x + 1, y, obj_wall);
    
    // Determine current wall direction
    var _currentWallDir = 0;
    if (_touchLeft)       _currentWallDir = -1;
    else if (_touchRight) _currentWallDir = 1;
    
    var _touchingWall = (_currentWallDir != 0);
    var _falling = (yspd > 0);
    var _inputDir = rightKey - leftKey;
    var _inputTowardWall = (_inputDir == _currentWallDir);
    var _inputAwayFromWall = (_inputDir == -_currentWallDir && _inputDir != 0);
    
    // Skip wall interaction logic if climbing
    if (!isClimbing)
    {
        #region WALL JUMP STATE
        if (airState == AirState.A_WALLJUMP)
        {
            // Check for opposite wall grab (EXCEPTION CASE)
            if (_touchingWall && _currentWallDir == -prevWallDir)
            {
                // Re-enter wall cling on opposite wall!
                airState = AirState.A_WALLCLING;
                isWallCling = true;
                wallDir = _currentWallDir;
                wallStickTimer = wallStickFrames;
                lockY = true;
                
                // Don't update prevWallDir here - we want to track the chain
            }
            else
            {
                // Stay in wall jump until lock timer expires
                if (wallJumpLockTimer > 0)
                {
                    wallJumpLockTimer--;
                    wallDir = prevWallDir; // Keep tracking which wall we jumped from
                }
                else
                {
                    // Lock expired - exit to normal air state
                    if (_falling)
                    {
                        airState = AirState.A_FALL;
                    }
                    else
                    {
                        airState = AirState.A_NONE;
                    }
                    wallDir = 0;
                }
            }
        }
        #endregion

        #region WALL CLING STATE
        else if (airState == AirState.A_WALLCLING)
        {
            // Check if we should STAY in wall cling
            if (_touchingWall && !onGround)
            {
                wallDir = _currentWallDir;
                isWallCling = true;
                
                // Handle stick timer and Y locking
                if (wallStickTimer > 0)
                {
                    lockY = true;
                    wallStickTimer--;
                }
                else
                {
                    lockY = false;  // Release Y lock after stick timer
                }
                
                // Check for EXIT conditions
                
                // Exit 1: Input away from wall
                if (_inputAwayFromWall)
                {
                    airState = AirState.A_FALL;
                    isWallCling = false;
                    lockY = false;  // Explicitly release
                    wallStickTimer = 0;
                    prevWallDir = wallDir;
                    wallDir = 0;
                }
                // Exit 2: Jump key pressed (launch off wall)
                else if (jumpKeyPressed)
                {
                    // Enter WALL JUMP state
                    airState = AirState.A_WALLJUMP;
                    isWallCling = false;
                    lockY = false;  // Release Y lock when leaving wall cling
                    wallStickTimer = 0;
                    
                    // Set launch velocities
                    xspd = -wallDir * wallJumpXSpeed;
                    yspd = wallJumpYSpeed;
                    
                    // Flip facing direction
                    face = -wallDir;
                    
                    // Lock inputs (INCLUDING JUMP!)
                    inputLockMove = wallJumpLockFrames;
                    inputLockFace = wallJumpLockFrames;
                    inputLockJump = wallJumpLockFrames;  // NEW: Lock jump input
                    wallJumpLockTimer = wallJumpLockFrames;
                    
                    // Store which wall we jumped from
                    prevWallDir = wallDir;
                    
                    // Reset jump count to allow air mobility after wall jump
                    jumpCount = 1;
                    jumpHoldTimer = 0;
                    
                    // Clear jump buffer to prevent immediate consumption
                    jumpKeyBuffered = false;      // NEW
                    jumpKeyBufferTimer = 0;       // NEW
                }
            }
            else
            {
                // Lost contact with wall or hit ground - exit cling
                airState = _falling ? AirState.A_FALL : AirState.A_NONE;
                isWallCling = false;
                lockY = false;  // Explicitly release
                wallStickTimer = 0;
                prevWallDir = wallDir;
                wallDir = 0;
            }
        }
        #endregion
        
        #region NORMAL AIR STATES (NONE/FALL)
        else
        {
            // Check if we should ENTER wall cling (normal entry)
            if (_touchingWall && _falling && _inputTowardWall)
            {
                // Enter wall cling!
                airState = AirState.A_WALLCLING;
                isWallCling = true;
                wallDir = _currentWallDir;
                wallStickTimer = wallStickFrames;
                lockY = true;  // Only set when entering cling
                prevWallDir = 0;
            }
            else
            {
                // Stay in normal air state
                wallDir = 0;
                isWallCling = false;
                lockY = false;  // Make sure it's off in normal air
                
                if (_falling)
                {
                    airState = AirState.A_FALL;
                }
                else
                {
                    airState = AirState.A_NONE;
                }
            }
        }
        #endregion
    }  // End of if (!isClimbing)
}  // End of AIR STATES
#endregion

#region Y Movement
//-----------Y Movement-----------

#region Gravity
	// Basic gravity with coyote hang
	if (coyoteHangTimer > 0) {
	    coyoteHangTimer--;
	} else {
	    if (!gravityOverride && !isClimbing) {  // Add !isClimbing for clarity
	        // Wall cling gravity override
	        if (airState == AirState.A_WALLCLING)
	        {
	            if (lockY)
	            {
	                // Freeze during stick timer
	                yspd = 0;
	            }
	            else
	            {
	                // Slide down wall after stick timer
	                yspd = min(yspd + wallSlideAccel, wallSlideSpeed);
	            }
	        }
	        else
	        {
	            // Normal gravity
	            yspd += grav;
	        }
	    }
	    
	    // Don't call setOnGround while climbing
	    if (!isClimbing) {
	        setOnGround(false);
	    }
	}
#endregion

//Reset or prepare jumping variable
if onGround
{
    jumpCount       = 0;
    jumpHoldTimer   = 0;
    coyoteJumpTimer = coyoteJumpFrames;

    // Recharge dashes when grounded
    dashCharges = dashChargesMax;
    
    // Also prep dash for future use
    canDash = true;
} 
else 
{
    //if player is already in the air, make sure they dont get an extra-extra jump
    coyoteJumpTimer--;
    if jumpCount == 0 && coyoteJumpTimer <= 0 { jumpCount = 1; };
}

//Initiate Jump (with buffer & double jump)
if (jumpKeyBuffered && !downKey && jumpCount < jumpMax)
{
    jumpKeyBuffered    = false;
    jumpKeyBufferTimer = 0;
    jumpCount++;
    jumpHoldTimer = jumpHoldFrames[jumpCount - 1];
    setOnGround(false);
    coyoteJumpTimer = 0;
}

//Cut off the jump by releasing the jump button
if !jumpKey
{
    jumpHoldTimer = 0;
}

//Jump based on the timer/holding the button
if jumpHoldTimer > 0
{
    //Arrays make the second jumps weaker
    yspd = jspd[jumpCount-1];
    //Count down the timer
    jumpHoldTimer--;
}

// --- PREEMPTIVE: Y LOCK ---
if (lockY) {
    yspd = 0;
}
// --- END PREEMPTIVE: Y LOCK ---
#endregion 
	
#region Y Collision and Movement Logic
//-----------Y Collision and Movvement-----------

    //Cap falling speed
    if yspd > termVel { yspd = termVel; };
    //How close the player can get to a wall
    var _subPixel = .5;

    //Upwards Y collision
    if yspd < 0 && place_meeting( x, y + yspd, obj_wall )
    {
        //Jump into sloped ceilings
        var _slopeSlide = false;
        
        //Slide UpLeft slope
        if moveDir != 1 && !place_meeting( x - abs(yspd)-1, y + yspd, obj_wall )
        {
            while place_meeting( x, y + yspd, obj_wall ) { x -= 1; }; 
            _slopeSlide = true;
        }
        
        //Slide UpRight slope
        if moveDir != -1 && !place_meeting( x + abs(yspd) +1, y + yspd, obj_wall )
        {
            while place_meeting( x, y + yspd, obj_wall ) { x += 1; };
            _slopeSlide = true;
        }
        
        //Normal Y collision
        if !_slopeSlide
        {
        //Scott up to wall percisely
            var _pixelCheck = _subPixel * sign(yspd);
            while !place_meeting( x, y + _pixelCheck, obj_wall )
            {
                y += _pixelCheck;
            }
            //Set yspd to zero to "collide"
            yspd = 0;    
        }
    }
    
    
    //Floor Y collision 

    //Check for solid and semisolid platforms under me
    var _clampYspd = max( 0, yspd ); 
    //Create a DS (data structure) list to store all of the objects we run into
    var _list = ds_list_create();
    var _array = array_create (0);
    array_push( _array, obj_wall, obj_semiSolidWall );
    
    //Do the actual check and add objects to list
    var _listSize = instance_place_list( x, y+1 + _clampYspd + moveplatMaxYspd, _array, _list, false);
        
    //Loop through the colliding instances and only return one if it's top is bellow the player
    for (var i = 0; i < _listSize; i++)
    {
        //Get an instance of obj_wall or obj_semiSolidWall from the list
        var _listInst = _list [| i];
        //Avoid magnetism
        if _listInst !=forgetSemiSolid
        && (_listInst.yspd <= yspd || instance_exists(myFloorPlat) )
        && ( _listInst.yspd > 0 || place_meeting( x, y+1 + _clampYspd, _listInst) )
        {
            //Return a solid wall or any semisolid walls that are below the player
            if _listInst.object_index == obj_wall
            || object_is_ancestor( _listInst.object_index, obj_wall )
            || floor(bbox_bottom) <= ceil( _listInst.bbox_top - _listInst.yspd )
            {
                //Return the "highest" wall object
                if !instance_exists(myFloorPlat)
                || _listInst.bbox_top + _listInst.yspd <= myFloorPlat.bbox_top + myFloorPlat.yspd
                || _listInst.bbox_top + _listInst.yspd <= bbox_bottom
                {
                    myFloorPlat = _listInst;
                }
            } 
        }
    }
    //Destroy the DS list to avoid memory leak
    ds_list_destroy(_list);

    //One last check to make sure the floor platform is actually below us
    if instance_exists(myFloorPlat) && !place_meeting( x, y + moveplatMaxYspd,  myFloorPlat )
    {
        myFloorPlat = noone;
    }

    //Land on the ground platform if there is one
    if instance_exists(myFloorPlat) 
    {
        //scott up to wall percisely
        var _subPixel = .5;
        while !place_meeting( x, y + _subPixel, myFloorPlat ) && !place_meeting ( x, y, obj_wall ) { y += _subPixel; };
        //Make sure we dont end up on top of a semi solid
        if myFloorPlat.object_index == obj_semiSolidWall || object_is_ancestor(myFloorPlat.object_index, obj_semiSolidWall)
        {
            while place_meeting ( x, y, myFloorPlat ) { y -= _subPixel; };
        }
        //Floor the y variable
        y = floor(y);
        
        //Collide with the ground
        yspd = 0;
        setOnGround(true);
    }
    
    //Manually Fall Through a semisolid platform
    if (downKey && jumpKeyPressed)
    {
        //Make sure we have a floor plaform thats a semisolid
        if instance_exists(myFloorPlat)
        && ( myFloorPlat.object_index == obj_semiSolidWall || object_is_ancestor( myFloorPlat.object_index, obj_semiSolidWall) )
        {
            //Check if we Can go below the semisolid
            var _yCheck = y + max(1, myFloorPlat.yspd + 1 );
            if !place_meeting( x, _yCheck, obj_wall )
            {
                //Move below the platform
                y += 1;
                //Forget this platform for a brief time so we don't get caught again
                forgetSemiSolid = myFloorPlat;
                
                //No more floor platform
                setOnGround(false);
            }
        }
    }
    
    //Move
    if !place_meeting( x, y + yspd, obj_wall)
    {
        y += yspd;
    }
    //Reset forgetSemiSolid variable
    if instance_exists(forgetSemiSolid) && !place_meeting(x, y, forgetSemiSolid)
    {
        forgetSemiSolid = noone;
    }
#endregion

#region Moving platform collision and movement
//Final moving platfrom collisions and movement
        //X - moveplatXspd and collision
        //Get the moveplatXspd
        moveplatXspd = 0;
        if instance_exists(myFloorPlat) { moveplatXspd = myFloorPlat.xspd; };
        //Move with moveplatXspd
        if place_meeting( x + moveplatXspd, y, obj_wall )
        {
            var _subPixel = .5;
            var _pixelCheck = _subPixel * sign(moveplatXspd);
            while !place_meeting( x + _pixelCheck, y, obj_wall )
            {
                x += _pixelCheck;
            }
            //Set moveplatXspd to 0 to finish collision
            moveplatXspd = 0;
        }
        //Move
        x += moveplatXspd;
            //Scott up to wall precisely
#endregion

#region Jitter Fix for moving platforms?    
//Y - Snap myself to myFloorPlat if it's moving vertically          
    // Check if platform exists and is moving vertically
    if instance_exists(myFloorPlat) && myFloorPlat.yspd != 0
    {
        // Snap to the top of the floor platform
        if !place_meeting(x, myFloorPlat.bbox_top, obj_wall) 
        && myFloorPlat.bbox_top >= bbox_bottom - moveplatMaxYspd
        {
            y = myFloorPlat.bbox_top;
        }
    }
#endregion

#region Get pushed down through a semisolid by a moving solid platform     

// Get pushed down through a semisolid by a moving solid platform
    if instance_exists( myFloorPlat )
    &&  ( myFloorPlat.object_index == obj_semiSolidWall || object_is_ancestor( myFloorPlat.object_index, obj_semiSolidWall ))
    && place_meeting( x, y, obj_wall )
    {
        //If I'm already stuck in a wall at this point, try to move me down to get below a SEMISOLID
        //If I'm still stuck aftwerwards, that just means I've been CRUSHED
        
        //Also, dont check too far down
        var _maxPushDist = 10; //MUST BE LESS THAN THE HEIGHT OF THE PLAYER'S HITBOX
        var _pushedDist = 0;
        var _startY = y;
        while place_meeting( x, y, obj_wall ) && _pushedDist <= _maxPushDist
        {
            y++;
            _pushedDist++;
        }
        setOnGround(false)
        
        //If I'm still stuck in a wall at this point, I've been crushed regardless, take me back to my start y to avoid the "funk"
        if _pushedDist > _maxPushDist {y = _startY;};
        
    }
#endregion

#region Sprite and Animation Management

	// Detect state changes
	var _stateChanged = false;
	if (parentState != prevParentState)
	{
	    _stateChanged = true;
	}
	else if (parentState == ParentState.GROUND && groundState != prevGroundState)
	{
	    _stateChanged = true;
	}
	else if (parentState == ParentState.AIR && airState != prevAirState)
	{
	    _stateChanged = true;
	}

	// Release frame hold if state changed (but not during dash or climbing)
	if (_stateChanged && animHoldUntilStateChange && !isDashing && !isClimbing)
	{
	    animFrameHold = false;
	    animHoldFrame = 0;
	    animHoldUntilStateChange = false;
	}
// Set sprites and animation rules based on state
var _newSprite = sprite_index;
var _resetAnim = false;

// GLOBAL STATE: Attack has highest priority
if (isAttacking)
{
    // Select correct attack sprite
    if (attackName == "standingSwing1")
    {
        _newSprite = attackSwing1Spr;
    }
    else if (attackName == "crouch")
    {
        _newSprite = attackCrouchSpr;
    }
    else if (attackName == "jump")
    {
        _newSprite = attackAirSlashSpr;
    }
}
// GLOBAL STATE: Backstep (NEW - priority over dash)
else if (isBackStepping)
{
    _newSprite = backStepSpr;
    
    // FRAME HOLD: Hold frame 1 during backstep
    if (!animFrameHold || sprite_index != backStepSpr)
    {
        animFrameHold = true;
        animHoldFrame = 1;
        animHoldUntilStateChange = false;
    }
}
// GLOBAL STATE: Dash
else if (isDashing)
{
    _newSprite = dashStartSpr;
    
    // FRAME HOLD: Hold frame 1 during dash
    if (!animFrameHold || sprite_index != dashStartSpr)
    {
        animFrameHold = true;
        animHoldFrame = 1;
        animHoldUntilStateChange = false;
    }
}
// GLOBAL STATE: Climbing (second priority)
else if (isClimbing)
{
    if (yspd == 0)
    {
        // Idle on ladder - play idle animation
        _newSprite = ladderIdleSpr;
        animFrameHold = false;
        image_speed = 1;
    }
    else
    {
        // Climbing - play animation
        _newSprite = ladderClimbSpr;
        animFrameHold = false;
        
        // Reverse animation when descending
        if (yspd > 0)
        {
            image_speed = -1;  // Play backwards when going down
        }
        else
        {
            image_speed = 1;   // Play forwards when going up
        }
    }
}
// PARENT STATES: Ground
else if (parentState == ParentState.GROUND)
{
    if (groundState == GroundState.G_CROUCH)
    {
        // Crouch state
        var _absX = abs(xspd);
        
        if (_absX < 0.1)
        {
            // Crouching idle
            _newSprite = crouchIdleSpr;
            animFrameHold = false;
        }
        else
        {
            // Crouch walking
            _newSprite = crouchWalkSpr;
            animFrameHold = false;
        }
    }
    else if (groundState == GroundState.G_IDLE)
    {
        _newSprite = idleSpr;
        animFrameHold = false;
    }
    else if (groundState == GroundState.G_WALK)
    {
        _newSprite = walkSpr;
        animFrameHold = false;
    }
    else if (groundState == GroundState.G_RUN)
    {
        _newSprite = runSpr;
        animFrameHold = false;
    }
}
// PARENT STATES: Air
else
{
    if (airState == AirState.A_WALLCLING)
    {
        _newSprite = spr_wallSlide;
        animFrameHold = false;
    }
    else if (yspd < 0)
    {
        // Jumping/Rising
        _newSprite = jumpSpr;
        animFrameHold = false;
    }
    else
    {
        // Falling
        _newSprite = fallSpr;
        
        // Play first frame, then hold second frame
        if (sprite_index != fallSpr)
        {
            // Just entered fall state - reset to start
            animFrameHold = false;
            animHoldUntilStateChange = false;
        }
        else if (image_index >= 1 && !animFrameHold)
        {
            // Reached second frame - now hold it
            animFrameHold = true;
            animHoldFrame = 1;
            animHoldUntilStateChange = true;
        }
    }
}

// Change sprite if needed
if (_newSprite != sprite_index)
{
    sprite_index = _newSprite;
    _resetAnim = true;
}

// Handle animation playback
if (animFrameHold)
{
    image_speed = 0;
    image_index = animHoldFrame;
}
else
{
    // Don't reset image_speed if climbing set it already
    if (!isClimbing || yspd == 0)
    {
        image_speed = 1;
    }
    
    if (_resetAnim)
    {
        image_index = 0;
    }
}

// Release frame hold when exiting global states
if (!isDashing && sprite_index == dashStartSpr)
{
    animFrameHold = false;
}
if (!isBackStepping && sprite_index == backStepSpr)  
{
    animFrameHold = false;
}

// Store current state for next frame's comparison
prevParentState = parentState;
prevGroundState = groundState;
prevAirState = airState;

#endregion

// --- PREEMPTIVE: TICK DOWN LOCK TIMERS ---

// --- DASH COOLDOWN ---
if (dashCooldownTimer > 0) dashCooldownTimer--;

if (inputLockMove > 0)  inputLockMove--;
if (inputLockFace > 0)  inputLockFace--;
if (inputLockJump > 0)  inputLockJump--;
// --- END PREEMPTIVE: TICK DOWN LOCK TIMERS ---

#region Debug

// Toggle hurtbox visualization
if (debugHurtboxKey)
{
    with (obj_hurtbox)
    {
        debug_show = !debug_show;
    }
}
#endregion

#region AFTERIMAGE SPAWNING
// Determine if afterimages should spawn
afterimageEnabled = false;

// Trigger 1: Dashing
if (isDashing)
{
    afterimageEnabled = true;
    afterimageColor = c_aqua;  // Cyan dash trails
}

// Trigger 2: Backstepping (NEW)
if (isBackStepping)
{
    afterimageEnabled = true;
    afterimageColor = c_orange;  // Orange backstep trails
}

// Trigger 2: Wall jumping
if (airState == AirState.A_WALLJUMP && wallJumpLockTimer > 0)
{
    afterimageEnabled = true;
    afterimageColor = c_yellow;  // Yellow wall jump trails
}

// Trigger 3: Moving fast (horizontal OR vertical speed > 4)
if (abs(xspd) > 4 || abs(yspd) > 4)
{
    afterimageEnabled = true;
    afterimageColor = c_white;  // White speed trails
}

// Trigger 4: Grappling
if (grappling)
{
    afterimageEnabled = true;
    afterimageColor = c_lime;  // Green grapple trails
}

// Spawn afterimage if enabled
if (afterimageEnabled)
{
    afterimageTimer++;
    
    if (afterimageTimer >= afterimageSpawnRate)
    {
        // Create afterimage
        var _afterimage = instance_create_depth(x, y, depth + 1, obj_afterimage);
        
        // Pass current visual data to afterimage
        _afterimage.stored_sprite = sprite_index;
        _afterimage.stored_frame = image_index;
        _afterimage.stored_x = x;
        _afterimage.stored_y = y;
        _afterimage.stored_xscale = image_xscale * face;  // Include facing
        _afterimage.stored_yscale = image_yscale;
        _afterimage.stored_angle = image_angle;
        _afterimage.stored_color = afterimageColor;
        
        // Reset timer
        afterimageTimer = 0;
    }
}
else
{
    // Reset timer when not active
    afterimageTimer = 0;
}
#endregion

#region FX SPAWNING SYSTEM

// === TRACK CONDITIONS ===
var isWallSliding = (airState == AirState.A_WALLCLING && wallStickTimer <= 0);

// === DASH DUST ===
if (isDashing && dashLockTimer == dashLockFrames - 1)  // First frame of dash
{
    var _fx = instance_create_depth(x, y, depth + 1, obj_fxDashDust);
    _fx.owner = id;
    _fx.initializeFX();
}

// === BACKSTEP DUST ===
if (isBackStepping && backStepLockTimer == backStepLockFrames - 1)  // First frame of backstep
{
    var _fx = instance_create_depth(x, y, depth + 1, obj_fxBackStepDust);
    _fx.owner = id;
    _fx.initializeFX();
}

// === JUMP DUST (SIMPLE VERSION) ===
// Track previous jump count
if (!variable_instance_exists(id, "prevJumpCount"))
{
    prevJumpCount = 0;
}

// Spawn dust when first jump occurs
if (jumpCount > prevJumpCount && jumpCount == 1)  // Only first jump
{
    var _fx = instance_create_depth(x, y, depth + 1, obj_fxJumpDust);
    _fx.owner = id;
    _fx.initializeFX();
}

prevJumpCount = jumpCount;

// === WALL JUMP DUST ===
// Track previous air state
if (!variable_instance_exists(id, "prevAirStateWallJump"))
{
    prevAirStateWallJump = AirState.A_NONE;
}

// Spawn dust when transitioning FROM wall cling TO wall jump
if (prevAirStateWallJump == AirState.A_WALLCLING && airState == AirState.A_WALLJUMP)
{
    var _fx = instance_create_depth(x, y, depth + 1, obj_fxWallJumpDust);
    _fx.owner = id;
    
    // IMPORTANT: Store the wall direction BEFORE initializing
    // (because wallDir might change after the jump)
    _fx.fxDirection = prevWallDir;  // Use the wall we jumped FROM
    
    _fx.initializeFX();
}

prevAirStateWallJump = airState;
// === DOUBLE JUMP DUST ===
// Track previous jump count for double jump
if (!variable_instance_exists(id, "prevJumpCountDouble"))
{
    prevJumpCountDouble = 0;
}

// Spawn dust when second jump occurs (double jump)
if (jumpCount > prevJumpCountDouble && jumpCount == 2)  // Only second jump
{
    var _fx = instance_create_depth(x, y, depth - 1, obj_fxDoubleJump);
    _fx.owner = id;
    _fx.initializeFX();
}

prevJumpCountDouble = jumpCount;

// === LANDING DUST ===
// Track previous ground state
if (!variable_instance_exists(id, "prevOnGround"))
{
    prevOnGround = false;
}

// Spawn dust when landing (transition from air to ground)
if (onGround && !prevOnGround)
{
    var _fx = instance_create_depth(x, y, depth + 1, obj_fxLandingDust);
    _fx.owner = id;
    _fx.initializeFX();
}

prevOnGround = onGround;

// === RUNNING DUST ===
// Track timer for periodic spawning
if (!variable_instance_exists(id, "runDustTimer"))
{
    runDustTimer = 0;
}

// Spawn dust periodically while running on ground
if (onGround && groundState == GroundState.G_RUN && abs(xspd) > 2)
{
    runDustTimer++;
    
    // Spawn every 8 frames (adjust for more/less frequent dust)
    if (runDustTimer >= 8)
    {
        var _fx = instance_create_depth(x, y, depth + 1, obj_fxRunDust);
        _fx.owner = id;
        _fx.initializeFX();
        
        runDustTimer = 0;  // Reset timer
    }
}
else
{
    // Reset timer when not running
    runDustTimer = 0;
}

// === WALL SLIDE FX ===
// Track if wall slide FX exists
if (!variable_instance_exists(id, "myWallSlideFX"))
{
    myWallSlideFX = noone;
}

// Spawn wall slide FX when entering wall slide
if (isWallSliding && !instance_exists(myWallSlideFX))
{
    myWallSlideFX = instance_create_depth(x, y, depth - 1, obj_fxWallSlide);
    myWallSlideFX.owner = id;
    myWallSlideFX.initializeFX();
}

// Clean up reference if FX is destroyed
if (!instance_exists(myWallSlideFX))
{
    myWallSlideFX = noone;
}

#endregion