
extends KinematicBody2D

const GRAVITY_VEC = Vector2(0,900)
const FLOOR_NORMAL = Vector2(0,-1)
const SLOPE_SLIDE_STOP = 25.0
const MIN_ONAIR_TIME = 0.1
const WALK_SPEED = 250 # pixels/sec
const JUMP_SPEED = 480
const SIDING_CHANGE_SPEED = 10
const BULLET_VELOCITY = 1000
const SHOOT_TIME_SHOW_WEAPON = 0.2

var linear_vel = Vector2()
var onair_time = 0 # 
var on_floor = false
var shoot_time=99999 #time since last shot

var anim=""
export var index=1

#cache the sprite here for fast access (we will set scale to flip it often)
onready var sprite = get_node("sprite")

func _fixed_process(delta):
	
	#increment counters
	
	onair_time+=delta
	shoot_time+=delta
	
	
	### MOVEMENT ###
	
	# Apply Gravity
	linear_vel += delta * GRAVITY_VEC
	# Move and Slide
	linear_vel = move_and_slide( linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP )
	# Detect Floor
	if (is_move_and_slide_on_floor()):
		onair_time=0		
		
	on_floor = onair_time < MIN_ONAIR_TIME
	
	### CONTROL ###
	
	# Horizontal Movement
	var target_speed = 0
	if (Input.is_action_pressed("move_left"+str(index))):
		target_speed += -1
	if (Input.is_action_pressed("move_right"+str(index))):
		target_speed +=  1
		
	target_speed *= WALK_SPEED
	linear_vel.x = lerp( linear_vel.x, target_speed, 0.1 )
	
	# Jumping
	if (on_floor and Input.is_action_just_pressed("jump"+str(index))):
		linear_vel.y=-JUMP_SPEED
		get_node("sound").play("jump")
	
	# Shooting		
	
	if (Input.is_action_just_pressed("shoot"+str(index))):
		
		var bullet = preload("res://bullet.tscn").instance()
		bullet.set_pos( get_node("sprite/bullet_shoot").get_global_pos() ) #use node for shoot position
		bullet.set_linear_velocity( Vector2( sprite.get_scale().x * BULLET_VELOCITY,0 ) )		
		bullet.add_collision_exception_with(self) # don't want player to collide with bullet
		get_parent().add_child( bullet ) #don't want bullet to move with me, so add it as child of parent
		get_node("sound").play("shoot")
		shoot_time=0
		
		
	### ANIMATION ###
	
	var new_anim="idle"
	
	if (on_floor):
		if (linear_vel.x < -SIDING_CHANGE_SPEED):
			sprite.set_scale( Vector2( -1, 1 ) )
			new_anim="run"
			
		if (linear_vel.x > SIDING_CHANGE_SPEED):
			sprite.set_scale( Vector2( 1, 1 ) )
			new_anim="run"
			
	else:
		
		if (linear_vel.y < 0 ):
			new_anim="jumping"
		else:
			new_anim="falling"
		
	if (shoot_time < SHOOT_TIME_SHOW_WEAPON):
		new_anim+="_weapon"
	
	if (new_anim!=anim):
		anim=new_anim
		get_node("anim").play(anim)
	
	
func _ready():
	set_fixed_process(true)

