extends KinematicBody2D

var username_text = load("res://UserNameText.tscn")

export (int) var speed = 500
export (int) var jump_speed = -1800
export (int) var gravity = 4000

puppet var puppet_position = Vector2.ZERO setget puppet_position_set
puppet var puppet_velocity = Vector2()
puppet var puppet_sprite = ""
puppet var puppet_flip = false
puppet var puppet_scale = Vector2(1,1)
puppet var puppet_username = "" setget puppet_username_set
puppet var puppet_cast_to = Vector2.ZERO
puppet var puppet_dead = false
puppet var puppet_emitting = false

onready var sprite = $AnimatedSprite
onready var tween = $Tween
onready var camera = $Camera2D
onready var ray_cast = $RayCast2D
onready var particles = $DeathParticles
onready var control_button = $ControlUI/Buttons


var velocity = Vector2.ZERO
var was_on_floor = false
var username setget username_set
var username_text_instance = null
var pushing_force = 10
var dead = false

var _moving_direction = 0 # left<0<right
var _jump_touch_pressed = false

# PRIVATES
func _ready() -> void:
	get_tree().connect("network_peer_connected",self,"_network_peer_connected")
	username_text_instance = Global.instance_node_at_location(username_text,Persistents, global_position)
	username_text_instance.player_following = self
	if OS.get_name() != "Windows":
		control_button.visible = true

func _process(delta) -> void:
	if username_text_instance != null:
		username_text_instance.name = "username" + name
	if get_tree().has_network_peer():
		if is_network_master():
			camera.current = true
			if not dead:
				_get_input()
			else:
				velocity = Vector2.ZERO
			_apply_animation()
			_normalize_animation_scale(delta)
			rset("puppet_cast_to", ray_cast.cast_to)
			was_on_floor=is_on_floor()
			velocity.y += gravity * delta
			rpc_unreliable("push_on_collision",velocity)
			velocity = move_and_slide(velocity, Vector2.UP)
		else:
			rpc_unreliable("push_on_collision",puppet_velocity)
			if not tween.is_active():
				move_and_slide(puppet_velocity)
			_apply_animation_over_network()

func init_prompt() -> void:
	for child in Persistents.get_children():
		if child.is_in_group("Net"):
			child.queue_free()
	Network.reset_network_connection()
	if Global.ui != null:
		var prompt = Global.instance_node(load("res://SimplePrompt.tscn"), Global.ui)
		prompt.set_text("Disconnected from server")

func dis() -> void:
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			Network.server.close_connection()
		elif is_network_master():
			Network.client.close_connection()
		init_prompt()


func _get_input() -> void:
	velocity.x = 0
	if Input.is_action_pressed("ui_right") or _moving_direction>0:
		velocity.x += speed
	if Input.is_action_pressed("ui_left") or _moving_direction<0:
		velocity.x -= speed
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			jump(1)
	if Input.is_action_just_pressed("ui_focus_next"):
		print("hi")
		dis()

func _apply_animation() -> void:
	#flip animations
	if velocity.x!=0:
		if velocity.x>0:
			sprite.flip_h=false
		else:
			sprite.flip_h=true
	#flip ray cast
	if sprite.flip_h:
		ray_cast.cast_to.x = abs(ray_cast.cast_to.x)*-1
	else:
		ray_cast.cast_to.x = abs(ray_cast.cast_to.x)
	#set animations
	if is_on_floor():
		if abs(velocity.x)>0:
			sprite.play("walk")
		else:
			sprite.play("idle")
	else:
		sprite.play("jump")
	#bounce when drop
	if is_on_floor() and !was_on_floor:
		sprite.scale = Vector2(1.1, 0.9)
	if dead:
		sprite.visible= false
		particles.emitting = true
	else:
		sprite.visible = true

func _normalize_animation_scale(delta) -> void:
	sprite.scale = sprite.scale.linear_interpolate(Vector2(1, 1), delta * 12)

func _apply_animation_over_network() -> void:
		sprite.visible = !puppet_dead
		particles.emitting = puppet_emitting
		sprite.play(puppet_sprite)
		sprite.flip_h = puppet_flip
		sprite.scale = puppet_scale
		ray_cast.cast_to = puppet_cast_to

func _network_peer_connected(id) -> void:
	rset_id(id,"puppet_username", username)

#PUBLICS
sync func player_is_dead() -> void:
	Global.someone_is_dead = true

sync func push_on_collision(vel):
	if ray_cast.is_colliding():
		if ray_cast.get_collider()!=null:
			if ray_cast.get_collider().is_in_group("Crate"):
				ray_cast.get_collider().push(Vector2(vel.x,0))

sync func jump(multiplier) -> void:
	sprite.scale = Vector2(0.75, 1.25)
	velocity.y = jump_speed * multiplier

sync func update_player_position(new_position) -> void:
	global_position = new_position
	puppet_position = new_position

func username_set(new_value) -> void:
	username = new_value
	if get_tree().has_network_peer():
		if is_network_master() and username_text_instance != null:
			username_text_instance.text = username
			username_text_instance.color = Color.green
			rset("puppet_username", username)

func puppet_username_set(new_value) -> void:
	puppet_username = new_value
	if get_tree().has_network_peer():
		if not is_network_master() and username_text_instance != null:
			username_text_instance.text = puppet_username

func puppet_position_set(new_value) -> void:
	puppet_position=new_value
	if get_tree().has_network_peer():
		if not is_network_master():
			tween.interpolate_property(self,"global_position",global_position,puppet_position,0.05)
			tween.start()

func set_cam_limit(left, top, right, bottom) -> void:
	camera.limit_left = left
	camera.limit_top = top
	camera.limit_right = right
	camera.limit_bottom = bottom

func emit_death() -> void:
	dead = true
	yield(get_tree().create_timer(1),"timeout")
	rpc("player_is_dead")

#SIGNALS
func _on_Network_tick_rate_timeout():
	if get_tree().has_network_peer():
		if is_network_master():
			rset_unreliable("puppet_position",global_position)
			rset_unreliable("puppet_velocity",velocity)
			rset_unreliable("puppet_sprite",sprite.animation)
			rset_unreliable("puppet_flip",sprite.flip_h)
			rset_unreliable("puppet_scale",sprite.scale)
			rset_unreliable("puppet_dead",dead)
			rset_unreliable("puppet_emitting",particles.emitting)

func _on_HitBox_area_entered(area):
	if get_tree().has_network_peer():
		if is_network_master():
			if area.is_in_group("Player_jump_booster"):
				rpc("jump",area.multiplier)
			if area.is_in_group("Player_damager"):
				emit_death()

func _on_MoveRightButton_button_up():
	_moving_direction = 0

func _on_MoveLeftTouchButton_pressed():
	_moving_direction = -1

func _on_MoveLeftTouchButton_released():
	_moving_direction = 0

func _on_MoveRightTouchButton_pressed():
	_moving_direction = 1

func _on_MoveRightTouchButton_released():
	_moving_direction = 0

func _on_JumpTouchButton_pressed():
	if not _jump_touch_pressed:
		_jump_touch_pressed = true
		if is_on_floor():
			jump(1)

func _on_JumpTouchButton_released():
	_jump_touch_pressed = false

