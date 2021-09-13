################################################################
#  set_ cpu_rp.py  - set cpu render properties
#    sets device settings for a host with CPU cores  
#    writes out .blend files for cpu render
################################################################   

import bpy

# get the name of the input file .blend file

infile=bpy.path.basename(bpy.context.blend_data.filepath)

# set global output properties for all scenes in infile

def set_fa() :

    for scene in bpy.data.scenes:
        scene.render.use_overwrite = False
        scene.render.use_placeholder = True
        
    return
 
# declare render device tile size settings
# set render device type to CPU
# set tile size
# set Threads mode as Auto-detect 


def set_cpu_rp() : 

    opt_cpu_tile_x = 32
    opt_cpu_tile_y = 32
 
    for scene in bpy.data.scenes:
        scene.cycles.device = 'CPU'
        scene.render.tile_x = opt_cpu_tile_x
        scene.render.tile_y = opt_cpu_tile_y
        scene.render.threads_mode = 'AUTO'

    return
    
set_fa()
set_cpu_rp()

# write file for cpu render

outfile = "c_" + infile
bpy.ops.wm.save_as_mainfile(filepath="/home/master/staging/" + outfile)






 
