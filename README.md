# Title
Tools for Conditional Probability

# Description 
Allow users to calculate conditional probabilities across defined ranges in any numeric data frame. Unlike general conditional probability packages that require numerical data to be converted into categorical data, this toolkit directly handles numerical data in various ranges, enabling the calculation of conditional probabilities without conversion. For example, I have a dataset named `df` that includes two numerical columns: `sleep_hour` and `age`. To find P( sleep_hour >= 8.5 l age), we typically need to categorize age into groups, such as "old," "middle-aged," and "young," in order to utilize the built-in functions in R. This package simplifies our task by handling this categorization internally. We can use the function `calc_cond_prob(df, "sleep_hour >= 8.5 ~ age", range_list=list(3))` to obtain the result.

## Installation

You can install `bcmaps` from CRAN:

``` r
install.packages("bcmaps")
```

# Example
## Sample Data
Assume your data frame is named df

df <- data.frame(<br>
&nbsp;&nbsp;exam_math_score = c(85, 78, 90, 92, 70, 88, 95),<br>
&nbsp;&nbsp;exam_lang_score = c(80, 88, 85, 82, 77, 68, 55),<br>
&nbsp;&nbsp;age = c(16, 17, 18, 19, 16, 17, 18),<br>
&nbsp;&nbsp;height = c(150, 160, 165, 170, 155, 158, 172),<br>
&nbsp;&nbsp;weight = c(45, 60, 62, 67, 50, 55, 68),<br>
&nbsp;&nbsp;income = c(3000, 3200, 3500, 4000, 2600, 3100, 3900)<br>
)

## Find P(exam_lang_score ≥ 80 | age) (EASY)
We find P(exam_lang_score ≥ 80 | age) in which age is split into three groups. Note that the return is a list which includes the output consists of a list containing [1] the results of the calculations, [2] a dataFrame of high and low odds extracted from the results, and [3] a range list used for the calculation. Note that outliners are removed.<br>

`calc_cond_prob(df, "exam_lang_score >= 80  ~ age ",  range_list=list(3))`

Sample Result<br>
| age | hit | total | odd
| -------- | -------- |-------- | -------- |
| 16:17   | 1   | 2 | 0.5 |
| 17:18  | 1   | 2 | 0.5 |
| 18:19  | 1   | 2 | 0.5 |

## Find P(exam_lang_score ≥ 80 | age) (SPECIFIC RANGE) 
We find P(exam_lang_score ≥ 80 | age) in which each age group is defined. Note that the return is a list. <br>

`calc_cond_prob(df, "exam_lang_score >= 80 ~ age ", range_list=list(c(16,16.5,17.5,18.5,19.5)))`

Sample Result<br>
| age | hit | total | odd
| -------- | -------- |-------- | -------- |
| 16:16.5   | 1   | 2 | 0.5 |
| 16.5:17.5 | 1   | 2 | 0.5 |
| 17.5:18.5  | 1   | 2 | 0.5 |
| 18.5:19.5  | 1   | 1 | 1.0 |

## Find P(exam_lang_score ≥ 80 | age and height and weight and income)
We find P(exam_lang_score ≥ 80 | age and height and weight and income), where their groups are split into 3,4,4,4 groups, respectively.<br>

`calc_cond_prob(df, "exam_lang_score >= 80 ~ age + height + weight + income", range_list=list( 3,4,4,4))`

| age | height | weight | income | hit | total | odd 
| -------- | -------- |-------- | -------- | -------- |-------- | -------- |
| 16:17   | 150:156.48    | 45:52.49| 2600:3049.7  |1 | 2 |0.5 |
| 17:18 | 	156.5:159.98   | 52.5:59.99 | 3050:3199.68 |0 | 1 |0.0 |
| 17:18  | 160:167.48   | 60:64.49 | 3200:3699.63 |1 | 1 |1.0 |
| 18:19  | 160:167.48   | 60:64.49 | 3200:3699.63 |1 | 1 |1.0 |

## Conduct a further analysis
Conduct a further analysis of the probabilities across all combinations of age and height.<br>
Below is for P(exam_lang_score ≥ 80 | age) , P(exam_lang_score ≥ 80 | height) and P(exam_lang_score ≥ 80 | age and height)<br>

`res=calc_cond_prob(df, "exam_lang_score >= 80 ~ age + height + weight + income", range_list=list( 3,4,4,4))`<br>
`shortSummary(res[[1]], "age + height ", combination=1)`

RESULT 1<br>
| age | hit | total | odd
| -------- | -------- |-------- | -------- |
| 16:17   | 1   | 2 | 0.5 |
| 17:18  | 1   | 2 | 0.5 |
| 18:19  | 1   | 1 | 1.0 |

Attention: The result P(exam_lang_score ≥ 80 | age) is different from the one of calc_cond_prob(df, "exam_lang_score >= 80  ~ age ",  range_list=list(3)) because it is derived from the result of calc_cond_prob(df, "exam_lang_score >= 80 ~ age + height + weight + income", range_list=list( 3,4,4,4)).

RESULT 2<br>
| height | hit | total | odd
| -------- | -------- |-------- | -------- |
| 150:156.48    | 1   | 2 | 0.5 |
| 156.5:159.98  | 0   | 2 | 0.5 |
| 160:167.48   | 2   | 1 | 1.0 |

RESULT 3<br>
| age | height | hit | total | odd
| -------- | -------- | -------- |-------- | -------- |
| 16:17  | 150:156.48    | 1   | 2 | 0.5 |
| 17:18  |156.5:159.98  | 0   | 1 | 0.0 |
| 17:18  | 160:167.48   | 1   | 1 | 1.0 |
| 18:19  | 160:167.48   | 1   | 1 | 1.0 |

## Filter out the result
Utilize the goodchance function to filter for values that fall within the specified range<br>

`res=calc_cond_prob(df, "exam_lang_score >= 80 ~ age + height + weight + income", range_list=list( 3,4,4,4))`<br>
`summary_result_list=shortSummary(res[[1]], "age + height ", combination=1)`<br>
`lapply(summary_result_list, goodchance, upper=0.7, lower=0.25)`<br>

RESULT 1<br>
| age | hit | total | odd
| -------- | -------- |-------- | -------- |
| 18:19  | 1   | 1 | 1.0 |


RESULT 2<br>
| height | hit | total | odd
| -------- | -------- |-------- | -------- |
| 160:167.48   | 2   | 1 | 1.0 |

RESULT 3<br>
| age | height | hit | total | odd
| -------- | -------- | -------- |-------- | -------- |
| 17:18  | 160:167.48   | 1   | 1 | 1.0 |
| 18:19  | 160:167.48   | 1   | 1 | 1.0 |

## Advanced Use

`calc_cond_prob(df, formula_string="exam_lang_score >= 80 | exam_math_score >= 80 ~ age + income",  range_list=list(3,4))`


## Licence

    # 
    # Licensed under the Apache License, Version 2.0 (the "License");
    # you may not use this file except in compliance with the License.
    # You may obtain a copy of the License at
    # 
    # http://www.apache.org/licenses/LICENSE-2.0
    # 
    # Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
    # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    # See the License for the specific language governing permissions and limitations under the License.

