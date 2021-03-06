require(grid)
library(ggplot2)
library(reshape2)


path_source <- "D:/active/exploratorien/paper_be_meteorology/src/"
path_data <- "D:/active/exploratorien/data/"
path_output <- "D:/active/exploratorien/output/"

source(paste0(path_source, "be_deseason.R"))
source(paste0(path_source, "be_io_lui.R"))
source(paste0(path_source, "be_io_lut.R"))
source(paste0(path_source, "be_io_met_annual.R"))
source(paste0(path_source, "be_io_met_monthly.R"))
source(paste0(path_source, "be_plot_multi.R"))
source(paste0(path_source, "be_plot_pr_am_box_combined.R"))
source(paste0(path_source, "be_plot_pr_mm_box.R"))
source(paste0(path_source, "be_plot_pr_mm_box_combined.R"))
source(paste0(path_source, "be_plot_pr_mm_box_combined_indv.R"))
source(paste0(path_source, "be_plot_pr_mm_ds_box.R"))
source(paste0(path_source, "be_plot_pr_mm_ds_box_combined.R"))
source(paste0(path_source, "be_plot_pr_mm_ds_box_combined_indv.R"))
source(paste0(path_source, "be_plot_ta_mm_box.R"))
source(paste0(path_source, "be_plot_ta_am_box_combined.R"))
source(paste0(path_source, "be_plot_ta_mm_box_combined.R"))
source(paste0(path_source, "be_plot_ta_am_box_combined_indv.R"))
source(paste0(path_source, "be_plot_ta_mm_box_combined_indv.R"))
source(paste0(path_source, "be_plot_ta_mm_ds_box.R"))
source(paste0(path_source, "be_plot_ta_mm_ds_box_combined.R"))
source(paste0(path_source, "be_plot_ta_mm_ds_box_combined_indv.R"))
source(paste0(path_source, "000_be_plot_pr_mmltm.R"))

# Read data
df_met_m <- be_io_met_monthly(paste0(path_data, "met_m/plots.csv"))
df_met_a <- be_io_met_annual(paste0(path_data, "met_a/plots.csv"))
df_lui <- be_io_lui(paste0(path_data, "lui.csv"))
df_lut <- be_io_lut(paste0(path_data, "lut.csv"))
df_bio <- read.table(paste0(path_data, "biomasse.csv"), header = TRUE, sep = ";", dec = ",")


tmin <- unique(df_met_m$timestamp[as.character(df_met_m$datetime) == "2009-01-01T00:00"]) - 1
tmax <- unique(df_met_m$timestamp[as.character(df_met_m$datetime) == "2016-01-01T00:00"])

df_met_m_2016 <- df_met_m[df_met_m$timestamp >= tmax, ]

df_met_m <- df_met_m[tmin < df_met_m$timestamp & df_met_m$timestamp < tmax, ]


# Copy the values from column P_RT_NRT_02 into column P_RT_NRT only for HET*
df_met_m$P_RT_NRT[df_met_m$plotID == "HET38"] <- df_met_m$P_RT_NRT_02[df_met_m$plotID == "HET38"]
df_met_m$P_RT_NRT[df_met_m$plotID == "HET38"] <- df_met_m$P_RT_NRT_02[df_met_m$plotID == "HET38"]

# Deseason annual air temperature
df_met_m <- be_deseason_m(df_met_m)
df_met_a <- be_deseason_a(df_met_a)


# COMBINE DATASETS
df_lui_lut <- merge(df_lui, df_lut, by=c("plotID","year"), all.x = TRUE)
df_met_m <- merge(df_met_m, df_lui_lut, 
                  by.x=c("plotID","g_a"), by.y=c("plotID","year"),
                  all.x = TRUE)
df_met_a <- merge(df_met_a, df_lui_lut, 
                  by.x=c("plotID","g_a"), by.y=c("plotID","year"),
                  all.x = TRUE)
df_bio <- merge(df_met_a[df_met_a$g_a== "2009",], df_bio,by.x=c("plotID"),
                all.x = TRUE)

head(df_met_m)
head(df_met_a)
head(df_bio)

t <- df_met_a[as.character(df_met_a$g_belc) %in% c("HEG"),]
plot(t$L, t$Ta_200)
l <- lm(t$Ta_200 ~ t$L)
summary(l)
abline(l)


ggplot(t, aes(x = LUI, y = Ta_200, color = LUI)) + 
  geom_boxplot(, notch = TRUE)

# PLOTS
# Create plots per exploratory and land cover type
belc_ta <- unique(df_met_m$g_belc[df_met_m$g_belc != "AET" & 
                                    df_met_m$g_belc != "SET"])
