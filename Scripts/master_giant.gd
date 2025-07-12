extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var animated_sprite_mg_death = $MGSprites/MGDeath

enum State { IDLE, CHASE, LEFTSWIPE, RIGHTSWIPE, LEFTBLAST, RIGHTBLAST, LASEREYES, DEATH }

signal master_giant_died

@onready var detection_area = $Detection
@onready var attack_cooldown = $AttackCooldown
@onready var attack_radius = $AttackRadius
@onready var head_hurtbox = $MGSprites/Head/CcMasterGiantHead/HeadHurtbox
@onready var right_hand_hurtbox = $MGSprites/RightHand/CcMasterGiantRighHand/RightHandHurtbox
@onready var left_hand_hurtbox = $MGSprites/LeftHand/CcMasterGiantLeftHand/LeftHandHurtbox
@onready var enable_mg_damage_area: Timer = $EnableMGDamageArea
@onready var disable_mg_damage_area: Timer = $DisableMGDamageArea

var player_in_attack_radius = false
var knockback_strength : float = 500
var is_knocked_back: bool = false
var knockback_dur: float = 0.2
var is_chasing: bool = false
var can_walk: bool

var mG_dmg: int = 0
var can_dmg: bool = true
var dmg_cooldown: float = 1.0

var current_state = State.IDLE
var player = null
var speed = 150
var attack_range = 80
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
	
	#$EGDealDamageArea/CollisionShape2D.set_deferred("disabled", true)
	
	#enable_eg_damage_area.timeout.connect(self._on_enable_eg_damage_area_timeout)
	#disable_eg_damage_area.timeout.connect(self._on_disable_eg_damage_area_timeout)
	
	animation_player.connect("animation_finished", _on_animation_player_animation_finished)
	
	attack_cooldown.start()

func _physics_process(delta):
	if dead:
		return
	
	$MGHealthBar.value = health
	
	match current_state:
		State.IDLE:
			# Do nothing until player is found
			pass

		State.CHASE:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
				
			if player:
				var direction = (player.global_position - global_position).normalized()
				velocity = direction * speed
				velocity.y = 0
				
				move_and_slide()
				
				var dist = global_position.distance_to(player.global_position)
				if dist < attack_range and attack_cooldown.time_left == 0:
					choose_attack()
					attack_cooldown.start()
				
		State.LEFTSWIPE, State.RIGHTSWIPE, State.LEFTBLAST, State.RIGHTBLAST, State.LASEREYES:
			velocity = Vector2.ZERO
	if current_state in [State.LEFTSWIPE, State.RIGHTSWIPE, State.LEFTBLAST, State.RIGHTBLAST, State.LASEREYES]:
		return

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
		print("Player entered attack radius")
		choose_attack()

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
			attack_cooldown.start()

func _on_animation_player_animation_finished(anim_name):
	if dead:
		return
	match current_state:
		State.LEFTSWIPE, State.RIGHTSWIPE, State.LEFTBLAST, State.RIGHTBLAST, State.LASEREYES:
			print("Finished attack animation:", current_state)
			change_state(State.CHASE)
			attack_cooldown.start()

func _on_attack_cooldown_timeout():
	if dead:
		return
	if player_in_attack_radius:
		choose_attack()

func take_dmg(dmg, knockback_dir):
	health -= dmg
	apply_knockback(knockback_dir)
	took_dmg = true
	if health <= min_health:
		health = min_health
		current_state = State.DEATH
		dead = true
		animated_sprite_mg_death.play("death")
		is_chasing = false
		can_walk = false
		velocity = Vector2.ZERO
		emit_signal("boss_died")
		
		$MGDeath.play()
		
		#$EGDealDamageArea/CollisionShape2D.set_deferred("disabled", true)
		#$CollisionShape2D.set_deferred("disabled", true)
		print("Enemy is dead. Disabling damage collision shape.")
		
		$EGHealthBar.hide()
		
		$MainCollisionShape2D.set_deferred("disabled", true) 
		head_hurtbox.set_deferred("disabled", true)
		left_hand_hurtbox.set_deferred("disabled", true)
		right_hand_hurtbox.set_deferred("disabled", true)
		
		animation_player.stop()
		animated_sprite_mg_death.play("death")
		print("Enemy is dying, playing death animation.")
		
		await get_tree().create_timer(1.0).timeout
		await $MGDeath.finished
		self.queue_free()
	print(str(self), "current health is ", health)

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
	
#func _on_eg_deal_damage_area_body_entered(body):
	#if can_dmg and body.is_in_group("player"):
		#print("Player entered EGDealDamageArea.")
		#var knockback_dir = (body.global_position - global_position).normalized()
		#body.plyr_take_dmg(dmg_to_deal, knockback_dir)
		#can_dmg = false
		#start_dmg_cooldown()

func start_dmg_cooldown():
	await get_tree().create_timer(dmg_cooldown).timeout
	can_dmg = true

func _on_enable_eg_damage_area_timeout():
	enable_eg_timer()

func _on_disable_eg_damage_area_timeout():
	disable_eg_timer()
	
func enable_eg_timer():
	$EGDealDamageArea/CollisionShape2D.disabled = false
	is_deal_dmg = true

func disable_eg_timer():
	$EGDealDamageArea/CollisionShape2D.disabled = true
	is_deal_dmg = false
