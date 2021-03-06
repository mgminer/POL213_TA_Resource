#' ---
#' title: "POL213 TA Session"
#' author: "Gento Kato"
#' date: "May 23, 2019"
#' ---

## Clear Workspace
rm(list = ls())

## Set Working Directory to the File location
## (If using RStudio, can be set automatically)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

## Required packages
library(ggplot2) # Plotting
library(faraway) # for ilogit function
library(pscl) # For pseudo R squared (pR2)
library(DAMisc) # For pre function
library(MASS) # For mvrnorm
library(readstata13)

#'
#' ## Data Preparation (Experiment Data on Name Recognition)
#' 
#' For original article, See [HERE](https://onlinelibrary.wiley.com/doi/full/10.1111/ajps.12034)
#' 

# Import Data
d <- read.dta13("https://github.com/gentok/POL213_TA_Resource/raw/master/KamZechmeister_Study1.dta", 
                convert.factors = FALSE)
names(d)

# FT Griffin Advantage
d$FTgrifadv <- d$FTgriffin - d$FTwilliams

#'
#' ## Run Logit Model
#'

# Baseline Model
m1 <- glm(votegriffin ~ namecond + female + democrat + age1,
          data=d, family=binomial("logit"))
summary(m1)

# Interaction
m2 <- glm(votegriffin ~ namecond*female + democrat + age1,
          data=d, family=binomial("logit"))
summary(m2)

# Some significant continous variable
m3 <- glm(votegriffin ~ FTgrifadv + democrat + age1, 
          data=d, family=binomial("logit")) 
summary(m3)

#'
#' ## Coefficient Plot
#'
#' Create Data Frames with Coefficient Values

(coef1 <- coef(m1)) # coefficient 
(ci1 <- confint(m1, level=0.95)) # 95% confidence interval
cdt1 <- as.data.frame(cbind(coef1, ci1)) # make it a data
colnames(cdt1) <- c("cf","lci","uci") # new names of data
cdt1$name <- "Baseline" # model name

(coef2 <- coef(m2)) # coefficient 
(ci2 <- confint(m2, level=0.95)) # 95% confidence interval
cdt2 <- as.data.frame(cbind(coef2, ci2)) # make it a data
colnames(cdt2) <- c("cf","lci","uci") # new names of data
cdt2$name <- "Interaction" # model name

#'
#' Set Variable Names
#' 
names(coef(m1)) # Check Original Names
cdt1$vn <- c("(Intercept)","Name Treatment",
            "Gender (Female)","Democrat","Age")
names(coef(m2)) # Check Original Names
cdt2$vn <- c("(Intercept)","Name Treatment",
             "Gender (Female)","Democrat","Age",
             "Treatment*Female")
#'
#' Assign Order to Variable Names
#' 
levelset <- c("(Intercept)","Name Treatment",
              "Gender (Female)","Treatment*Female",
              "Democrat","Age")
cdt1$vn <- factor(cdt1$vn, levels = rev(levelset))
cdt2$vn <- factor(cdt2$vn, levels = rev(levelset))
#'
#' * The above code sets ordering of variable labels in the output <br>
#' * Make sure to include all possible values appears in vn variable. <br>
#' * level is reversed for the plotting purpose (because you flip plot later)

#'
#' ### Draw Plot (Model 1)
#' 
#' Optimized for Poster purposes

# Drop intercept from the output 
# (depending on your preference, you can drop ANY variables by its "vn" value)
cdt1x <- cdt1[!cdt1$vn %in% c("(Intercept)"),]

