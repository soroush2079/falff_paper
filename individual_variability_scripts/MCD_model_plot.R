# This script models and plots slow 4 and slow 5 
# Mean Correlation Distance (MCD) of fALFF based on 
# social cognitive scores, diagnostic group, age 
# and sex.

# Join the slow 4 and slow 5 MCD values to the rest of the data containing group, sex, age and site.
new_falff_data_Dec2023 <- full_join(new_falff_data_Dec2023, ind_var_4_updated_DEC13)
new_falff_data_Dec2023 <- full_join(new_falff_data_Dec2023, ind_var_5_updated_DEC13)

new_falff_data_Dec2023$diagnostic_group <- as.factor(new_falff_data_Dec2023$diagnostic_group)
new_falff_data_Dec2023$diagnostic_group <- relevel(new_falff_data_Dec2023$diagnostic_group, "TDC")
new_falff_data_Dec2023$demo_sex <- as.factor(new_falff_data_Dec2023$demo_sex)
new_falff_data_Dec2023$site <- as.factor(new_falff_data_Dec2023$site)

# Model for slow 5 fALFF MCD
model_falff5 <- lm(MCD_5 ~ diagnostic_group + demo_sex + 
                     demo_age_study_entry + er40_total + tasit3_sar +site + mean_fd+
                     er40_total:diagnostic_group + tasit3_sar:diagnostic_group, data = new_falff_data_Dec2023)
car::Anova(model_falff5)

# Model for slow 4 fALFF MCD
model_falff4 <- lm(MCD_4 ~ diagnostic_group + demo_sex + 
                     demo_age_study_entry + er40_total + tasit3_sar +site + mean_fd+
                     er40_total:diagnostic_group + tasit3_sar:diagnostic_group, data = new_falff_data_Dec2023)
car::Anova(model_falff4)

write.csv(new_falff_data_Dec2023, "new_falff_data_Dec2023.csv")



### Plotting slow 4 MCD Models
# Slow 4 MCD as a function of diagnostic group
ggplot(data = new_falff_data_Dec2023, aes(x = diagnostic_group, y = MCD_4)) +
  geom_boxplot() + geom_point() + ylab("Mean Correlational distance") +
  xlab("Diagnostic Group") + ggsignif::geom_signif(comparisons = list(c("ASD","TDC"),
                                                                      c("ASD","SSD"),c("TDC","SSD")), map_signif_level = TRUE)+
  theme_classic()

# Slow 4 MCD as a function of age
ggplot(data = new_falff_data_Dec2023, aes(x = demo_age_study_entry, y = MCD_4)) + geom_point() +
  stat_smooth(method = "lm", se = TRUE)+ ylab("Mean Correlational distance") +
  xlab("Age") +theme_classic()

# Slow 4 MCD as a function of TASIT3 Sarcasm Score
ggplot(data = new_falff_data_Dec2023, aes(x = tasit3_sar, y = MCD_4)) + geom_point() +
  stat_smooth(method = "lm", se = TRUE)+ ylab("Mean Correlational distance") +
  xlab("TASIT 3 Sarcasm") + theme_classic()




### Plotting slow 5 MCD Models
# Slow 5 MCD as a function of sex
ggplot(data = new_falff_data_Dec2023, aes(x = demo_sex, y = MCD_5)) +
  geom_boxplot() + geom_point() + ylab("Mean Correlational distance") +
  xlab("Sex") + ggsignif::geom_signif(comparisons = list(c("Male","Female")), map_signif_level = TRUE)+
  theme_classic()

# Slow 5 MCD as a function of age
ggplot(data = new_falff_data_Dec2023, aes(x = demo_age_study_entry, y = MCD_5)) + geom_point() +
  stat_smooth(method = "lm", se = TRUE)+ ylab("Mean Correlational distance") +
  xlab("Age") +theme_classic()

# Slow 5 MCD as a function of TASIT3 Sarcasm Scores
ggplot(data = new_falff_data_Dec2023, aes(x = tasit3_sar, y = MCD_5)) + geom_point() +
  stat_smooth(method = "lm", se = TRUE)+ ylab("Mean Correlational distance") +
  xlab("TASIT 3 Sarcasm") + theme_classic()
