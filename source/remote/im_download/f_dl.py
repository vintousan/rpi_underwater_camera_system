# Raspberry Pi-based Underwater Camera System
# Author: VJA
# Description: Download of most recent file

# Import libraries
import dropbox
import os
import zipfile
import shutil

# Define function for determine the folder size (in bytes)
def get_directory_size(directory):
    """Returns the `directory` size in bytes."""
    total = 0
    file_list = os.scandir(directory)
    
    try:
        # print("[+] Getting the size of", directory)
        for entry in file_list:
            if entry.is_file():
                # if it's a file, use stat() function
                total += os.stat(entry).st_size
            elif entry.is_dir():
                # if it's a directory, recursively call this function
                total += get_directory_size(entry.path)
    except NotADirectoryError:
        # if `directory` isn't a directory, get the file size then
        return os.path.getsize(directory)
    except PermissionError:
        # if for whatever reason we can't open the folder, return 0
        return 0
    return total

# User-defined variables
# Dropbox OAuth Token, to access the Dropbox
TOKEN = 'I4nKnDAbbR0AAAAAAAAAAZMO1rNNOJT48sVt5A1qU7iJHVVvx264VeNrj_kHatHn'
# Directories
# Note: File formattiing on dbx path is not the same as the local path (Python, Anaconda)
dbx_dir = '/images'
work_dir = 'C:\\Users\\ERDT\\Documents\\0_workingdir'
if os.path.isdir(work_dir) == False:
    os.mkdir(work_dir)
# Threshold: For determining the file size of the working directory
FOLDER_THR = 30_000_000 #100_000_000_000 

# TODO: Delete older files if the total size of the directory is beyond threshold. 
folder_size = get_directory_size(work_dir)
print(folder_size)

# Delete oldest folder to cater new downloaded folder
if folder_size < FOLDER_THR:
    pass
else:
    # TODO: Delete oldest files 
    work_dir_list = sorted(os.listdir(work_dir))
    work_dir_oldest = os.path.join(work_dir, work_dir_list[0])
    shutil.rmtree(work_dir_oldest) 
    
# Open dropbox
with dropbox.Dropbox(TOKEN, timeout = 180) as dbx:        
    try:
        account_info = dbx.users_get_current_account()
    except AuthError:
        print("ERROR: Invalid access token; try re-generating an access token from the app console on the web.")
    
# List files in the folder
dbx_dir_list = dbx.files_list_folder(path=dbx_dir)
dbx_dir_file_name_list = list()

for i in dbx_dir_list.entries:
    dbx_dir_file_name_list.append(i.name)
    
# Determine most recent file and file paths
sorted(dbx_dir_file_name_list)
dbx_recent_file = dbx_dir_file_name_list[-1]
recent_file_name = dbx_recent_file[:-4]
dl_path = os.path.join(work_dir, dbx_recent_file)
dbx_path = dbx_dir + '/' + dbx_recent_file

# Check in the working directories if the most recent file is already downloaded
if not os.path.exists(os.path.join(work_dir, recent_file_name)):
    
    # Check if zip file is already downloaded
    if not os.path.exists(os.path.join(work_dir, dbx_recent_file)):
        # Download the file from Dropbox
        with open(dl_path, 'wb') as f:
            dbx.files_download_to_file(dl_path, dbx_path)
    
    # Extract downloaded zip
    with zipfile.ZipFile(dl_path, 'r') as zip_ref:
        zip_ref.extractall(os.path.join(work_dir, recent_file_name))
        
    # Delete downloaded zip file
    os.remove(dl_path)

else:
    print('Already downloaded most recent file in Dropbox.')
    
    




        

        


    

    