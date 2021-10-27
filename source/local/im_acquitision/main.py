# Raspberry Pi-based Underwater Camera System
# Main Program
# Author: VJA
# Description: Automated acquisition and management of images from underwater scene

# Modules
from processes import acquire_ims as aims
from processes import manage_loc as mloc
from processes import manage_dbx as mdbx
# manage_dbx
import os

# User-defined Variables
# Streaming link (from Raspberry Pi-based Underwater Camera)
LINK = "http://192.168.4.3:8080/stream.mjpg"
# Current Directory - the location of main program
CUR_DIR = os.getcwd()
# Local Storage Directory - the primary, permanent local storage of acquired images 
HDD_DEST_DIR = '/media/ucamclient/DATA'
# Token - the unique ID string for accessing Dropbox
#TOKEN = 'token'
# Thresholds - the amount of free space in both storages that triggers the deletion of old files 
HDD_THR = 100_000_000 # 100 Mb #TEST_THR = 1_999_500_000_000
DBX_THR = 50_000_000 # 50 Mb
RPI_THR = 6_000_000_000 # 6 Gb #TEST_THR = 26_000_000_000

# ACQUISITION
acq_info = aims.acquisition(LINK, CUR_DIR, HDD_DEST_DIR, HDD_THR)

if acq_info is not None:
    print('Acquisition Done!')
    
    timestamp = acq_info[0]
    frame_rate = acq_info[1]
    acq_time = acq_info[2]
    
    print('\tTimestamp: ', timestamp)
    print('\tFrame Rate: {:.2f} fps'.format(frame_rate))
    print('\tAcquisition Time: {:.2f} s'.format(acq_time))

# FILES UPLOAD - DROPBO
    mdbx_info = mdbx.fileupload(CUR_DIR, TOKEN, DBX_THR)

    if mdbx_info:
        
        print('Upload Done!')
        
        mdbx_info_dict = mdbx_info[0]
        mdbx_upload_rate = mdbx_info[1]
        mdbx_time = mdbx_info[2]
        
        DBX_space_info = mdbx_info_dict["DBX_space_info"]
        uploaded_zip = mdbx_info_dict["uploaded_zip"]
        deleted_zip = mdbx_info_dict["deleted_zip"]
        
        print('\tDropbox Free Space: {:.4f} Gb/{:.4f} Gb'.format(DBX_space_info[-1][0], DBX_space_info[-1][1]))
        print('\tUploaded ', uploaded_zip[-1], ' into Dropbox')
        
        if deleted_zip:
            print('\tDeleted ', deleted_zip[-1], ' from Dropbox')
            
        print('\tUpload Speed: {:.4f} Mbps'.format(mdbx_upload_rate))
        print('\tUpload Time: {:.2f} s'.format(mdbx_time))
       
# FILES MANAGEMENT - LOCAL
    mloc_info = mloc.filemanagement(CUR_DIR, HDD_DEST_DIR, HDD_THR, RPI_THR)
    
    if mloc_info:
        
        mloc_info_dict = mloc_info[0]
        mloc_time = mloc_info[1]
        
        HDD_space_info = mloc_info_dict["HDD_space_info"]
        RPi_space_info = mloc_info_dict["RPi_space_info"]
        moved_dirs = mloc_info_dict["moved_dirs"]
        deleted_dirs = mloc_info_dict["deleted_dirs"]
        
        print('\tRPi Free Space: {:.4f} Gb/{:.4f} Gb'.format(RPi_space_info[-1][0], RPi_space_info[-1][1]))
        
        if HDD_space_info:
            print('\tHDD Free Space: {:.4f} Gb/{:.4f} Gb'.format(HDD_space_info[-1][0], HDD_space_info[-1][1]))
            if deleted_dirs:
                for dirs in deleted_dirs:
                    print('\tDeleted ', dirs)
            if moved_dirs:
                for dirs in moved_dirs:
                    print('\tMoved ', dirs, ' into ', HDD_DEST_DIR)
        else:
            if deleted_dirs:
                for dirs in deleted_dirs:
                    print('\tDeleted ', dirs)
                
    else:
        print('\tNo file management happened.')
        
    print('\tLocal File Management Processing Time: {:.2f} s'.format(mloc_time))

else:
    print('No acquisition happened.')

# FILES MANAGEMENT - DROPBOX
