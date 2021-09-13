#########################################################################
#  alloc_cpu_rt.py  - allocate CPU render threads 
# set max cpu core usage based on leaving 1 thread to kernel use
# cpu_count() returns logical cores not physical cores i.e. total threads
##########################################################################   

import bpy
from multiprocessing import cpu_count

def set_fa() :

    for scene in bpy.data.scenes:
        scene.render.use_overwrite = False
        scene.render.use_placeholder = True
        
    return

def alloc_cpu_rt() :

    available_threads = cpu_count()
    cpu_render_threads = max(1, (available_threads - 1))

    for scene in bpy.data.scenes:
        scene.render.threads_mode = 'FIXED'
        scene.render.threads = cpu_render_threads

    return
    
set_fa()
alloc_cpu_rt()
 
