################################################################
#  set_ren_fa.py  - set sets critical Overwrite and Placeholder
#  render properties on render host
#    opens .blend file
#    sets Overwrite to False and Placeholder to True render properties  
################################################################   

import bpy


# set global output properties for all scenes in infile

def set_fa() :

    for scene in bpy.data.scenes:
        scene.render.use_overwrite = False
        scene.render.use_placeholder = True
        
    return

set_fa()



