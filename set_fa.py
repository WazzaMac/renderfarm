################################################################
#  set_fa.py  - set sets critical Overwrite and Placeholder render properties
#    opens .blend file
#    sets Overwrite to False and Placeholder to True render properties  
#    saves .blend file with settings
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

set_fa()

# save infile with essential settings


bpy.ops.wm.save_as_mainfile(filepath="/home/master/staging/" + infile)


