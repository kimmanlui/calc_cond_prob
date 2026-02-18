#Assume your data frame is named df

df <- data.frame(
exam_score = c(85, 78, 90, 92, 70, 88, 95),
age = c(16, 17, 18, 19, 16, 17, 18),
height = c(150, 160, 165, 170, 155, 158, 172),
weight = c(45, 60, 62, 67, 50, 55, 68),
income = c(3000, 3200, 3500, 4000, 2600, 3100, 3900)
)

#Find P(exam_score ≥ 80 | age), where age is split into three groups.

calc_cond_prob(df, "exam_score >= 80 ~ age ", range_list=list( 3))

#Find P(exam_score ≥ 80 | age and height and weight and income), where their groups are split into 3,4,4,4 groups, respectively. 
res=calc_cond_prob(df, "exam_score >= 80 ~ age + height + weight + income", range_list=list( 3,4,4,4))

#the return is a list. We may further analyze the P(exam_score ≥ 80 | age) , P(exam_score ≥ 80 | height) and P(exam_score ≥ 80 | age and height)
shortSummary(res[[1]], "age + height ", combination=1)

#Use goodchance function to extract only those with the intereted range
lapply(res_list, goodchance, upper=0.7, lower=0.25)
