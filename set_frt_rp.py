################################################################
#  set_frt_rp.py  - set fast render time render properties
#    opens .blend file
#    sets standard render properties  
#    saves .blend file with settings
#
################################################################   

import bpy

# get the name of this .blend file

infile=bpy.path.basename(bpy.context.blend_data.filepath)

# check if images are packed in

# set global output properties for all scenes in infile

def set_fa() :

    for scene in bpy.data.scenes:
        scene.render.use_overwrite = False
        scene.render.use_placeholder = True
        
    return

# declare standard production render property values and
# set global output properties for all scenes in infile

def set_frt_rp() :

    res_x = 1280
    res_y = 720
    percent = 90
    aspect_x = 1
    aspect_y = 1

    for scene in bpy.data.scenes:
        scene.render.resolution_x = res_x
        scene.render.resolution_y = res_y
        scene.render.resolution_percentage = percent
        scene.render.pixel_aspect_x = aspect_x
        scene.render.pixel_aspect_y = aspect_y
      
    return

set_fa()
set_frt_rp()

# save infile with standard settings

outfile = "f_" + infile
bpy.ops.wm.save_as_mainfile(filepath="/home/master/staging/" + outfile)






