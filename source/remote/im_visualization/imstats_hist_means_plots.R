#####################################################################################################################
# DATA VISUALIZATION
# AUthor: VJA
#####################################################################################################################

# Import libraries
library(R.matlab)
library(plyr)

# Define file path of image statistics (matrix files)
#filepath = "C:/Users/ERDT/Documents/7_analysis_m/datasetB_analysis/stats/"

#filepath = "C:/Users/ERDT/Documents/7_analysis_m/datasetC_analysis/stats/"
#filepath = "C:/Users/ERDT/Documents/7_analysis_m/datasetC_prepro_analysis/stats/"
filepath = "C:/Users/ERDT/Documents/7_analysis_m/datasetC_prepro_analysis/stats/"

# Store first matrix file into a list
mat_list_filenames_all = list.files(path = filepath, pattern = "*.mat")

# Find unique dates and methods in the filenames
filename_dates <- list()

for(i in 1:length(mat_list_filenames_all)){
  filename_dates_temp = substring(mat_list_filenames_all[i],1,10)
  
  filename_dates <- c(filename_dates, filename_dates_temp)
}

filename_dates <- unique(filename_dates)

# Classify file names into methods and dates
mat_list_filenames_by_date <- list()

# Prepare data structure
for(i in 1:length(filename_dates)){
  list_temp <- list()
  mat_list_filenames_by_date[[i]] <- c(list_temp)
}

for(i in 1:length(mat_list_filenames_all)){
  for(j in 1:length(filename_dates)){
      if(substring(mat_list_filenames_all[i],1,10) == filename_dates[[j]]){
          mat_list_filenames_by_date[[j]] <- c(mat_list_filenames_by_date[[j]], mat_list_filenames_all[i])
      }
  }
}

# Store data from matrix files
data <- list()

for(i in 1:length(mat_list_filenames_by_date)){
  data_temp2 <- list() 

  for(j in 1:length(mat_list_filenames_by_date[[i]])){
    data_temp <- readMat(paste(filepath, mat_list_filenames_by_date[[i]][[j]], sep = ""))
    data_temp2 <- c(data_temp2, data_temp)
  }
  
  data[[i]] <- c(data_temp2)
  
}

# Prepare plot file names
plots_filepath = "C:/Users/ERDT/Documents/6_analysis_R/datasetC_prepro_plots/"
if(!dir.exists(plots_filepath)){
  dir.create(plots_filepath)
} 

################################################################################
# 1 - PLOT OF MEANS
################################################################################

R_means <- list()
G_means <- list()
B_means <- list()

# Date iterator
for(a in 1:length(filename_dates)){

  R_means_temp <- list()
  G_means_temp <- list()
  B_means_temp <- list()
  
  for(b in 1:length(data[[a]])){
    
    num_entries = length(data[[a]][[b]])
    
    for (i in seq(from = 6, to = num_entries, by=8)){
      R_ave = data[[a]][[b]][[i]]
      R_means_temp <- c(R_means_temp, R_ave)
    }
    
    for (i in seq(from = 7, to = num_entries, by=8)){
      G_ave = data[[a]][[b]][[i]]
      G_means_temp <- c(G_means_temp, G_ave)
    }
    
    for (i in seq(from = 8, to = num_entries, by=8)){
      B_ave = data[[a]][[b]][[i]]
      B_means_temp <- c(B_means_temp, B_ave)
    }
    
    R_means[[a]] <- R_means_temp
    G_means[[a]] <- G_means_temp
    B_means[[a]] <- B_means_temp
    
  }

  # Plot function
  
  plot_fullfile_path = paste(plots_filepath, filename_dates[[a]], "_anl_means.jpeg", sep = "")

  png(file=plot_fullfile_path)

  x = 1:500

  R_m <- unlist(R_means[[a]])
  G_m <- unlist(G_means[[a]])
  B_m <- unlist(B_means[[a]])


  plot(x, R_m, type = "p", xlim = c(0,500), ylim = c(0,255), col = "red", xlab = "Sample Image Number", ylab = "Intensity (0-255)",
       main = paste("Mean Intensities of Sample Images, Dataset C-", a, sep = ""))

  lines(x, G_m, type = "p",col = "green")

  lines(x, B_m, type = "p",col = "blue")

  abline(lm(R_m ~ x), col = 'red', lty = 5, lwd = 2)
  abline(lm(G_m ~ x), col = 'green', lty = 5, lwd = 2)
  abline(lm(B_m ~ x), col = 'blue', lty = 5, lwd = 2)

  graphics.off()
  # dev.off()

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


################################################################################
# 2 - HISTOGRAMS
################################################################################

for(a in 1:length(filename_dates)){
  
  R_bins <- data.frame()
  G_bins <- data.frame()
  B_bins <- data.frame()
  
  # Extract histogram bins from data  
  for(b in 1:length(data[[a]])){
    
    num_entries = length(data[[a]][[b]])
  
    for (i in seq(from = 3, to = num_entries, by=8)){
      R <- c(data[[a]][[b]][[i]])
      R_bins <- rbind(R_bins, R)
    }
    
    for (i in seq(from = 4, to = num_entries, by=8)){
      G <- c(data[[a]][[b]][[i]])
      G_bins <- rbind(G_bins, G)
    }
    
    for (i in seq(from = 5, to = num_entries, by=8)){
      B <- c(data[[a]][[b]][[i]])
      B_bins <- rbind(B_bins, B)
    }

  }
  
  # Rename columns of data frame
  count_list <- list()
  col_count = 0
  
  for (col_count in seq(from = 1, to = 256)){
    count_list <- cbind(count_list, paste(toString(col_count), sep=""))
  }
  
  colnames(R_bins) <- count_list
  colnames(G_bins) <- count_list
  colnames(B_bins) <- count_list
  
  # Determine sum of bins
  x = 0:255
  R_bins_sum <- colSums(matrix(unlist(R_bins), ncol = 256))
  G_bins_sum <- colSums(matrix(unlist(G_bins), ncol = 256))
  B_bins_sum <- colSums(matrix(unlist(B_bins), ncol = 256))
  
  # Plot cumulative histograms
  plot_fullfile_path = paste(plots_filepath, filename_dates[[a]], "_anl_hist.jpeg", sep = "")
  
  png(file=plot_fullfile_path)
  
  par(mfrow=c(3,1), "mai" = c(0.55,0.75,0.25,0.25))
  
  plot(x, R_bins_sum, xlim=c(0,256), type = "h", col = "red", ylab = "Number of Occurences", xlab = "Intensity (0-255)",
       main = paste("Histogram of Color Intensities of Sample Images, Dataset C-", a, sep=""), lwd = 2)
  
  plot(x, G_bins_sum, xlim=c(0,256), type = "h", col = "green", ylab = "Number of Occurences", xlab = "Intensity (0-255)",
       lwd = 2)
  
  plot(x, B_bins_sum, xlim=c(0,256), type = "h", col = "blue", ylab = "Number of Occurences", xlab = "Intensity (0-255)",
       lwd = 2)
  
  graphics.off()
  #dev.off()
  
}




