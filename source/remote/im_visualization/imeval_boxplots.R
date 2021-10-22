#####################################################################################################################
# DATA VISUALIZATION
# AUthor: VJA
#####################################################################################################################

# Import libraries

# Call libraries
library(R.matlab)
library(plyr)

# Define file path of image statistics (matrix files)
#filepath = "C:/Users/ERDT/Documents/2_processing_m/datasetA_eval_stats/"
#filepath = "C:/Users/ERDT/Documents/2_processing_m/datasetA_eval_stats_old/" #18 27 35 37

filepath = "C:/Users/ERDT/Documents/2_processing_m/datasetB_eval_stats/"  #10,19,27,29

#filepath = "C:/Users/ERDT/Documents/2_processing_m/datasetC_prepro_eval_stats/" 


# Store first matrix file into a list
mat_list_filenames_all = list.files(path = filepath, pattern = "*.mat")

# Find unique dates and methods in the filenames
filename_dates <- list()
filename_methods <- list()

for(i in 1:length(mat_list_filenames_all)){
  filename_dates_temp = substring(mat_list_filenames_all[i],10,19)
  filename_methods_temp = substring(mat_list_filenames_all[i],27,29)
  
  filename_dates <- c(filename_dates, filename_dates_temp)
  filename_methods <- c(filename_methods, filename_methods_temp)
}

filename_dates <- unique(filename_dates)
filename_methods <- unique(filename_methods)

# Classify file names into methods and dates
mat_list_filenames_by_methods_and_date <- list()

# Prepare data structure
for(i in 1:length(filename_dates)){
  list_temp <- list()
  mat_list_filenames_by_methods_and_date[[i]] <- c(list_temp)
  for(j in 1:length(filename_methods)){
    list_temp2 <- list()
    mat_list_filenames_by_methods_and_date[[i]][[j]] <-c(list_temp2)
  }
}

for(i in 1:length(mat_list_filenames_all)){
  for(j in 1:length(filename_dates)){
    for(k in 1:length(filename_methods)){
      if(substring(mat_list_filenames_all[i],10,19) == filename_dates[[j]]){
        if(substring(mat_list_filenames_all[i],27,29) == filename_methods[[k]]){
          mat_list_filenames_by_methods_and_date[[j]][[k]] <- c(mat_list_filenames_by_methods_and_date[[j]][[k]], mat_list_filenames_all[i])
        }
      }
    }
  }
}

# Store data from matrix files
data <- list()

for(i in 1:length(mat_list_filenames_by_methods_and_date)){
  for(j in 1:length(mat_list_filenames_by_methods_and_date[[i]])){
    data_temp2 <- list()
    
    for(k in 1:length(mat_list_filenames_by_methods_and_date[[i]][[j]])){
      data_temp <- readMat(paste(filepath, mat_list_filenames_by_methods_and_date[[i]][[j]][[k]], sep = ""))
      data_temp2 <- c(data_temp2, data_temp)
    }
    idx = 4*(i-1) + j
    data[[idx]] <- c(data_temp2)
  }
}

# Prepare plot file names

plots_filepath = "C:/Users/ERDT/Documents/6_analysis_R/datasetB_plots/"
if(!dir.exists(plots_filepath)){
  dir.create(plots_filepath)
} 


#####################################################################################################################
# COLOR INFORMATION ENTROPY
#####################################################################################################################

# Date iterator
for(a in 1:length(filename_dates)){
  
  print('Iterating on Dates')
  h <- list()
  
  for(b in 1:length(filename_methods)){
    
    print('Iterating on Methods')
    
    h_temp2 <- list()
    idx = 4*(a-1) + b
    
    for(c in 1:length(data[[idx]])){
      
      num_entries = length(data[[idx]][[c]])
      
      # CBlF
      if(i %% 4 == 1){
        for (k in seq(from = 6, to = num_entries, by=14)){
          h_temp = data[[idx]][[c]][[k]]
          h_temp2 <- c(h_temp2, h_temp)
        }
      }
      # GWA
      else if(i %% 4 == 2){
        for (k in seq(from = 6, to = num_entries, by=14)){
          h_temp = data[[idx]][[c]][[k]]
          h_temp2 <- c(h_temp2, h_temp)
        }
      }
      # IMS
      else if(i %% 4 == 3){
        for (k in seq(from = 6, to = num_entries, by=14)){
          h_temp = data[[idx]][[c]][[k]]
          h_temp2 <- c(h_temp2, h_temp)
        }
      }
      # UWB
      else{
        for (k in seq(from = 6, to = num_entries, by=14)){
          h_temp = data[[idx]][[c]][[k]]
          h_temp2 <- c(h_temp2, h_temp)
        }
      }
      
      print('Extracting data')
      h[[b]] <- h_temp2
      
    }
  }
  
  print('Plotting data')

  h_df = data.frame(matrix(unlist(h), nrow=500, byrow=FALSE))
  colnames(h_df) <- c('h_cbf', 'h_gwa', 'h_ims', 'h_uwb')

  plot_fullfile_path = paste(plots_filepath, filename_dates[[a]], "_enh_h.jpeg", sep = "")
  png(file=plot_fullfile_path)

  boxplot(h_df$h_uwb, h_df$h_gwa, h_df$h_ims, h_df$h_cbf,
          main = paste("Sample Images from Dataset C-", a, sep=""),
          at = c(1,2,3,4),
          xlab = "Underwater Image Enhancement Methods",
          ylab = "H",
          names = c("UWB", "GWA", "IMS", "CBF"),
          col = c("#1B9E77", "#D95F02", "#7570B3", "#E7298A"))

  dev.off()
  
  #h_list <- list()
  
  #for 
  
  
  # means_list = list(R_means[[a]], G_means[[a]], B_means[[a]])
  # 
  # means_df <- data.frame(matrix(unlist(means_list), nrow=500, byrow=FALSE))
  # 
  # colnames(means_df) <- c('R', 'G', 'B')
  # 
  # csv_fullfile_path = paste(plots_filepath, filename_dates[[a]], "_means.csv", sep = "")
  # 
  # write.csv(means_df, csv_fullfile_path)
  
}

