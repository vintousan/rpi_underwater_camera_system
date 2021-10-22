# Raspberry Pi-based Underwater Camera System
# Local File Management Module
# Author: VJA

import os
import shutil
import time

class ManLS:
    def __init__(self, curDir, extDir, hdd_cap_thr = 100_000_000, rpi_cap_thr = 6_000_000_000):
        self.curDir = curDir
        self.extDir = extDir
        self.extDir_im = os.path.join(self.extDir, 'images')
        self.tempDir_im =  os.path.join(self.curDir, 'images')
        self.hdd_cap_thr = hdd_cap_thr
        self.rpi_cap_thr = rpi_cap_thr
    
    def check_Dir(self, Dir):
        if os.path.exists(Dir):
            return True
        else:
            return False
    
    def list_Dircontents(self, Dir):
        Dir_list = sorted(os.listdir(Dir))
        return Dir_list
    
    def make_Dir(self, Dir):
        if os.path.isdir(Dir) == False:
            os.mkdir(Dir)
    
    def check_capacity(self, Dir):
        disk_stats = shutil.disk_usage(Dir)
        total_space = disk_stats[0]/1_000_000_000
        free_space = disk_stats[2]/1_000_000_000
        return total_space, free_space
    
    def delete_Dir(self, dir_path, Dir):
        
        #Dir_list_sorted = sorted(Dir_list)
        #oldest_Dir = Dir_list_sorted[0]
        oldest_Dir_full_path = os.path.join(dir_path, Dir)
        
        #Dir_full_path = [os.path.join(self.extDir_im, Dir) for Dir in Dir_list]
        #Dir_full_paths_sorted = sorted(Dir_full_paths)
        #oldest_Dir = min(Dir_full_paths, key=os.path.getctime)
        
        shutil.rmtree(oldest_Dir_full_path)
        return oldest_Dir_full_path
    
    def init_mloc_info(self):
        mloc_info = dict()
        
        HDD_space_info = list()
        RPi_space_info = list()
        moved_dirs = list()
        deleted_dirs = list()
        
        mloc_info["HDD_space_info"] = HDD_space_info
        mloc_info["RPi_space_info"] = RPi_space_info
        mloc_info["moved_dirs"] = moved_dirs
        mloc_info["deleted_dirs"] = deleted_dirs
        
        return mloc_info
    
    def get_mloc_info(self, mloc_info, HDD_space_info, RPi_space_info, moved_dirs, deleted_dirs):
        
        mloc_info["HDD_space_info"] = HDD_space_info
        mloc_info["RPi_space_info"] = RPi_space_info
        mloc_info["moved_dirs"] = moved_dirs 
        mloc_info["deleted_dirs"] = deleted_dirs 
        
        return mloc_info
    
    def manage_Dir(self):
        
        print('Managing local directories...')
        
        mloc_info = self.init_mloc_info()
        
        HDD_space_info = list()
        RPi_space_info = list()
        moved_dirs = list()
        deleted_dirs = list()
        
        if self.check_Dir(self.extDir):
            
            Dir_list_temp = self.list_Dircontents(self.tempDir_im)
            Dir_list_ext = self.list_Dircontents(self.extDir_im)
            
            if not Dir_list_temp:
                print(self.tempDir_im, " is empty")
                return None
            else:
                
                HDD_total_space, HDD_free_space = self.check_capacity(self.extDir)
                HDD_space_info.append([HDD_free_space, HDD_total_space])
                
                # Should be while loop
                while len(Dir_list_temp):
                #for Dir in Dir_list_temp:
                    if HDD_free_space > self.hdd_cap_thr:
                        temp_Dir = Dir_list_temp.pop(0)
                        Dir_path_RPi = os.path.join(self.tempDir_im, temp_Dir)
                        Dir_path_HDD = os.path.join(self.extDir_im, temp_Dir)
                        #print('HDD Free Space: {}/{}'.format(free_space, total_space))
                        
                        shutil.move(Dir_path_RPi, Dir_path_HDD)
                        moved_dirs.append(Dir_path_RPi)
                        
                        HDD_total_space, HDD_free_space = self.check_capacity(self.extDir)
                        HDD_space_info.append([HDD_free_space, HDD_total_space])
                        
                        #print('Files in ', Dir_path_RPi, " moved to ", Dir_path_HDD)
                    else:
                        ext_Dir = Dir_list_ext.pop(0)
                        oldest_Dir_ext = self.delete_Dir(self.extDir_im, ext_Dir)
                        deleted_dirs.append(oldest_Dir_ext)
                        
                        HDD_total_space, HDD_free_space = self.check_capacity(self.extDir)
                        HDD_space_info.append([HDD_free_space, HDD_total_space])
                        #print('Deleted ', oldest_Dir)
                        #print('HDD Free Space: {}/{}'.format(free_space, total_space))
                
                RPi_total_space, RPi_free_space = self.check_capacity('/')
                RPi_space_info.append([RPi_free_space, RPi_total_space])
                
                mloc_info = self.get_mloc_info(mloc_info, HDD_space_info, RPi_space_info, moved_dirs, deleted_dirs)

                return mloc_info
        else:
            
            print(self.extDir, " does not exist")
            
            RPi_total_space, RPi_free_space = self.check_capacity('/')
            RPi_space_info.append([RPi_free_space, RPi_total_space])
            
            # TASK: Delete oldest in Raspberry Pi
            if not RPi_free_space > self.rpi_cap_thr:
                Dir_list_temp = self.list_Dircontents(self.tempDir_im)
                temp_Dir = Dir_list_temp.pop(0)
                oldest_Dir_temp = self.delete_Dir(self.tempDir_im, temp_Dir)
                deleted_dirs.append(oldest_Dir_temp)
                
                RPi_total_space, RPi_free_space = self.check_capacity('/')
                RPi_space_info.append([RPi_free_space, RPi_total_space])
                            
                mloc_info = self.get_mloc_info(mloc_info, None, RPi_space_info, None, deleted_dirs)
                return mloc_info
            
            mloc_info = self.get_mloc_info(mloc_info, None, RPi_space_info, None, None)
            return mloc_info
    
def filemanagement(curDir, extDir, hdd_cap_thr, rpi_cap_thr):
    
    start_mloc_time = time.time()
    
    manager = ManLS(curDir, extDir, hdd_cap_thr, rpi_cap_thr)
    mloc_info = manager.manage_Dir()
    
    finish_mloc_time = time.time()
    
    mloc_time = finish_mloc_time - start_mloc_time
    
    if mloc_info:
        return (mloc_info, mloc_time)
    else:
        return None
    
# TASK:
# What if RPi is full, specify how many Gb?
# Store to HDD
# What if HDD does not e