belc_p <- c("AEG", "HEG", "SEG")


ggplot(data = df_met_m[
  as.character(df_met_m$plotID) %in% c("HEG42", "HEG16", "HEG04"),], 
       aes(x = g_a, y = Ta_200_mm_ds, fill = plotID)) +
  geom_boxplot(notch = TRUE)

ggplot(data = df_met_m[
  as.character(df_met_m$plotID) %in% c("HEW12", "HEG42"),], 
  aes(x = g_a, y = Ta_200_mm_ds, fill = plotID)) +
  geom_boxplot(notch = TRUE)

ggplot(data = df_met_m_nd[
  as.character(df_met_m_nd$plotID) %in% c("HEG03", "HEG19", "HEG20", "HEG24", "HEG29", "HEG31", "HEG48"),], 
  aes(x = g_a, y = P_RT_NRT_ms_ds, fill = plotID)) +
  geom_boxplot(notch = TRUE)+
  theme_bw() +
  ggtitle("Deseasoned rainfall variablity, HEGx") + 
  theme(plot.title = element_text(size = 20),
        axis.title = element_text(size = 20),
        axis.text = element_text(size = 15)) + 
  labs(x = "Year", y = "Rainfall (mm)")


ggplot(data = df_met_m_nd[
  as.character(df_met_m_nd$plotID) %in% c("HEG03", "HEG19", "HEG20", "HEG24", "HEG29", "HEG31", "HEG48"),], 
  aes(x = plotID, y = P_RT_NRT, fill = plotID)) +
  geom_boxplot(notch = TRUE)




df_met_m[as.character(df_met_m$plotID) == "HEG42", "Ta_200"] | 
           as.character(df_met_m$plotID) == "HEG17",]

# Mean monthly air temperature over all years per Exploratory (combined plot)
ta_mm_box_combined <- be_plot_ta_mm_box_combined(data = df_met_m, notch = TRUE, title = NULL)  
png(paste0(path_output, "ta_mm_box_combined.png"), 
    width = 1024 * 7, 
    height = 748 * 6, 
    units = "px", 
    res = 600)
ta_mm_box_combined
graphics.off()


data(Fort)ta_mm_box_combined_indv <- be_plot_ta_mm_box_combined_indv(data = df_met_m, notch = TRUE, title = NULL,
                                                      plotIDs = c("HEG42", "HEW12"),
                                                      belcs = c("HEG", "HEW"))  
png(paste0(path_output, "ta_mm_box_combined_indv.png"), 
    width = 1024 * 7, 
    height = 748 * 6, 
    units = "px", 
    res = 600)
ta_mm_box_combined_indv
graphics.off()


# Monthly air temperature deviations from long term mean per year and Exploratory
ta_mm_ds_box_combined <- be_plot_ta_mm_ds_box_combined(data = df_met_m, notch = TRUE, title = NULL)  
png(paste0(path_output, "ta_mm_ds_box_combined.png"), 
    width = 1024 * 7, 
    height = 748 * 6, 
    units = "px", 
    res = 600)
ta_mm_ds_box_combined
graphics.off()



ta_mm_ds_box_combined_indv <- be_plot_ta_mm_ds_box_combined_indv(data = df_met_m, notch = TRUE, title = NULL,
                                   plotIDs = c("HEG42", "HEW12"),
                                   belcs = c("HEG", "HEW"))
png(paste0(path_output, "ta_mm_ds_box_combined_indv.png"), 
    width = 1024 * 7, 
    height = 748 * 6, 
    units = "px", 
    res = 600)
ta_mm_ds_box_combined_indv
graphics.off()


ta_am_box_combined <- be_plot_ta_am_box_combined(data = df_met_a, notch = TRUE, title = NULL)  
png(paste0(path_output, "ta_am_box_combined.png"), 
    width = 1024 * 7, 
    height = 748 * 6, 
    units = "px", 
    res = 600)
ta_am_box_combined
graphics.off()


ta_am_box_combined_indv <- be_plot_ta_am_box_combined_indv(data = df_met_a, notch = TRUE, title = NULL,
                                                           plotIDs = c("HEG42", "HEW12"),
                                                           belcs = c("HEG", "HEW"))
png(paste0(path_output, "ta_am_box_combined_indv.png"), 
    width = 1024 * 7, 
    height = 748 * 6, 
    units = "px", 
    res = 600)
ta_am_box_combined_indv
graphics.off()




for(i in unique(df_met_a$g_belc)){
  print(i)
  print(summary(df_met_a[df_met_a$g_belc == i, 
                         c("g_belc", "Ta_200", "Ta_200_min", 
                           "Ta_200_max", "P_RT_NRT")]))
}


