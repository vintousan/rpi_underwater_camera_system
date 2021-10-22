#!/usr/bin/python3

import dropbox
from dropbox.files import WriteMode
from dropbox.exceptions import ApiError, AuthError
import os
import time
from zipfile import ZipFile
import socket

class ManDBX:
    def __init__(self, curDir, dbx, dbx_thr=50_000_000):
        self.curDir = curDir
        self.tempDir_im =  os.path.join(self.curDir, 'images')
        self.zipDir_im = os.path.join(self.curDir, 'zip')
        self.dbxDir_im = '/images/'
        self.dbx = dbx
        self.dbx_thr = dbx_thr

    # Check available space in Dropbox
    def check_dbx_space(self):

        # Divided into Gb

        space_usage_info = self.dbx.users_get_space_usage()
    
        used_space = (space_usage_info.used)/1_000_000_000
        allocated_space = (space_usage_info.allocation.get_individual().allocated)/1_000_000_000
        free_space = allocated_space - used_space
        
        return free_space, allocated_space
    
    # Delete oldest files in Dropbox
    def delete_dbx_zip(self):
        
        # List folders
        dbx_zip_list = []
        dbx_zip_list_sorted = []
    
        response = self.dbx.files_list_folder(path=self.dbxDir_im)
    
        for entry in response.entries: 
            dbx_zip_list.append(entry.path_display)
     
        # Determine oldest folder by timestamp
        # Rely on timestamp, not on os.ctime (as it sorts files by last modified)
        dbx_zip_list_sorted = sorted(dbx_zip_list)
        dbx_oldest_zip = dbx_zip_list_sorted[0]
    
        # Delete folder and contents 
        self.dbx.files_delete(path=dbx_oldest_zip)
        #print('Deleted ', dbx_oldest_folder)
        return dbx_oldest_zip
    
    # Permanently delete zip created for DBX upload
    def delete_local_zip(self):
        pass


    def create_zip(self, recent_im_Dir):
        
        # Create zip directory if does not exist
        if not os.path.isdir(self.zipDir_im):
            os.mkdir(self.zipDir_im)
        
        # Define recent image folder file path
        recent_im_Dir_path = os.path.join(self.tempDir_im, recent_im_Dir)
        
        # Define zip object name
        zip_name = recent_im_Dir + '.zip'
        zip_path = os.path.join(self.zipDir_im, zip_name)
        
        # Create a zip file object
        with ZipFile(zip_path, 'w') as zipObj:
            
            # List all images
            im_list = [im for im in os.listdir(recent_im_Dir_path) if im.endswith('.jpg')]
            
            for im in im_list:
                im_path = os.path.join(recent_im_Dir_path, im)
                zipObj.write(im_path, im)
                
        return zip_name, zip_path
        
    # List directories in local temporary storage - RPi
    def list_Dircontents(self, Dir):
        Dir_list = sorted(os.listdir(Dir))
        return Dir_list
    
    # Upload images to Dropbox using Dropbox API
    def upload_file(self, zip_path_local, zip_path_dbx):
    
        file_size = os.path.getsize(zip_path_local)
        
        CHUNK_SIZE = 4*1024*1024
    
        with open(zip_path_local, 'rb') as f:
            
            try:
                upload_session_start_result = self.dbx.files_upload_session_start(f.read(CHUNK_SIZE))
                cursor = dropbox.files.UploadSessionCursor(session_id=upload_session_start_result.session_id, offset=f.tell())
                commit = dropbox.files.CommitInfo(path=zip_path_dbx)
                while f.tell() <= file_size:
                    if ((file_size - f.tell()) <= CHUNK_SIZE):
                        #print(self.dbx.files_upload_session_finish(f.read(CHUNK_SIZE), cursor, commit))
                        break
                    else:
                        self.dbx.files_upload_session_append_v2(f.read(CHUNK_SIZE), cursor)
                        cursor.offset = f.tell()
            except dropbox.exceptions.ApiError as err:
                if (err.error.is_path() and err.error.get_path().reason.is_insufficient_space()):
                    print("Cannot upload. Insufficient space.")
                    #sys.exit("ERROR: Cannot upload, insufficient space.")
                elif err.user_message_text:
                    print(err.user_message_text)
                    #sys.exit()
                else:
                    print(err)
                #sys.exit()
                return None
            except socket.timeout:
                print("Connection interrupted.")
                return None
            except requests.exceptions.ConnectionError:
                print("Connection interrupted.")
                return None
    
        '''
        # Access upload function
        f = open(zip_path_local, 'rb')   
        upload_session_start_result = self.dbx.files_upload_session_start(f.read(CHUNK_SIZE))
        cursor = dropbox.files.UploadSessionCursor(session_id=upload_session_start_result.session_id, offset=f.tell())
        commit = dropbox.files.CommitInfo(path=zip_path_dbx)
        
        while f.tell() <= file_size:
            if ((file_size - f.tell()) <= CHUNK_SIZE):
                print(self.dbx.files_upload_session_finish(f.read(CHUNK_SIZE), cursor, commit))
                break
            else:
                self.dbx.files_upload_session_append_v2(f.read(CHUNK_SIZE), cursor)
                cursor.offset = f.tell()
    
        f.close()
        
        
        with open(zip_path_local, 'rb') as f:
        
            try:
                self.dbx.files_upload(f.read(), zip_path_dbx, mode=WriteMode('overwrite'))
            except ApiError as err:
                if (err.error.is_path() and err.error.get_path().reason.is_insufficient_space()):
                    sys.exit("ERROR: Cannot upload, insufficient space.")
                elif err.user_message_text:
                    print(err.user_message_text)
                    sys.exit()
                else:
                    print(err)
                sys.exit()
        '''
        
    # Define data structure that stores info regarding uploading process
    def init_mdbx_info(self):
        
        mdbx_info = dict()
        
        DBX_space_info = list()
        uploaded_zip = list()
        deleted_zip = list()
        
        mdbx_info["DBX_space_info"] = DBX_space_info
        mdbx_info["uploaded_zip"] = uploaded_zip
        mdbx_info["deleted_zip"] = deleted_zip
        
        return mdbx_info
    
    # Stores info regarding uploading process into the defined data structure
    def get_mbc_info(self, mdbx_info, DBX_space_info, uploaded_zip, deleted_zip):
        
        mdbx_info["DBX_space_info"] = DBX_space_info
        mdbx_info["uploaded_zip"] = uploaded_zip
        mdbx_info["deleted_zip"] = deleted_zip
        
        return mdbx_info

    # Upload image zip from RPi to Dropbox
    def upload_imzip(self, account_info):
        
        if account_info:
            
            # Define data structure for storing upload info
            mdbx_info = self.init_mdbx_info()            
            
            DBX_space_info = list()
            uploaded_zip = list()
            deleted_zip = list()
            
            free_space, allocated_space = self.check_dbx_space()
            DBX_space_info.append([free_space, allocated_space])
            
            # Delete files if space capacity is lower than threshold
            if free_space > self.dbx_thr:
                pass
            else:
                deleted_zip = self.delete_dbx_zip()
                deleted_dir.append(deleted_folder)
                
                free_space, allocated_space = self.check_dbx_space()
                DBX_space_info.append([free_space, allocated_space])
            
            # Determine the most recent folder in the temporary storage
            im_Dir_list = self.list_Dircontents(self.tempDir_im)
            
            if len(im_Dir_list):
                recent_im_Dir = im_Dir_list[-1]
            else:
                print('Acquisition did not happened.')
                return None
            
            # Generate zip file for recent image folder
            recent_zip_name, recent_zip_path_local = self.create_zip(recent_im_Dir)
            
            # Intialize zip file path in Dropbox
            recent_zip_path_dbx = os.path.join(self.dbxDir_im, recent_zip_name)
            
            # Upload contents of the most recent folder to Dropbox
            start_upload_time = time.time()
            
            self.upload_file(recent_zip_path_local, recent_zip_path_dbx)
    
            finish_upload_time = time.time()
            upload_time = finish_upload_time - start_upload_time
            # Compute for upload rate
            zip_file_size = os.stat(recent_zip_path_local).st_size
            upload_rate = (zip_file_size/1_000_000)/upload_time
            
            # Store info into the define data structure
            uploaded_zip.append(recent_zip_name)
            
            # Permanently delete local zip file 
            os.system('rm ' + recent_zip_path_local)
            
            free_space, allocated_space = self.check_dbx_space()
            DBX_space_info.append([free_space, allocated_space])
            
            mdbx_info = self.get_mbc_info(mdbx_info, DBX_space_info, uploaded_zip, deleted_zip)
            
            # Return with the info
            return (mdbx_info, upload_rate)

def fileupload(curDir, token, dbx_thr):

    print('Starting upload...')
    start_mdbx_time = time.time()
    
    print('Gaining remote access on Dropbox...')
    # Access Dropbox through generated token
    with dropbox.Dropbox(token) as dbx:
    
        try:
            account_info = dbx.users_get_current_account()
        except AuthError:
            print("ERROR: Invalid access token; try re-generating an access token from the app console on the web.")

    print('Uploading image files (.zip) on Dropbox...') 
    uploader = ManDBX(curDir, dbx, dbx_thr)
    mdbx_info = uploader.upload_imzip(account_info)

    finish_mdbx_time = time.time()
    
    mdbx_time = finish_mdbx_time - start_mdbx_time
    
    if mdbx_info:
        return(mdbx_info[0], mdbx_info[1], mdbx_time)
    else:
        return None