ggplot(cdt1x, aes(x=vn)) + 
   # data is cdt1x, y axis is variable name = vn (flip later)
  geom_point(aes(y=cf),size=3) + 
   # plot point estimate = cf
   # size to control point size
  geom_errorbar(aes(ymin=lci,ymax=uci),width=0.3, size = 1) + 
   # plot confidence interval (lower bound is lci, upper bound is uci)
   # size to control line width
   # width to control th height of vertical lines at the edges
  geom_hline(aes(yintercept=0), linetype=2, size=0.5) + 
   # horizontal line at 0
   # linetype to control form of line (2 is dashed)
   # size to control line width
  xlab(NULL) + 
   # no grand label for variables
  ylab("Coefficient with 95% Confidence Interval") + 
   # Label for x axis (for coefficient value)
  ggtitle("The Effect of Name Treatment on Griffin Vote") + 
   # Title (if not needed, use NULL)
  coord_flip() + 
   # Flip Plot 
  theme_bw() + 
  theme(plot.title = element_text(size=16, face="bold", hjust=0.5),
         # plot title setting (ggtitle argument)
        axis.title.x = element_text(size=13, face="plain", hjust=0.5),
         # x axis title setting 
        axis.text.y = element_text(size=13, face="bold", color="black", hjust=1),
         # y axis labels (variables)
        axis.text.x = element_text(size=13, face="plain", color="black",hjust=0.5)
         # x axis labels (coefficient values)
        )
#'
#' ### Draw Plot (Model 2)
#' 
#' Optimized for Paper purposes

# Drop intercept from the output 
# (depending on your preference, you can drop ANY variables by its "vn" value)
# (If You don't want to drop any variables, delete this line)
cdt2x <- cdt2[!cdt2$vn %in% c("(Intercept)"),]

ggplot(cdt2x, aes(x=vn)) + 
  # data is cdt2x, y axis is variable name = vn (flip later)
  geom_point(aes(y=cf),size=2) + 
  # plot point estimate = cf
  # size to control point size
  geom_errorbar(aes(ymin=lci,ymax=uci),width=0.3, size = 0.5) + 
  # plot confidence interval (lower bound is lci, upper bound is uci)
  # size to control line width
  # width to control th height of vertical lines at the edges
  geom_hline(aes(yintercept=0), linetype=2, size=0.5) + 
  # horizontal line at 0
  # linetype to control form of line (2 is dashed)
  # size to control line width
  xlab(NULL) + 
  # no grand label for variables
  ylab("Coefficient with 95% Confidence Interval") + 
  # Label for x axis (for coefficient value)
  ggtitle("The Effect of Name Treatment on Griffin Vote") + 
  # Title (if not needed, use NULL)
  coord_flip() + 
  # Flip Plot 
  theme_bw() + 
  theme(plot.title = element_text(size=13, face="bold", hjust=0.5),
        # plot title setting (ggtitle argument)
        axis.title.x = element_text(size=11, face="plain", hjust=0.5),
        # x axis title setting 
        axis.text.y = element_text(size=11, face="plain", color="black", hjust=1),
        # y axis labels (variables)
        axis.text.x = element_text(size=11, face="plain", color="black",hjust=0.5)
        # x axis labels (coefficient values)
  )

#'
#' Draw Plot (Two Models Side by Side)
#' 
#' Optimized for Paper purposes

# Combine data of two models
cdt <- rbind(cdt1, cdt2)

# Drop intercept from the output 
# (depending on your preference, you can drop ANY variables by its "vn" value)
# (If You don't want to drop any variables, delete this line)
cdtx <- cdt[!cdt$vn %in% c("(Intercept)"),]

