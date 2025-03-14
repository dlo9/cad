# https://github.com/mmalecki/cq-queryabolt
import cq_queryabolt
import cadquery as cq
class Workplane(cq_queryabolt.WorkplaneMixin, cq.Workplane):
    pass


width = 35
thickness = 3

# 2020 extrusion measurements
width_2020 = 20
inner_width_2020 = 6
inner_depth_2020 = 6
hinge_gap = 1

inner_hinge = (
    #cq.Workplane("XY")
    Workplane("XY")
    .box(width, width_2020, thickness)
    .edges(">YZ")
    .chamfer(2, 3)
)

inner_hinge = (
    inner_hinge
    .faces(">Z")
    #.cboreHole(2.4, 4.4, 2.1)
    # Move the hole up, since the part is too thin for a full counterbore
    .workplane(1.5)
    .cboreBoltHole("M3")
)

# Render the solid
show_object(inner_hinge)