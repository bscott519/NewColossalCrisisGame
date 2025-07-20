extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var animated_sprite_mg_death = $MGSprites/MGDeath

enum State { IDLE, CHASE, LEFTSWIPE, RIGHTSWIPE, LEFTBLAST, RIGHTBLAST, LASEREYES, DEATH }

signal master_giant_died

@onready var detection_area = $Detection
@onready var attack_cooldown = $AttackCooldown
@onready var attack_radius = $AttackRadius
@onready var head_hurtbox = $MGSprites/Head/CcMasterGiantHead/HeadHurtbox
@onready var head_hitbox = $MGSprites/Head/CcMasterGiantHead/HeadHitBox
@onready var right_hand_hurtbox = $MGSprites/RightHand/CcMasterGiantRighHand/RightHandHurtbox
@onready var right_hand_hitbox = $MGSprites/RightHand/CcMasterGiantRighHand/RightHandHitbox
@onready var left_hand_hurtbox = $MGSprites/LeftHand/CcMasterGiantLeftHand/LeftHandHurtbox
@onready var left_hand_hitbox = $MGSprites/LeftHand/CcMasterGiantLeftHand/LeftHandHitbox

var player_in_attack_radius = false
var knockback_strength : float = 500
var is_knocked_back: bool = false
var knockback_dur: float = 0.2
var is_chasing: bool = false
var can_walk: bool
var beam_1_can_dmg = false
var beam_2_can_dmg = false
var was_damaged_this_frame := false

var mG_dmg: int = 0
var can_dmg: bool = true
var dmg_cooldown: float = 1.0

var current_state = State.IDLE
var player = null
var speed = 150
var attack_range = 90
var dead: bool = false
var took_dmg: bool = false
var health = 15
var max_health = 15
var min_health = 0
var dmg_to_deal = 2
var is_deal_dmg: bool = false

func _ready():
	detection_area.connect("body_entered", _on_body_entered)
	attack_radius.connect("body_entered", _on_attack_radius_body_entered)
	
	animation_player.connect("animation_finished", _on_animation_player_animation_finished)
	
	attack_cooldown.start()

func _physics_process(delta):
	if dead:
		return
	
	was_damaged_this_frame = false
	
	$MGHealthBar.value = health
	
	match current_state:
		State.IDLE:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")

		State.CHASE:
			if player:
				var direction = (player.global_position - global_position).normalized()
				velocity = direction * speed
				velocity.y = 0
				move_and_slide()
				
				if animation_player.current_animation != "chase":
					animation_player.play("chase")
					
				var dist = global_position.distance_to(player.global_position)
				if dist < attack_range and attack_cooldown.time_left == 0:
					choose_attack()
					attack_cooldown.start()
			
		State.LEFTSWIPE, State.RIGHTSWIPE, State.LEFTBLAST, State.RIGHTBLAST, State.LASEREYES:
			velocity = Vector2.ZERO

func choose_attack():
	if dead:
		return
	var rand = randi() % 5
	match rand:
		0: change_state(State.LEFTSWIPE)
		1: change_state(State.RIGHTSWIPE)
		2: change_state(State.LEFTBLAST)
		3: change_state(State.RIGHTBLAST)
		4: change_state(State.LASEREYES)

func _on_body_entered(body):
	if body.name == "player":
		player = body
		change_state(State.CHASE)

func _on_attack_radius_body_entered(body):
	if dead: 
		return
	if body.name == "player":
		player = body
		player_in_attack_radius = true
		choose_attack()
		print("Player entered attack radius")

func _on_attack_radius_body_exited(body):
	if body.name == "player":
		player_in_attack_radius = false

func change_state(new_state):
	current_state = new_state
	match new_state:
		State.LEFTSWIPE:
			print("Entering LEFTSWIPE")
			velocity = Vector2.ZERO
			animation_player.play("LeftHandAttack")
			#enable_eg_damage_area.start(0.5)
			#disable_eg_damage_area.start(0.8)
			attack_cooldown.start()

		State.RIGHTSWIPE:
			print("Entering RIGHTSWIPE")
			velocity = Vector2.ZERO
			animation_player.play("RightHandAttack")
			#enable_eg_damage_area.start(0.3)
			#disable_eg_damage_area.start(0.6)
			attack_cooldown.start()

		State.LEFTBLAST:
			print("Entering LEFTBLAST")
			velocity = Vector2.ZERO
			animation_player.play("LeftHandBlast")
			attack_cooldown.start()
			
		State.RIGHTBLAST:
			print("Entering RIGHTBLAST")
			velocity = Vector2.ZERO
			animation_player.play("RightHandBlast")
			attack_cooldown.start()
			
		State.LASEREYES:
			print("Entering LASEREYES")
			velocity = Vector2.ZERO
			animation_player.play("LaserEyes")
			#mg_fire_beam_2()
			attack_cooldown.start()

func _on_animation_player_animation_finished(anim_name):
	if dead:
		return
	#if anim_name == "LaserEyes":
		#mg_stop_beam_2()
	if current_state in [State.LEFTSWIPE, State.RIGHTSWIPE, State.LEFTBLAST, State.RIGHTBLAST, State.LASEREYES]:
			print("Finished attack animation:", current_state)
			change_state(State.CHASE)

func _on_attack_cooldown_timeout():
	if dead:
		return
	if player_in_attack_radius:
		choose_attack()