ggplot(cdtx, aes(x=vn)) + 
  # data is cdtx, y axis is variable name = vn (flip later)
  geom_point(aes(y=cf),size=2) + 
  # plot point estimate = cf
  # size to control point size
  geom_errorbar(aes(ymin=lci,ymax=uci),width=0.3, size = 0.5) + 
  # plot confidence interval (lower bound is lci, upper bound is uci)
  # size to control line width
  # width to control th height of vertical lines at the edges
  geom_hline(aes(yintercept=0), linetype=2, size=0.5) + 
  # horizontal line at 0
  # linetype to control form of line (2 is dashed)
  # size to control line width
  facet_grid(. ~ name) +
  # facetting by the model name (name is the model variable created in the data)
  xlab(NULL) + 
  # no grand label for variables
  ylab("Coefficient with 95% Confidence Interval") + 
  # Label for x axis (for coefficient value)
  ggtitle("The Effect of Name Treatment on Griffin Vote") + 
  # Title (if not needed, use NULL)
  coord_flip() + 
  # Flip Plot 
  theme_bw() + 
  theme(plot.title = element_text(size=13, face="bold", hjust=0.5),
        # plot title setting (ggtitle argument)
        axis.title.x = element_text(size=11, face="plain", hjust=0.5),
        # x axis title setting 
        axis.text.y = element_text(size=11, face="plain", color="black", hjust=1),
        # y axis labels (variables)
        axis.text.x = element_text(size=11, face="plain", color="black",hjust=0.5),
        # x axis labels (coefficient values)
        strip.text = element_text(size=11, face="bold", color="black", hjust=0.5)
        # facet strip texts
  )

#'
#' ### Draw Plot (Two Models in the same plot, with different linetype)
#' 
#' Optimized for Paper purposes

## use the same data (i.e., cdtx) as the previous plot.

ggplot(cdtx, aes(x=vn)) + 
  # data is cdtx, y axis is variable name = vn (flip later)
  geom_point(aes(y=cf,shape=name), size=2, 
             position=position_dodge(width=-0.5)) + 
  # plot point estimate = cf
  # point shape is differentiated by "name" == model name
  # size to control point size
  # position_dodge width to control space between two points in the same row.
  geom_errorbar(aes(ymin=lci,ymax=uci,linetype=name),width=0.3, size = 0.5,
                position=position_dodge(width=-0.5)) + 
  # plot confidence interval (lower bound is lci, upper bound is uci)
  # linetype is differentiated by "name" == model name
  # size to control line width
  # width to control th height of vertical lines at the edges
  # position_dodge width to control space between two lines in the same row.
  geom_hline(aes(yintercept=0), linetype=2, size=0.5) + 
  # horizontal line at 0
  # linetype to control form of line (2 is dashed)
  # size to control line width
  scale_shape_discrete(name="Model Name") + 
  # Legend Title for Point Shape
  scale_linetype_discrete(name="Model Name") + 
  # Legend Title for Line Type
  xlab(NULL) + 
  # no grand label for variables
  ylab("Coefficient with 95% Confidence Interval") + 
  # Label for x axis (for coefficient value)
  ggtitle("The Effect of Name Treatment on Griffin Vote") + 
  # Title (if not needed, use NULL)
  coord_flip() + 
  # Flip Plot 
  theme_bw() + 
  theme(plot.title = element_text(size=13, face="bold", hjust=0.5),
        # plot title setting (ggtitle argument)
        axis.title.x = element_text(size=11, face="plain", hjust=0.5),
        # x axis title setting 
        axis.text.y = element_text(size=11, face="plain", color="black", hjust=1),
        # y axis labels (variables)
        axis.text.x = element_text(size=11, face="plain", color="black",hjust=0.5),
        # x axis labels (coefficient values)
        strip.text = element_text(size=11, face="bold", color="black", hjust=0.5),
        # facet strip texts
        legend.title = element_text(size=11, face="plain", color="black",hjust=0.5),
        # legend title text
        legend.text = element_text(size=11, face="plain", color="black",hjust=0.5),
        # legend label text
        legend.position = "top"
        # legend position. You can use "top","bottom","right","left"/like c(0.1,0.1)
  )

#'
#' ## Odds Ratio Plot 
#'
#' Easy. Just convert each variable by exponentiating them.
#' 
#' ### For Model 1 (Optimized for Poster)

# Use the same data cdt1x.

