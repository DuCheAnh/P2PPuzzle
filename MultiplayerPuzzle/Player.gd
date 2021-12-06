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
puppet var puppet_hp = 10 setget puppet_hp_set
puppet var puppet_username = "" setget puppet_username_set
puppet var puppet_cast_to = Vector2.ZERO
onready var sprite = $AnimatedSprite
onready var tween = $Tween
onready var hit_timer = $HitTimer
onready var camera = $Camera2D
onready var ray_cast = $RayCast2D
var hp = 10 setget set_hp
var velocity = Vector2.ZERO
var was_on_floor = false
var username setget username_set
var username_text_instance = null
var pushing_force = 10
# PRIVATES
func _ready() -> void:
	get_tree().connect("network_peer_connected",self,"_network_peer_connected")
	username_text_instance = Global.instance_node_at_location(username_text,Persistents, global_position)
	username_text_instance.player_following = self

func _process(delta) -> void:
	if username_text_instance != null:
		username_text_instance.name = "username" + name
	if get_tree().has_network_peer():
		if is_network_master():
			camera.current = true
			_get_input()
			_apply_animation()
			_normalize_animation_scale(delta)
			rset("puppet_cast_to", ray_cast.cast_to)
			was_on_floor=is_on_floor()
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP, false, 4, PI/4, false)
			rpc_unreliable("push_on_collision",velocity)
		else:
			if not tween.is_active():
				move_and_slide(puppet_velocity)
			rpc_unreliable("push_on_collision",puppet_velocity)
			_apply_animation_over_network()


func _get_input() -> void:
	velocity.x = 0
	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
	if Input.is_action_pressed("ui_left"):
		velocity.x -= speed
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			jump(1)
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

func _normalize_animation_scale(delta) -> void:
	sprite.scale = sprite.scale.linear_interpolate(Vector2(1, 1), delta * 12)

func _apply_animation_over_network() -> void:
		sprite.play(puppet_sprite)
		sprite.flip_h = puppet_flip
		sprite.scale = puppet_scale
		ray_cast.cast_to = puppet_cast_to

func _network_peer_connected(id) -> void:
	rset_id(id,"puppet_username", username)

#PUBLICS
sync func push_on_collision(vel):
	if ray_cast.is_colliding():
		if ray_cast.get_collider().is_in_group("Crate"):
			ray_cast.get_collider().push(Vector2(vel.x,0))
sync func jump(multiplier) -> void:
	sprite.scale = Vector2(0.75, 1.25)
	velocity.y = jump_speed * multiplier

sync func update_player_position(new_position) -> void:
	global_position = new_position
	puppet_position = new_position

func set_hp(new_value) -> void:
	hp = new_value
	if get_tree().has_network_peer():
		if is_network_master():
			rset("puppet_hp",hp)

func username_set(new_value) -> void:
	username = new_value
	if get_tree().has_network_peer():
		if is_network_master() and username_text_instance != null:
			username_text_instance.text = username
			rset("puppet_username", username)

func puppet_username_set(new_value) -> void:
	puppet_username = new_value
	if get_tree().has_network_peer():
		if not is_network_master() and username_text_instance != null:
			username_text_instance.text = puppet_username

func puppet_hp_set(new_value) -> void:
	puppet_hp = new_value
	if get_tree().has_network_peer():
		if not is_network_master():
			hp = puppet_hp

func puppet_position_set(new_value) -> void:
	puppet_position=new_value
	if get_tree().has_network_peer():
		if not is_network_master():
			tween.interpolate_property(self,"global_position",global_position,puppet_position,0.05)
			tween.start()



#SIGNALS
func _on_Network_tick_rate_timeout():
	if get_tree().has_network_peer():
		if is_network_master():
			rset_unreliable("puppet_position",global_position)
			rset_unreliable("puppet_velocity",velocity)
			rset_unreliable("puppet_sprite",sprite.animation)
			rset_unreliable("puppet_flip",sprite.flip_h)
			rset_unreliable("puppet_scale",sprite.scale)

func _on_HitBox_area_entered(area):
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			if area.is_in_group("Player_jump_booster"):
				rpc("jump",area.multiplier)
			if area.is_in_group("Player_damager"):
				rpc("player_is_dead")

sync func player_is_dead() -> void:
	Global.someone_is_dead = true