func take_dmg(dmg, knockback_dir):
	health -= dmg
	print("Master Giant takes ", dmg, " damage. Health now: ", health)
	apply_knockback(knockback_dir)
	took_dmg = true
	
	if health <= min_health:
		health = min_health
	
		if dead:
			return
		
		dead = true
		current_state = State.DEATH
	
		$MGHealthBar.hide()
		$MainCollisionShape2D.set_deferred("disabled", true) 
		head_hurtbox.set_deferred("disabled", true)
		left_hand_hurtbox.set_deferred("disabled", true)
		right_hand_hurtbox.set_deferred("disabled", true)
		head_hitbox.set_deferred("disabled", true)
		right_hand_hitbox.set_deferred("disabled", true)
		left_hand_hitbox.set_deferred("disabled", true)
		
		velocity = Vector2.ZERO
		is_chasing = false
		can_walk = false
		animation_player.stop()
		
		$MGDeath.play()
		animated_sprite_mg_death.play("death")

		await animated_sprite_mg_death.animation_finished
		emit_signal("master_giant_died")
		queue_free()

func apply_knockback(knockback_dir: Vector2):
	if is_knocked_back:
		return
	is_knocked_back = true
	velocity.x = knockback_dir.x * knockback_strength  
	velocity.y = 0
	
	move_and_slide()
	
	await get_tree().create_timer(knockback_dur).timeout 
	is_knocked_back = false 
	velocity.x = 0
	
	move_and_slide()

func start_dmg_cooldown():
	await get_tree().create_timer(dmg_cooldown).timeout
	can_dmg = true

func _on_head_hit_box_area_entered(area):
	if dead or was_damaged_this_frame or not can_dmg or not area.is_in_group("damagezone"):
		return
	was_damaged_this_frame = true
	can_dmg = false
	print("Player entered Master Giant Head.")
	start_dmg_cooldown()
	var knockback_dir = (area.global_position - global_position).normalized()
	take_dmg(1, knockback_dir)

func _on_right_hand_hitbox_area_entered(area):
	if dead or was_damaged_this_frame or not can_dmg or not area.is_in_group("damagezone"):
		return
	was_damaged_this_frame = true
	can_dmg = false
	print("Player entered Master Giant Right Hand.")
	start_dmg_cooldown()
	var knockback_dir = (area.global_position - global_position).normalized()
	take_dmg(1, knockback_dir)

func _on_left_hand_hitbox_area_entered(area):
	if dead or was_damaged_this_frame or not can_dmg or not area.is_in_group("damagezone"):
		return
	was_damaged_this_frame = true
	can_dmg = false
	print("Player entered Master Giant Left Hand.")
	start_dmg_cooldown()
	var knockback_dir = (area.global_position - global_position).normalized()
	take_dmg(1, knockback_dir)

func _on_head_hurtbox_body_entered(body):
	if can_dmg and body.is_in_group("player"):
		print("Player entered Master Giant Head")
		var knockback_dir = (body.global_position - global_position).normalized()
		body.plyr_take_dmg(dmg_to_deal, knockback_dir)
		can_dmg = false
		start_dmg_cooldown()

func _on_right_hand_hurtbox_body_entered(body):
	if can_dmg and body.is_in_group("player"):
		print("Player entered Master Giant Right Hand")
		var knockback_dir = (body.global_position - global_position).normalized()
		body.plyr_take_dmg(dmg_to_deal, knockback_dir)
		can_dmg = false
		start_dmg_cooldown()
		
func _on_left_hand_hurtbox_body_entered(body):
	if can_dmg and body.is_in_group("player"):
		print("Player entered Master Giant Left Hand")
		var knockback_dir = (body.global_position - global_position).normalized()
		body.plyr_take_dmg(dmg_to_deal, knockback_dir)
		can_dmg = false
		start_dmg_cooldown()

func mg_fire_beam_1():
	beam_1_can_dmg = true
	$MGSprites/MasterBeam/BeamHurtBox.monitoring = true
	$MGSprites/MasterBeam/BeamHurtBox/BeamCollisionShape.disabled = false
	$MGSprites/MasterBeam/BeamHurtBox.visible = true

func mg_stop_beam_1():
	beam_1_can_dmg = false
	$MGSprites/MasterBeam/BeamHurtBox.monitoring = false
	$MGSprites/MasterBeam/BeamHurtBox/BeamCollisionShape.disabled = true
	$MGSprites/MasterBeam/BeamHurtBox.visible = false

func mg_fire_beam_2():
	beam_2_can_dmg = true
	$MGSprites/MasterBeam2/BeamHurtBox2.monitoring = true
	$MGSprites/MasterBeam2/BeamHurtBox2/BeamCollisionShape2.disabled = false
	$MGSprites/MasterBeam2/BeamHurtBox2.visible = true

func mg_stop_beam_2():
	beam_2_can_dmg = false
	$MGSprites/MasterBeam2/BeamHurtBox2.monitoring = false
	$MGSprites/MasterBeam2/BeamHurtBox2/BeamCollisionShape2.disabled = true
	$MGSprites/MasterBeam2/BeamHurtBox2.visible = false

func _on_beam_hurt_box_body_entered(body):
	if can_dmg and beam_1_can_dmg and body.is_in_group("player"):
		print("Player entered Master Giant laser 1.")
		var knockback_dir = (body.global_position - global_position).normalized()
		body.plyr_take_dmg(dmg_to_deal, knockback_dir)
		can_dmg = false
		start_dmg_cooldown()

func _on_beam_hurt_box_2_body_entered(body):
	print("Beam 2 body entered:", body)
	print("can_dmg: ", can_dmg, "beam_2_can_dmg: ", beam_2_can_dmg, "is player? ", body.is_in_group("player"))
	if can_dmg and beam_2_can_dmg and body.is_in_group("player"):
		print("Player entered Master Giant laser 2.")
		var knockback_dir = (body.global_position - global_position).normalized()
		body.plyr_take_dmg(dmg_to_deal, knockback_dir)
		can_dmg = false
		start_dmg_cooldown()
