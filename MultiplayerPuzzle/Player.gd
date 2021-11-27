extends KinematicBody2D

export (int) var speed = 500
export (int) var jump_speed = -1800
export (int) var gravity = 4000

puppet var puppet_position = Vector2.ZERO setget puppet_position_set
puppet var puppet_velocity = Vector2()
puppet var puppet_sprite = ""
puppet var puppet_flip = false
puppet var puppet_scale = Vector2(1,1)
onready var sprite = $AnimatedSprite
onready var tween = $Tween

var velocity = Vector2.ZERO
var was_on_floor=false
func _process(delta):
	if is_network_master():
		_get_input()
		_apply_animation()
		_normalize_animation_scale(delta)
		was_on_floor=is_on_floor()
#		velocity.y += gravity * delta
		velocity = move_and_slide(velocity, Vector2.UP)
	else:
		if not tween.is_active():
			move_and_slide(puppet_velocity)
		_apply_animation_over_network()
func _get_input() -> void:
	velocity.x = 0
	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
		sprite.scale = Vector2(1.2,0.8)
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
		sprite.flip_h=puppet_flip
		sprite.scale=puppet_scale
func jump(multiplier) -> void:
	sprite.scale = Vector2(0.75, 1.25)
	velocity.y = jump_speed * multiplier

func puppet_position_set(new_value) -> void:
	puppet_position=new_value
	tween.interpolate_property(self,"global_position",global_position,puppet_position,0.05)
	tween.start()
	pass
func _on_Network_tick_rate_timeout():
	if is_network_master():
		rset_unreliable("puppet_position",global_position)
		rset_unreliable("puppet_velocity",velocity)
		rset_unreliable("puppet_sprite",sprite.animation)
		rset_unreliable("puppet_flip",sprite.flip_h)
		rset_unreliable("puppet_scale",sprite.scale)
