library(knitr)
library(ggplot2)
library(ggbeeswarm)
library(data.table)
library(magrittr)
library(dplyr)
library(cvequality)
library(outliers)

"
Determine the statistical significance of aging variability due to fast 
formation. Use some statistical tests to determine if the coefficients of
variation from the two sample sets (baseline vs fast formation) are 
statistically different. We need to look at the coefficient of variation 
(standard deviation over mean) since the variation in aging naturally increases 
as the mean increases.
"

remove_outliers <- function(kable_in) {

   kable_out = kable_in
   
   p_value_target = 0.05
   
   x = subset(kable_in, formation_type=='Baseline Formation')$cycles
   y = subset(kable_in, formation_type=='Fast Formation')$cycles
   
   # Initialize a list of indices for storing exclusions
   idx <- c()
   
   # Use Dixon test to remove max outlier (if significant)
   out = dixon.test(x, type = 0, opposite = FALSE, two.sided = TRUE)
   if (unname(out[3]) < p_value_target) {
      cat(sprintf('Removing max from Baseline Formation (%g)...\n', max(x)))
      idx = c(idx, which(max(x) == kable_out$cycles))
   }
   
   out = dixon.test(x, type = 0, opposite = TRUE, two.sided = TRUE)
   if (unname(out[3]) < p_value_target) {
      cat(sprintf('Removing min from Baseline Formation (%g)...\n', min(x)))
      idx = c(idx, which(min(x) == kable_out$cycles))
   }   
   
   out = dixon.test(y, type = 0, opposite = FALSE, two.sided = TRUE)
   if (unname(out[3]) < p_value_target) {
      cat(sprintf('Removing max from Fast Formation (%g)...\n', max(y)))
      idx = c(idx, which(max(y) == kable_out$cycles))
   }   
   
   out = dixon.test(y, type = 0, opposite = TRUE, two.sided = TRUE)
   if (unname(out[3]) < p_value_target) {
      cat(sprintf('Removing min from Fast Formation (%g)...\n', min(y)))
      idx = c(idx, which(min(y) == kable_out$cycles))
   }   

   if (is.null(idx) == FALSE) {
      kable_out <- kable_out[-idx,]
   }
      
   # grubbs.test(x, type = 10, opposite = FALSE, two.sided = TRUE)
   
   return(kable_out)
   
}

run_f_test <- function(kable_in) {
"
Run a simple F test
"
   
   x = subset(kable_in, formation_type=='Baseline Formation')$cycles
   y = subset(kable_in, formation_type=='Fast Formation')$cycles
   
   res.ftest <- var.test(x, y, alternative = 'two.sided')
   res.ftest$p.value
   res.ftest$estimate
   
}

compute_statistics <- function(kable_in, temp_label, retention_label) {
" 
Compute the statistics of variability; are the variabilities between the two
groups statistically significant after accounting for differences in the mean?

References:

https://cran.r-project.org/web/packages/cvequality/vignettes/how_to_test_CVs.html
https://link.springer.com/article/10.1007/s00180-013-0445-2
"
   
   cv_test_asymptotic <- with(kable_in, 
                              asymptotic_test(retention_at_c200, 
                                              is_baseline_formation)
   )
   
   cv_test_MSLRT <- with(kable_in, 
                         mslr_test(nr = 1e4,
                                   retention_at_c200,
                                   is_baseline_formation))
   
   num_data_points = floor(lengths(kable_in['is_baseline_formation'])/2)
   
   label = sprintf("%s, %s \nD'AD Statistic: %.4f, p = %.4f, n = %g", 
                   retention_label, temp_label,
                   cv_test_asymptotic[1],
                   cv_test_asymptotic[2],
                   num_data_points)
   
   cat(label)
   
   
   # Visualize the result for a sec as a sanity check
   ggplot(kable_in,
          aes(is_baseline_formation, retention_at_c200)) +
      geom_boxplot() + 
      geom_quasirandom(alpha = 0.5) +
      theme_bw() + 
      theme(text = element_text(size=20)) + 
      labs(subtitle = label,
           y = "Retention",
           x = NULL) + 
      scale_x_discrete(labels=c("Fast","Baseline"))
   
}

## BEGIN MAIN

# Load the data
setwd('~/code/fast-formation/output')
EndOfLife = read.csv('retention_by_cycles.csv')
kable(head(EndOfLife), caption = "Preview of first few rows of EndOfLife data")

# Define subsets of the table
room_temp = subset(EndOfLife, is_room_temp == 'True')
high_temp = subset(EndOfLife, is_room_temp == 'False')

# Remove outliers
# print('|outlier -> room temp')
# room_temp = remove_outliers(room_temp)
# print('|outlier -> high temp')
# high_temp = remove_outliers(high_temp)

# # Duplicate the dataset to understand the impact of sample size on the p-value
# high_temp = rbind(high_temp, high_temp)

compute_statistics(room_temp, 'room temp', 'Retention at c200') 
#compute_statistics(high_temp, '45C', 'Retention at c200') 