ggplot(cdt1x, aes(x=vn)) + 
  # data is cdt1x, y axis is variable name = vn (flip later)
  geom_point(aes(y=exp(cf)),size=3) + 
  # plot odds ratio point estimate = exp(cf)
  # size to control point size
  geom_errorbar(aes(ymin=exp(lci),ymax=exp(uci)),width=0.3, size = 1) + 
  # plot confidence interval (lower bound is exp(lci), upper bound is exp(uci))
  # size to control line width
  # width to control th height of vertical lines at the edges
  geom_hline(aes(yintercept=1), linetype=2, size=0.5) + 
  # horizontal line at 1
  # linetype to control form of line (2 is dashed)
  # size to control line width
  xlab(NULL) + 
  # no grand label for variables
  ylab("Odds Ratio with 95% Confidence Interval") + 
  # Label for x axis (for coefficient value)
  ggtitle("The Effect of Name Treatment on Griffin Vote") + 
  # Title (if not needed, use NULL)
  coord_flip() + 
  # Flip Plot 
  theme_bw() + 
  theme(plot.title = element_text(size=16, face="bold", hjust=0.5),
        # plot title setting (ggtitle argument)
        axis.title.x = element_text(size=13, face="plain", hjust=0.5),
        # x axis title setting 
        axis.text.y = element_text(size=13, face="bold", color="black", hjust=1),
        # y axis labels (variables)
        axis.text.x = element_text(size=13, face="plain", color="black",hjust=0.5)
        # x axis labels (coefficient values)
  )

#'
#' ## Plotting First Differences of Predicted Probabilities
#' 
#' use model 2 to compare experiment conditions by gender
#'
#' ### Creating Data
#' 
#' Using custom function (for logit)
#' 

# function
logisprob <- function(model,profile,ndraws=1000,cilevel=0.95) {
  # Draw Beta Coefficients
  betadraw <- mvrnorm(ndraws, coef(model), vcov(model))
  # Matrix multiply profile and coefficients
  profile_beta <- as.matrix(profile) %*% t(betadraw)
  # Calculate probability
  profile_prob <- exp(profile_beta) / (1 + exp(profile_beta))
  # Summarize
  meanprob <- rowMeans(profile_prob)
  sdprob <- apply(profile_prob, 1, sd)
  qtprob <- t(apply(profile_prob, 1, quantile, probs=c(0.5,(1-cilevel)/2,1 - (1-cilevel)/2)))
  res <- as.data.frame(cbind(meanprob,sdprob,qtprob))
  colnames(res) <- c("mean","se","median","lci","uci")
  # Return summary
  return(res)
}

# profiles
coef(m2) # check the list of coefficients
# male, control (non-democrat, age=20)
profile1 <- c(1,0,0,0,20,0)
# male, treated (non-democrat, age=20)
profile2 <- c(1,1,0,0,20,0)
# female control (non-democrat, age=20)
profile3 <- c(1,0,1,0,20,0)
# female, treated (non-democrat, age=20)
profile4 <- c(1,1,1,0,20,1)
# combine all profiles
(profile1to4 <- rbind(profile1,profile2,profile3,profile4))

# simulate
set.seed(34)
(predres <- logisprob(m2, profile1to4))

#'
#' Using zelig
#'

require(Zelig)
m2z <- zelig(votegriffin ~ namecond*female + democrat + age1,
             data=d, model="logit")
summary(m2z)

# Create Profiles
profile1z <- setx(m2z, namecond=0, female=0, democrat=0, age1=20)
profile2z <- setx(m2z, namecond=1, female=0, democrat=0, age1=20)
profile3z <- setx(m2z, namecond=0, female=1, democrat=0, age1=20)
profile4z <- setx(m2z, namecond=1, female=1, democrat=0, age1=20)

# Prediction
set.seed(34)
pred1z <- sim(m2z, x = profile1z)
set.seed(34)
pred2z <- sim(m2z, x = profile2z)
set.seed(34)
pred3z <- sim(m2z, x = profile3z)
set.seed(34)
pred4z <- sim(m2z, x = profile4z)

