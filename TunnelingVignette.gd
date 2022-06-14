@tool
class_name TunnelingVignette
extends MeshInstance3D

var iris_mesh_const: Mesh = load("res://addons/xr_vignette/iris_extruded.obj") as Mesh
var iris_color_mat_const: ShaderMaterial = load("res://addons/xr_vignette/iris_gradient_mat.tres") as ShaderMaterial
var iris_depth_mat_const: ShaderMaterial = load("res://addons/xr_vignette/iris_depth_mat.tres") as ShaderMaterial

var iris_color_mat_inst: ShaderMaterial = iris_color_mat_const.duplicate() as ShaderMaterial
var iris_depth_mat_inst: ShaderMaterial = iris_depth_mat_const.duplicate() as ShaderMaterial

@export_node_path(Camera3D) var camera: NodePath = NodePath("..")
@onready var camera_node: Camera3D = get_node(camera) as Camera3D if has_node(camera) else null

@export_range(3.0, 10.0, 0.01, "or_lesser", "or_greater") var iris_distance: float = 5.0:
	set(x):
		iris_distance = x
		iris_color_mat_inst.set_shader_param(&"iris_distance", iris_distance)
		iris_depth_mat_inst.set_shader_param(&"iris_distance", iris_distance)

@export_range(0.0, 1.0) var vignette_alpha: float = 1.0:
	set(x):
		#if not is_equal_approx(vignette_alpha, 1) and is_equal_approx(x, 1):
		#	material_overlay = iris_depth_mat_inst
		#if is_equal_approx(vignette_alpha, 1) and not is_equal_approx(x, 1):
		#	material_overlay = null
		vignette_alpha = x
		iris_color_mat_inst.set_shader_param(&"vignette_alpha", vignette_alpha)

@export_range(0.0, 30.0, 0.1) var current_fade_fov: float = 6.5:
	set(x):
		current_fade_fov = x
		iris_color_mat_inst.set_shader_param(&"current_fade_fov", current_fade_fov)
		iris_depth_mat_inst.set_shader_param(&"current_fade_fov", current_fade_fov)

@export_exp_easing("attenuation") var fov_multiplier: float = 1.0:
	set(x):
		fov_multiplier = clamp(x, 0.0, 160.0)
		current_fov = camera_fov * fov_multiplier

var camera_fov: float = 100.0:
	set(x):
		camera_fov = x
		current_fov = camera_fov * fov_multiplier

var current_fov: float = 100.0:
	set(x):
		current_fov = clamp(x, 0.0, 160.0)
		iris_color_mat_inst.set_shader_param(&"current_fov", current_fov)
		iris_depth_mat_inst.set_shader_param(&"current_fov", current_fov)

# Called when the node enters the scene tree for the first time.
func _ready():
	mesh = iris_mesh_const
	transform = Transform3D.IDENTITY
	material_override = iris_color_mat_inst
	#if is_equal_approx(vignette_alpha, 1.0):
	#	material_overlay = iris_depth_mat_inst

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if camera_node != null:
		if camera_node.fov != camera_fov:
			camera_fov = camera_node.fov
