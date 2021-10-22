# Raspberry Pi-based Underwater Camera System
# Acquisition Module
# Author: VJA
# Description: Capture and storage of images from the streaming link of the underwater camera

# Libraries, Modules
import cv2
import time
from datetime import datetime
import os
import sys
import shutil

# Queue class (from Python)
if sys.version_info >= (3, 0):
    from queue import Queue
# otherwise, import the Queue class for Python 2.7
else:
    from Queue import Queue

# Class that gets images from streaming link and storing into a queue
class Images:
    def __init__(self, link, duration = 15, queueSize = 128):
        self.stream = cv2.VideoCapture(link)
        self.duration = duration # Duration of underwater video frames capture
        self.stopped = False
        self.Q = Queue(maxsize=queueSize)
    
    def get_time(self):
        return time.time()
    
    def get_date_time(self):
        return datetime.now()
    
    # Acquire frames within 15 s
    # Store in a queue to increase acquisition rates
    def get_images_from_link(self):
        time.sleep(1.0)
        
        start_time = self.get_time()
        current_datetime = self.get_date_time()
        
        while(int(self.get_time() - start_time) < self.duration):
            if not self.Q.full():
                # Read frames
                (grabbed, frame) = self.stream.read()
                # Check if captured frame is valid
                if not grabbed:
                    print('Connection to link is interrupted.')
                    self.stop()
                    break
                # Add frame into queue
                self.Q.put(frame)
                
        return self.Q, self.Q.qsize(), start_time, current_datetime
    
    def stop(self):
        # Stop operations
        self.stopped = True
    
class AcqIm:
    def __init__(self, link, curDir, extDir, hdd_cap_thr = 100000000):
        self.link = link
        self.curDir = curDir
        self.extDir = extDir
        self.hdd_cap_thr = hdd_cap_thr
        
    def check_link(self):
        cap = cv2.VideoCapture(self.link)
        if cap.isOpened():
            return True
        else:
            return False
    
    def make_Dir(self, Dir):
        if os.path.isdir(Dir) == False:
            os.mkdir(Dir)
    
    def init_tempDir(self):
        self.tempDir =  os.path.join(self.curDir, 'images')
        self.make_Dir(self.tempDir)
        #if os.path.isdir(self.tempDir) == False:
        #    os.mkdir(self.tempDir)
    
    def get_info(self, num_ims, start_acq_time, finish_acq_time):   
        capture_time = finish_acq_time - start_acq_time
        frame_rate = num_ims/capture_time
        return frame_rate
    
    def check_capacity(self, Dir):
        disk_stats = shutil.disk_usage(Dir)
        free_space = disk_stats[2]
        
        if free_space > self.hdd_cap_thr:
            return True
        else:        
            return False
    
    def acquire_images(self):
        
        im_acq_data, num_ims, start_acq_time, datetime = Images(self.link).get_images_from_link()
        # Handling of interrupted streaming link
        
        finish_acq_time = time.time()

        if not im_acq_data:
            return None
        else:
            frame_num = 0
            while not im_acq_data.empty():
                # Get queue entry
                img = im_acq_data.get()
    
                if(frame_num == 0):
                    #Create a subfolder in working directory
                    self.datetime_str = datetime.strftime("%Y_%m_%d_%H_%M")
                    workFolderName = self.datetime_str
                    self.subDir = os.path.join(self.tempDir, workFolderName) 
                    self.make_Dir(self.subDir)
                    #os.mkdir(self.subDir)
            
                # Save image files in the subfolder of working directory
                os.chdir(self.subDir)
                imageFileName = 'UCAM_P_1_' + self.datetime_str + '_' + '%03i' % frame_num + '.jpg'
                cv2.imwrite(imageFileName, img)
                frame_num += 1
    
                os.chdir(self.curDir)
            
            cap_frame_rate = self.get_info(num_ims, start_acq_time, finish_acq_time)
            
            return [self.datetime_str, cap_frame_rate]
    
    '''    
    def manage_images(self):
        
        if os.path.exists(self.extDir) and self.check_capacity(self.extDir):
            localdestDir_HDD_im = os.path.join(self.extDir, 'images', self.datetime_str)
            localdestDir_HDD_im_parent = os.path.join(self.extDir, 'images')
            self.make_Dir(localdestDir_HDD_im_parent)
            shutil.move(self.subDir, localdestDir_HDD_im)
            
        else:
            shutil.move(self.subDir, self.tempDir)
    '''    
    
    def perform_acquisition(self):
        
        print('Starting images acquisition...')
        start_acq_process_time = time.time()
        
        print('Checking link...')
        if self.check_link():
            print('Streaming link found...')
        else:
            print('No streaming link found.')
            return None
        
        print('Initializing local directories...')
        self.init_tempDir()
        
        print('Acquiring Images...')
        acq_info = self.acquire_images()
        #self.datetime_str, frame_rate = self.acquire_images()

        if acq_info is not None:
            
            #self.manage_images()
    
            finish_acq_process_time = time.time()
            
            timestamp = acq_info[0]
            frame_rate = acq_info[1]
            acq_time = finish_acq_process_time - start_acq_process_time
    
            return (timestamp, frame_rate, acq_time)
        else: 
            return None
        
def acquisition(link, curDir, extDir, hdd_cap_thr):
    
    acq = AcqIm(link, curDir, extDir, hdd_cap_thr)
    acq_info = acq.perform_acquisition()
    return acq_info

        



    