# Extract Simulation Ouput
profile_prob <- rbind(as.numeric(pred1z$sim.out$x$ev[[1]]),
                      as.numeric(pred2z$sim.out$x$ev[[1]]),
                      as.numeric(pred3z$sim.out$x$ev[[1]]),
                      as.numeric(pred4z$sim.out$x$ev[[1]]))
# Summarize
meanprob <- rowMeans(profile_prob)
sdprob <- apply(profile_prob, 1, sd)
qtprob <- t(apply(profile_prob, 1, quantile, probs=c(0.5,0.025,0.975)))
predresz <- as.data.frame(cbind(meanprob,sdprob,qtprob))
colnames(predresz) <- c("mean","se","median","lci","uci")
predresz

# Zelig results look the same as custom results
predresz-predres

#'
#' ### Bar Plot
#' 

# Use predres data
# add variables that describes each profile
# * first two profiles are male, next two profiles are female
predres$gender <- factor(c("Male","Male","Female","Female"),
                          levels=c("Male","Female"))
# * second and fourth profiles are treated, first and third profiles are not.
predres$treatment <- factor(c("Control","Treated","Control","Treated"),
                             levels=c("Control","Treated"))

# plot (optimized for poster)
ggplot(predres, aes(y=mean, x=treatment)) + 
  # data is predres, 
  # y axis is mean predicted probability = mean
  # x axis is treatment groups
  geom_bar(stat="identity", fill="gray40") + 
  # stat allows you to plot value as it is (not aggregating)
  geom_errorbar(aes(ymin=lci,ymax=uci),width=0.3, size = 0.75) + 
  # plot confidence interval (lower bound is lci, upper bound is uci)
  # size to control line width
  # width to control th height of vertical lines at the edges
  facet_grid(. ~ gender) +
  # facetting by gender
  xlab(NULL) + 
  # Label for x axis # Null if not needed
  ylab("Predicted Probability of Griffin Vote \nwith 95% Confidence Interval") + 
  # Label for y axis
  ggtitle("Predicted Probability of Griffin Vote \nby Name Treatment and Gender") + 
  # Title (if not needed, use NULL)
  theme_bw() + 
  theme(plot.title = element_text(size=16, face="bold", hjust=0.5),
        # plot title setting (ggtitle argument)
        axis.title.x = element_text(size=13, face="plain", hjust=0.5),
        # x axis title setting 
        axis.title.y = element_text(size=13, face="plain", hjust=0.5),
        # y axis title setting 
        axis.text.y = element_text(size=13, face="plain", color="black", hjust=1),
        # y axis labels (variables)
        axis.text.x = element_text(size=14, face="bold", color="black",hjust=0.5),
        # x axis labels (coefficient values)
        strip.text = element_text(size=14, face="bold", color="black", hjust=0.5)
        # facet strip texts
        )


#' 
#' ### Point Plot (Notice that scale changes in the y axis)

# Use predresz (zelig) data
# add variables that describes each profile
# * first two profiles are male, next two profiles are female
predresz$gender <- factor(c("Male","Male","Female","Female"),
                         levels=c("Male","Female"))
# * second and fourth profiles are treated, first and third profiles are not.
predresz$treatment <- factor(c("Control","Treated","Control","Treated"),
                            levels=c("Control","Treated"))

