# Introduction 
This package provides tools for determining conditional probabilities across defined ranges in any numeric data frame.

# Example
## Assume your data frame is named df

df <- data.frame(<br>
exam_score = c(85, 78, 90, 92, 70, 88, 95),
age = c(16, 17, 18, 19, 16, 17, 18),
height = c(150, 160, 165, 170, 155, 158, 172),
weight = c(45, 60, 62, 67, 50, 55, 68),
income = c(3000, 3200, 3500, 4000, 2600, 3100, 3900)
)

## Find P(exam_score ≥ 80 | age), where age is split into three groups.

calc_cond_prob(df, "exam_score >= 80 ~ age ", range_list=list( 3))

## Find P(exam_score ≥ 80 | age and height and weight and income), where their groups are split into 3,4,4,4 groups, respectively. The return is a list

res=calc_cond_prob(df, "exam_score >= 80 ~ age + height + weight + income", range_list=list( 3,4,4,4))

## Further analyze the P(exam_score ≥ 80 | age) , P(exam_score ≥ 80 | height) and P(exam_score ≥ 80 | age and height)

shortSummary(res[[1]], "age + height ", combination=1)

## Utilize the goodchance function to filter for values that fall within the specified range

lapply(res_list, goodchance, upper=0.7, lower=0.25)

## Advanced Use

calc_cond_prob(df, formula_string="lang_score >= 80 | math_score >= 80 ~ age + income",  range_list=list(3,4))

calc_cond_prob(df, formula_string="conditional_probability$lang_score >= 80 | conditional_probability$math_score >= 80 ~ age",  range_list=list(3))
