extends CharacterBody2D

@onready var grindables = $"../Grindables"
@onready var animated_sprite = $AnimatedSprite2D

# Constants

const ACCEL: float = 400.
const GRAVITY: float = 1000.
const MAX_H_VELOCITY: float = 400.
const MIN_H_VELOCITY: float = 10.
const GRIND_VEL_THRESHOLD: float = MAX_H_VELOCITY * .5
const FRICTION: float = .01
const JUMP_TIMER: float = 1.
const JUMP_TIMER_CAP: float= 2.
const JUMP_SMALL_IMPULSE: float = 300.
const JUMP_BIG_IMPULSE: float = 500.

# Player States
var jump_charge: float = 0.
var on_grindable: bool = false
var is_grinding: bool = false
var facing_right: bool = true

func get_input(dt: float) -> void:

  # Horizontal movement
  if Input.is_action_pressed("left"):
    facing_right = false
    velocity.x -= dt * ACCEL
    animated_sprite.flip_h = true
  elif Input.is_action_pressed("right"):
    facing_right = true
    velocity.x += dt * ACCEL
    animated_sprite.flip_h = false
  elif (abs(velocity.x) < MIN_H_VELOCITY):
    velocity.x = 0.


  # Jump
  if is_on_floor():
    if Input.is_action_pressed("jump"):
      jump_charge += dt
      jump_charge = min(JUMP_TIMER_CAP, jump_charge)
    elif Input.is_action_just_released("jump"):
      velocity.y = -JUMP_SMALL_IMPULSE if jump_charge < JUMP_TIMER else -JUMP_BIG_IMPULSE
      jump_charge = 0.;


  # Grind
  var can_grind: bool = on_grindable
  # can_grind &= abs(velocity.x) > GRIND_VEL_THRESHOLD
  if can_grind && Input.is_action_just_pressed("grind"):
    is_grinding = true


func animate() -> void:

  animated_sprite.flip_h = !facing_right

  # Start with grinding animations (can be mid air on on ground)
  if is_grinding:
    animated_sprite.play("grind")

  # Ground animations
  elif is_on_floor():
    if jump_charge > 0 && jump_charge < JUMP_TIMER:
      animated_sprite.play("crouch1")
    elif jump_charge > JUMP_TIMER:
      animated_sprite.play("crouch2")
    elif velocity.x:
      animated_sprite.play("skate")
    else:
      animated_sprite.play("idle")

  # Mid air animations

  else:
    if velocity.y <= 0:
      animated_sprite.play("jump")
    else:
      animated_sprite.play("fall")


func _physics_process(dt: float) -> void:
  get_input(dt)
  animate()
  if is_grinding:
    velocity.x = MAX_H_VELOCITY if facing_right else -MAX_H_VELOCITY
    velocity.y = 0
  else:
    # Friction
    velocity.x -= sign(velocity.x) * dt * velocity.x * velocity.x * FRICTION
    velocity.x = clamp(velocity.x, -MAX_H_VELOCITY, MAX_H_VELOCITY);
    # Gravity
    velocity.y += dt * GRAVITY
  move_and_slide()


func _on_colliders_body_entered(body: Node2D) -> void:
  if body.get_parent() == grindables:
    on_grindable = true


func _on_colliders_body_exited(body: Node2D) -> void:
  if body.get_parent() == grindables:
    on_grindable = false
    if is_grinding:
      body.free()
      is_grinding = false