df_met_m_nd <- df_met_m[df_met_m$P_RT_NRT < 300,]


# Mean monthly rainfall over all years per Exploratory (combined plot)
df_met_a_nd <- aggregate(df_met_m_nd$P_RT_NRT, by = list(df_met_m_nd$g_pa), FUN = sum)
colnames(df_met_a_nd)[2] <- "P_RT_NRT"
df_met_a_nd$g_belc <- substr(df_met_a_nd$Group.1, 1, 3)
df_met_a_nd$g_a <- substr(df_met_a_nd$Group.1, 7, 10)

pr_am_box_combined <- be_plot_pr_am_box_combined(data = df_met_a_nd[
  df_met_a_nd$g_belc %in% c("AEG", "HEG", "SEG") &
    df_met_a_nd$P_RT_NRT > 250, ], title = NULL) 

png(paste0(path_output, "pr_am_box_combined.png"), 
    width = 1024 * 7, 
    height = 748 * 6, 
    units = "px", 
    res = 600)
pr_am_box_combined
graphics.off()


pr_mm_box_combined <- be_plot_pr_mm_box_combined(data = df_met_m_nd, title = NULL) 
png(paste0(path_output, "pr_mm_box_combined.png"), 
    width = 1024 * 7, 
    height = 748 * 6, 
    units = "px", 
    res = 600)
pr_mm_box_combined
graphics.off()


ta_mm_extremes_fit <- fevd(df_met_m_nd$P_RT_NRT[!is.na(df_met_m_nd$P_RT_NRT) &
                                                  df_met_m_nd$g_belc == "HEG" &
                                                  df_met_m_nd$g_m == "07"], 
                           time.units = "months",  units = "mm")
ta_mm_extremes_fit
plot(ta_mm_extremes_fit)


pr_mm_box_combined_indv <- be_plot_pr_mm_box_combined_indv(data = df_met_m_nd, title = NULL, notch = FALSE,
                                plotIDs = c("HEG19"),
                                belcs = c("HEG", "HET")) 
png(paste0(path_output, "pr_mm_box_combined_indv.png"), 
    width = 1024 * 7, 
    height = 748 * 6, 
    units = "px", 
    res = 600)
pr_mm_box_combined_indv
graphics.off()


# Monthly rainfall total deviations from long term mean per year and Exploratory
pr_mm_ds_box_combined <- be_plot_pr_mm_ds_box_combined(data = df_met_m_nd, title = NULL)  
png(paste0(path_output, "pr_mm_ds_box_combined.png"), 
    width = 1024 * 7, 
    height = 748 * 6, 
    units = "px", 
    res = 600)
pr_mm_ds_box_combined
graphics.off()


pr_mm_ds_box_combined_indv <- be_plot_pr_mm_ds_box_combined_indv(data = df_met_m_nd, title = NULL, notch = TRUE,
                                   plotIDs = c("HEG19"),
                                   belcs = c("HEG", "HET")) 
png(paste0(path_output, "pr_mm_ds_box_combined_indv.png"), 
    width = 1024 * 7, 
    height = 748 * 6, 
    units = "px", 
    res = 600)
pr_mm_ds_box_combined_indv
graphics.off()




#Test tnauss
data <- df_met_m[df_met_m$g_belc == "HEG",]
data <- df_met_m
title <- "test"

data$LUI_cut <- cut(data$LUI, c(0, median(data$LUI, na.rm = TRUE), 
                                max(data$LUI, na.rm = TRUE)))



data$LUI_cut <- cut(data$LUI, quantile(data$LUI, probs = seq(0, 1, 0.1), na.rm = TRUE))
data$LUI_cut <- cut(data$LUI, seq(0, 5, 1))
data$M_std_cut <- cut(data$M_std, seq(0, 5, 1))
data$G_std_cut <- cut(data$G_std, seq(0, 10, 1))
data$F_std_cut <- cut(data$F_std, seq(0, 7, 1))

ggplot(data[!is.na(data$LUI_cut),], aes(x = LUI_cut, y = Ta_200_mm_ds, fill = g_belc)) + geom_boxplot(notch=TRUE)
ggplot(data[!is.na(data$LUI_cut),], aes(x = LUI_cut, y = Ta_200_min_mm_ds, fill = g_belc)) + geom_boxplot(notch=TRUE)
ggplot(data[!is.na(data$LUI_cut),], aes(x = LUI_cut, y = Ta_200_max_mm_ds, fill = g_belc)) + geom_boxplot(notch=TRUE)

