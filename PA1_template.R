library(knitr)
opts_chunk$set(echo=TRUE, cache=TRUE)
data <- read.csv(unz("activity.zip", "activity.csv"))

##What is mean total number of steps taken per day?
##1.For this part of the assignment, you can ignore the missing values in the dataset.
##2.Make a histogram of the total number of steps taken each day
##3.Calculate and report the mean and median total number of steps taken per day
hist(tapply(data$steps, data$date, sum), xlab = "Total daily steps", breaks = 20, 
     main = "Total of steps taken per day")

total.daily.steps <- as.numeric(tapply(data$steps, data$date, sum))
step.mean <- mean(total.daily.steps, na.rm = TRUE)
step.median <- median(total.daily.steps, na.rm = TRUE)

step.mean
step.median

##What is the average daily activity pattern?
##1.Make a time series plot (i.e. type = "l") of the 5-minute interval (x-axis) and the average number of steps taken, averaged across all days (y-axis)
##2.Which 5-minute interval, on average across all the days in the dataset, contains the maximum number of steps?

data$interval <- as.factor(as.character(data$interval))
interval.mean <- as.numeric(tapply(data$steps, data$interval, mean, na.rm = TRUE))
intervals <- data.frame(intervals = as.numeric(levels(data$interval)), interval.mean)
intervals <- intervals[order(intervals$intervals), ]

labels <- c("00:00", "05:00", "10:00", "15:00", "20:00")
labels.at <- seq(0, 2000, 500)
plot(intervals$intervals, intervals$interval.mean, type = "l", main = "Average steps 5-minute interval", 
     ylab = "Average steps", xlab = "Time of day", xaxt = "n")
axis(side = 1, at = labels.at, labels = labels)


intervals.sorted <- intervals[order(intervals$interval.mean, decreasing = TRUE),]
head(intervals.sorted)

max.interval <- intervals.sorted$intervals[1[1]]
max.interval
##The 5-minute interval with the highest average number of steps corresponds to the interval between 8:35 AM and 8:40 AM.


##Imputing missing values
##Note that there are a number of days/intervals where there are missing values (coded as NA). The presence of missing days may introduce bias into some calculations or summaries of the data.
##1.Calculate and report the total number of missing values in the dataset (i.e. the total number of rows with NAs)
##2.Devise a strategy for filling in all of the missing values in the dataset. The strategy does not need to be sophisticated. For example, you could use the mean/median for that day, or the mean for that 5-minute interval, etc.
##3.Create a new dataset that is equal to the original dataset but with the missing data filled in.
##4.Make a histogram of the total number of steps taken each day and Calculate and report the mean and median total number of steps taken per day. Do these values differ from the estimates from the first part of the assignment? What is the impact of imputing missing data on the estimates of the total daily number of steps?

dim(data[is.na(data$steps), ])[1]

##The total number of missing values in the dataset (i.e. the total number of rows with NAs) is 2304.
##The strategy for filling in all of the missing values in the dataset is to change the ��NA"s to the mean values for that 5-minute interval.
steps <- vector()
for (i in 1:dim(data)[1]) {
  if (is.na(data$steps[i])) {
    steps <- c(steps, intervals$interval.mean[intervals$intervals == data$interval[i]])
  } else {
    steps <- c(steps, data$steps[i])
  }
}

activity.without.missing.data <- data.frame(steps = steps, date = data$date, 
                                            interval = data$interval)
hist(tapply(activity.without.missing.data$steps, activity.without.missing.data$date, 
            sum), xlab = "Total daily steps", breaks = 20, main = "Total of steps taken per day")


total.daily.steps <- as.numeric(tapply(activity.without.missing.data$steps, 
                                       activity.without.missing.data$date, sum))
step.mean <- mean(total.daily.steps)
step.median <- median(total.daily.steps)
step.mean
##The new mean and median of total number of steps taken per day are 10766 and 10766 respectively, the median is exactly equal to the mean. Because of the strategy chosen, there is no impact of imputing missing data on the estimates of the total daily number of steps.


##Are there differences in activity patterns between weekdays and weekends?
##For this part the weekdays() function may be of some help here. Use the dataset with the filled-in missing values for this part.
##Create a new factor variable in the dataset with two levels �V ��weekday�� and ��weekend�� indicating whether a given date is a weekday or weekend day.
##Make a panel plot containing a time series plot (i.e. type = "l") of the 5-minute interval (x-axis) and the average number of steps taken, averaged across all weekday days or weekend days (y-axis). The plot should look something like the following, which was creating using simulated data:


##Classify by weekend and weekday and repeat the previous process. Create a new factor variable with two factor levels in the dataset - weekday and weekend - indicating whether a given date is a weekday or weekend day.

activity.without.missing.data$day.type <- c("weekend", "weekday", "weekday", 
                                            "weekday", "weekday", "weekday", "weekend")[as.POSIXlt(activity.without.missing.data$date)$wday + 
                                                                                          1]
activity.without.missing.data$day.type <- as.factor(activity.without.missing.data$day.type)

weekday <- activity.without.missing.data[activity.without.missing.data$day.type == 
                                           "weekday", ]
weekend <- activity.without.missing.data[activity.without.missing.data$day.type == 
                                           "weekend", ]
weekday.means <- as.numeric(tapply(weekday$steps, weekday$interval, mean))
weekend.means <- as.numeric(tapply(weekend$steps, weekend$interval, mean))

intervals.day.type <- data.frame(intervals = as.numeric(levels(data$interval)), 
                                 weekday.means, weekend.means)
intervals.day.type <- intervals.day.type[order(intervals.day.type$intervals),]


##Plot two time series - weekdays and weekends - of the 5-minute intervals and average number of steps taken.
par <- par(mfrow = c(2, 1))
plot(intervals.day.type$intervals, intervals.day.type$weekday.means, type = "l", 
     col = "red", ylab = "Average steps", xlab = "Time of day", main = "Average steps 5-minute interval at weekday", 
     xaxt = "n")
axis(side = 1, at = labels.at, labels = labels)
plot(intervals.day.type$intervals, intervals.day.type$weekend.means, type = "l", 
     col = "blue", ylab = "Average steps", xlab = "Time of day", main = "Average steps 5-minute interval at weekend", 
     xaxt = "n")
axis(side = 1, at = labels.at, labels = labels)


par(par)
##It is a bit difficult to compare the two plots. For a better comparison, combine the time series on a single plot.
plot(intervals.day.type$intervals, intervals.day.type$weekday.means, type = "l", 
     col = "red", ylab = "Average steps", xlab = "Time of day", main = "Comparison between weekday and weekend", 
     xaxt = "n")
axis(side = 1, at = labels.at, labels = labels)
lines(intervals.day.type$intervals, intervals.day.type$weekend.means, type = "l", 
      col = "blue")
legend(1500, 230, c("Weekend", "Weekday "), lty = c(1, 1), lwd = c(1, 1), col = c("blue", 
                                                                                  "red"))