# plot (optimized for poster)
ggplot(predresz, aes(y=mean, x=treatment)) + 
  # data is predres, 
  # y axis is mean predicted probability = mean
  # x axis is treatment groups
  geom_point(size=3) + 
  # size to control point size
  geom_errorbar(aes(ymin=lci,ymax=uci),width=0.3, size = 0.75) + 
  # plot confidence interval (lower bound is lci, upper bound is uci)
  # size to control line width
  # width to control th height of vertical lines at the edges
  facet_grid(. ~ gender) +
  # facetting by gender
  xlab(NULL) + 
  # Label for x axis # Null if not needed
  ylab("Predicted Probability of Griffin Vote \nwith 95% Confidence Interval") + 
  # Label for y axis
  ggtitle("Predicted Probability of Griffin Vote \nby Name Treatment and Gender") + 
  # Title (if not needed, use NULL)
  theme_bw() + 
  theme(plot.title = element_text(size=16, face="bold", hjust=0.5),
        # plot title setting (ggtitle argument)
        axis.title.x = element_text(size=13, face="plain", hjust=0.5),
        # x axis title setting 
        axis.title.y = element_text(size=13, face="plain", hjust=0.5),
        # y axis title setting 
        axis.text.y = element_text(size=13, face="plain", color="black", hjust=1),
        # y axis labels (variables)
        axis.text.x = element_text(size=14, face="bold", color="black",hjust=0.5),
        # x axis labels (coefficient values)
        strip.text = element_text(size=14, face="bold", color="black", hjust=0.5)
        # facet strip texts
  )


#'
#' ## Plotting Predicted Probabilities by Continuous Variable
#'
#' ### Creating Data
#' 
#' Use model 3
#' 
#' Use custom function (already created)

# profile
coef(m3) # check coefficients
# move FTgrifadv from its 25%tile to 75%tile
quantile(d$FTgrifadv, probs=c(0.25,0.75), na.rm = TRUE)
# create profile (fixed to non-democrat, age 20)
(profile5 <- data.frame(X0=1,X1=seq(-9.25,0.00,by=0.25),X2=0,X3=20))

# Make predicton
(predres5 <- logisprob(m3,profile5))

#'
#' ### Line Plot
#' 

# Add variable that describes profile
# * the moving parameter ftgrifadv. add it to predres
predres5$FTgrifadv <- seq(-9.25,0.00,by=0.25)

# plot (optimized for poster)
ggplot(predres5, aes(y=mean, x=FTgrifadv)) + 
  # data is predres, 
  # y axis is mean predicted probability = mean
  # x axis is Griffin advantage in FT FTgrifadv
  geom_ribbon(aes(ymin=lci,ymax=uci),fill="gray50", alpha = 0.5) + 
  # plot confidence interval (lower bound is lci, upper bound is uci)
  # alpha to control transparency
  # fill to control filling color
  geom_line(size=1) + 
  # size to control line width
  xlab("Griffin Advantage in Feeling Thermometer") + 
  # Label for x axis # Null if not needed
  ylab("Predicted Probability of Griffin Vote \nwith 95% Confidence Interval") + 
  # Label for y axis
  ggtitle("Predicted Probability of Griffin Vote \nby Feeling Themometer Score") + 
  # Title (if not needed, use NULL)
  theme_bw() + 
  theme(plot.title = element_text(size=16, face="bold", hjust=0.5),
        # plot title setting (ggtitle argument)
        axis.title.x = element_text(size=13, face="bold", hjust=0.5),
        # x axis title setting 
        axis.title.y = element_text(size=13, face="plain", hjust=0.5),
        # y axis title setting 
        axis.text.y = element_text(size=13, face="plain", color="black", hjust=1),
        # y axis labels (variables)
        axis.text.x = element_text(size=13, face="plain", color="black",hjust=0.5)
        # x axis labels (coefficient values)
  )

#+ eval=FALSE, echo=FALSE
# Exporting HTML File
# In R Studio
# rmarkdown::render('TA_session_052319.R', 'pdf_document', encoding = 'UTF-8')
# rmarkdown::render('TA_session_052319.R', 'github_document', clean=FALSE)
# In Terminal, run:
# Rscript -e "rmarkdown::render('TA_session_052319.R', 'github_document')"
# Rscript -e "rmarkdown::render('TA_session_052319.R', 'pdf_document')"