ggplot(data[!is.na(data$LUI),], aes(x = LUI, y = Ta_200_mm_ds)) + geom_point()
ggplot(data[!is.na(data$LUI),], aes(x = LUI, y = Ta_200_min_mm_ds)) + geom_point()

summary(lm(Ta_200_max_mm_ds ~ LUI, data = data))

ggplot(data, aes(x = M_std_cut, y = Ta_200_mm_ds)) + geom_boxplot(notch=TRUE)
ggplot(data, aes(x = G_std_cut, y = Ta_200_mm_ds)) + geom_boxplot(notch=TRUE)
ggplot(data, aes(x = F_std_cut, y = Ta_200_mm_ds)) + geom_boxplot(notch=TRUE)
ggplot(data, aes(x = LUI, y = M_std, color = as.factor(g_a))) + geom_point()
ggplot(data[data$plotID == "SEG20" & data$g_a < 2013,], aes(x = timestamp, y = Ta_200_mm_ds, group =1)) + geom_point() + geom_smooth(method=lm)


ggplot(df_bio, aes(x = BM, y = Ta_200_am_ds)) + geom_point()
summary(lm(Ta_200_am_ds ~ BM, data = df_bio))

#Test sforteva bio
dataBM <- df_bio[df_bio$g_belc == "SEG",]
title <- "test BM"
dataBM$BM_cut <- cut(dataBM$BM, quantile(dataBM$BM, probs = seq(0, 1, 0.1), na.rm = TRUE))
#dataBM$BM_cut <- cut(dataBM$BM, seq(0, 5, 1))
ggplot(dataBM[!is.na(dataBM$BM_cut),], aes(x = BM_cut, y = Ta_200_am_ds)) + geom_boxplot(notch=TRUE)
ggplot(dataBM[!is.na(dataBM$BM_cut),], aes(x = BM, y = Ta_200)) + geom_point()
plot(Ta_200 ~ BM, dataBM[!is.na(dataBM$BM_cut),])

#ggplot(dataBM, aes(x = BM, y = M_std, color = as.factor(g_a))) + geom_point()



# Mean monthly air temperature one year (in multiplot)
# png(paste0(path_output, "be_plot_multiplot_ta_200_ta_mm_box_multplot.png"),
#     width     = 3880,
#     height    = 4808,
#     units     = "px",
#     res       = 200,
#     # pointsize = 1
# )
# p1 <- try(be_plot_ta_mm_box(data = df_met_m[df_met_m$g_belc == "HEG",], title = "HEG") )
# p2 <- try(be_plot_ta_mm_box(data = df_met_m[df_met_m$g_belc == "HEW",], title = "HEW") )
# p3 <- try(be_plot_ta_mm_box(data = df_met_m[df_met_m$g_belc == "SEG",], title = "SEG") )
# p4 <- try(be_plot_ta_mm_box(data = df_met_m[df_met_m$g_belc == "SEW",], title = "SEW") )
# p5 <- try(be_plot_ta_mm_box(data = df_met_m[df_met_m$g_belc == "AEG",], title = "AEG") )
# p6 <- try(be_plot_ta_mm_box(data = df_met_m[df_met_m$g_belc == "AEW",], title = "AEW") )
# try(be_plot_multi(p1, p2, p3, p4, p5, p6))
# dev.off()

# Mean monthly deseasoned air temperature one year (in multiplot)
# png(paste0(path_output, "be_plot_multiplot_ta_200_ta_mm_ds_box_multplot.png"),
#     width     = 3880,
#     height    = 4808,
#     units     = "px",
#     res       = 200,
#     # pointsize = 1
# )
# p1 <- try(be_plot_ta_mm_ds_box(data = df_met_m[df_met_m$g_belc == "HEG",], title = "HEG") )
# p2 <- try(be_plot_ta_mm_ds_box(data = df_met_m[df_met_m$g_belc == "HEW",], title = "HEW") )
# p3 <- try(be_plot_ta_mm_ds_box(data = df_met_m[df_met_m$g_belc == "SEG",], title = "SEG") )
# p4 <- try(be_plot_ta_mm_ds_box(data = df_met_m[df_met_m$g_belc == "SEW",], title = "SEW") )
# p5 <- try(be_plot_ta_mm_ds_box(data = df_met_m[df_met_m$g_belc == "AEG",], title = "AEG") )
# p6 <- try(be_plot_ta_mm_ds_box(data = df_met_m[df_met_m$g_belc == "AEW",], title = "AEW") )
# try(be_plot_multi(p1, p2, p3, p4, p5, p6))
# dev.off()
