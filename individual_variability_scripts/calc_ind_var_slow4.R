# This code calculates mean correlational distance (MCD)
# for slow 4 fALFF as a measure of quantifying individual 
# variability among each diagnostic group.


# Get list of text files for each participant group

# 1:185 which is the number of control participants.
list_of_files <- list.files(path = "/mnt/tigrlab/scratch//jgallucci/for_soroush/CTRL_4_UPDATED_DEC13///" ,recursive = TRUE,
                            pattern = "\\.txt$", 
                            full.names = TRUE)

# 186:253 which includes the ASD participants.
list_of_files2<- list.files(path = "/mnt/tigrlab/scratch/jgallucci/for_soroush/ASD_4_UPDATED_DEC13///",recursive = TRUE,
                            pattern = "\\.txt$", 
                            full.names = TRUE)

# 254:495 which includes the SSD participants.
list_of_files3<- list.files(path = "/mnt/tigrlab/scratch//jgallucci/for_soroush/SCZ_4_UPDATED_DEC13///",recursive = TRUE,
                            pattern = "\\.txt$", 
                            full.names = TRUE)

ALL_files <- append(list_of_files, list_of_files2)
ALL_files <- append(ALL_files, list_of_files3)

# Read text files need[1:59412]
txt_files_df <- lapply(ALL_files, function(x) {x = read.table(file = x, header = FALSE, sep =",", nrows = 64984)})

# Combine txt files into a dataframe
combined_df <- do.call("cbind", lapply(txt_files_df, as.data.frame))
combined_df <- na.omit(combined_df)

# Participants (rows) x voxels (columns)
df.final <- as.data.frame(t(combined_df))

# Pairwise correlational distance
# Pairwise distance measure 0 to 1, 0 is less distance = more similar, 1 is more distance = less similar
corr = rdist::pdist(df.final, metric = "correlation")

# Calculate mean distance for each subject
distance= rowMeans(corr,na.rm = TRUE)

# Compare mean distance between groups
CTRL = distance[1:185]
ASD = distance[186:253]
SCZ = distance[254:495]

MCD_slow4 <- cbind(ALL_files, distance)
write.csv(MCD_slow4, "ind_var_4_updated_DEC13.csv")