#####################################################################################################################
# MEANS
#####################################################################################################################

# Date iterator
for(a in 1:length(filename_dates)){
  
  print('Iterating on Dates')
  means <- list()
  
  for(b in 1:length(filename_methods)){
    
    print('Iterating on Methods')
    
    means_temp2 <- list()
    idx = 4*(a-1) + b
    
    for(c in 1:length(data[[idx]])){
      
      num_entries = length(data[[idx]][[c]])
      
      # CBF
      if(i %% 4 == 1){
        for (k in seq(from = 10, to = num_entries, by=14)){
          means_temp = data[[idx]][[c]][[k]]
          means_temp2 <- c(means_temp2, means_temp)
        }
      }
      # GWA
      else if(i %% 4 == 2){
        for (k in seq(from = 10, to = num_entries, by=14)){
          means_temp = data[[idx]][[c]][[k]]
          means_temp2 <- c(means_temp2, means_temp)
        }
      }
      # IMS
      else if(i %% 4 == 3){
        for (k in seq(from = 10, to = num_entries, by=14)){
          means_temp = data[[idx]][[c]][[k]]
          means_temp2 <- c(means_temp2, means_temp)
        }
      }
      # UWB
      else{
        for (k in seq(from = 10, to = num_entries, by=14)){
          means_temp = data[[idx]][[c]][[k]]
          means_temp2 <- c(means_temp2, means_temp)
        }
      }
      
      print('Extracting data')
      means[[b]] <- means_temp2
      
    }
  }
  
  print('Plotting data')
  
  means_df = data.frame(matrix(unlist(means), nrow=500, byrow=FALSE))
  colnames(means_df) <- c('means_cbf', 'means_gwa', 'means_ims', 'means_uwb')
  
  plot_fullfile_path = paste(plots_filepath, filename_dates[[a]], "_enh_means.jpeg", sep = "")  
  png(file=plot_fullfile_path)
  
  boxplot(means_df$means_uwb, means_df$means_gwa, means_df$means_ims, means_df$means_cbf,
          main = paste("Sample Images from Dataset C-", a, sep=""),
          at = c(1,2,3,4),
          xlab = "Underwater Image Enhancement Methods",
          ylab = "Mean Intensity",
          names = c("UWB", "GWA", "IMS", "CBF"),
          col = c("#1B9E77", "#D95F02", "#7570B3", "#E7298A"))
  
  dev.off()
  
}

#####################################################################################################################
# AVERAGE GRADIENT
#####################################################################################################################

# Date iterator
for(a in 1:length(filename_dates)){
  
  print('Iterating on Dates')
  ag <- list()
  
  for(b in 1:length(filename_methods)){
    
    print('Iterating on Methods')
    
    ag_temp2 <- list()
    idx = 4*(a-1) + b
    
    for(c in 1:length(data[[idx]])){
      
      num_entries = length(data[[idx]][[c]])
      
      # CBF
      if(i %% 4 == 1){
        for (k in seq(from = 14, to = num_entries, by=14)){
          ag_temp = data[[idx]][[c]][[k]]
          ag_temp2 <- c(ag_temp2, ag_temp)
        }
      }
      # GWA
      else if(i %% 4 == 2){
        for (k in seq(from = 14, to = num_entries, by=14)){
          ag_temp = data[[idx]][[c]][[k]]
          ag_temp2 <- c(ag_temp2, ag_temp)
        }
      }
      # IMS
      else if(i %% 4 == 3){
        for (k in seq(from = 14, to = num_entries, by=14)){
          ag_temp = data[[idx]][[c]][[k]]
          ag_temp2 <- c(ag_temp2, ag_temp)
        }
      }
      # UWB
      else{
        for (k in seq(from = 14, to = num_entries, by=14)){
          ag_temp = data[[idx]][[c]][[k]]
          ag_temp2 <- c(ag_temp2, ag_temp)
        }
      }
      
      print('Extracting data')
      ag[[b]] <- ag_temp2
      
    }
  }
  
  print('Plotting data')
  
  ag_df = data.frame(matrix(unlist(ag), nrow=500, byrow=FALSE))
  colnames(ag_df) <- c('ag_cbf', 'ag_gwa', 'ag_ims', 'ag_uwb')
  
  plot_fullfile_path = paste(plots_filepath, filename_dates[[a]], "_enh_ag.jpeg", sep = "")  
  png(file=plot_fullfile_path)
  
  boxplot(ag_df$ag_uwb, ag_df$ag_gwa, ag_df$ag_ims, ag_df$ag_cbf,
          main = paste("Sample Images from Dataset B-", a, sep=""),
          at = c(1,2,3,4),
          xlab = "Underwater Image Enhancement Methods",
          ylab = "Average Gradient",
          names = c("UWB", "GWA", "IMS", "CBF"),
          col = c("#1B9E77", "#D95F02", "#7570B3", "#E7298A"))
  
  dev.off()
  
}
