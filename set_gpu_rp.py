################################################################
#  set_gpu_rp.py  - set GPU render properties 
#    sets device settings for a host with 1 GPU
#    writes out .blend file for a gpu render 
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

# declare render device settings for host with 1 GPU
# set render device to use gpu for all scenes in infile
# set optimum cpu core usage for 1 GPU host

def set_gpu_rp() :

    threads = 0
    opt_gpu_tile_x = 256
    opt_gpu_tile_y = 256


    for scene in bpy.data.scenes:
        scene.cycles.device = 'GPU'
        scene.render.tile_x = opt_gpu_tile_x
        scene.render.tile_y = opt_gpu_tile_y   
        scene.render.threads_mode = 'FIXED'
        scene.render.threads = threads

    return

set_fa()
set_gpu_rp()

# write file for cpu render

outfile = "g_" + infile
bpy.ops.wm.save_as_mainfile(filepath="/home/master/staging/" + outfile)









 
