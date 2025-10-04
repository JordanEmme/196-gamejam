extends CharacterBody2D

@export var acceleration: float = 400.
@export var grav: float = 1000.
@export var MAX_H_VELOCITY: float = 400.
@export var MIN_H_VELOCITY: float = 10.
@export var FRICTION: float = .01
@export var JUMP_TIMER: float = 1.
@export var JUMP_TIMER_CAP: float= 2.
@export var JUMP_SMALL_IMPULSE: float = 300.
@export var JUMP_BIG_IMPULSE: float = 500.

# Constants

# Player States
var idle: bool = true
var can_kick: bool = true
var jump_charge: float = 0.


func get_input(dt: float):

  # Horizontal movement
  if Input.is_action_pressed("left"):
    velocity.x -= dt * acceleration
  elif Input.is_action_pressed("right"):
    velocity.x += dt * acceleration
  elif (abs(velocity.x) < MIN_H_VELOCITY):
    velocity.x = 0.


  # Jump
  if is_on_floor():
    if Input.is_action_pressed("jump"):
      jump_charge += dt
      jump_charge = min(JUMP_TIMER_CAP, jump_charge)
    elif Input.is_action_just_released("jump"):
      velocity.y = -JUMP_SMALL_IMPULSE if jump_charge < JUMP_TIMER else -JUMP_BIG_IMPULSE


func _physics_process(dt: float):
  get_input(dt)
  # Friction
  velocity.x -= sign(velocity.x) * dt * velocity.x * velocity.x * FRICTION
  velocity.x = clamp(velocity.x, -MAX_H_VELOCITY, MAX_H_VELOCITY);
  # Gravity
  velocity.y += dt * grav
  move_and_slide()
