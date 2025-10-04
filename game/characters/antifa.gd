extends CharacterBody2D

@onready var grindable = $"../Grindable"
@onready var area2d = $"Colliders/Grindables"

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
var facing_right = true

func get_input(dt: float) -> void:

  # Horizontal movement
  if Input.is_action_pressed("left"):
    facing_right = false
    velocity.x -= dt * ACCEL
    animated_sprite.flip_h = true
    animated_sprite.play("skating")
  elif Input.is_action_pressed("right"):
    facing_right = true
    velocity.x += dt * ACCEL
    animated_sprite.flip_h = false
    animated_sprite.play("skating")
  elif (abs(velocity.x) < MIN_H_VELOCITY):
    velocity.x = 0.
    animated_sprite.stop()


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
   

func _physics_process(dt: float) -> void:
  get_input(dt)
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
  if body == grindable:
    print("Enter")
    on_grindable = true


func _on_colliders_body_exited(body: Node2D) -> void:
  if body == grindable:
    print("exit")
    on_grindable = false
    is_grinding = false
