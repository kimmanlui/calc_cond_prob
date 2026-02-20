library(dplyr)
# internal functions used for calc_cond_prob
#for calc_cond_prob
toCountListElement <- function(input_list) {
  # Map over each sub-list and create a sequence from 1 to its length
  lapply(input_list, function(x) seq_len(length(x)))
}

#for calc_cond_prob
gen_combination <- function(a) {
  # Use expand.grid to create all combinations of the list elements
  df <- expand.grid(a)

  # Convert to a data frame
  result_df <- as.data.frame(df)

  # Sort the data frame by all columns
  sorted_df <- result_df[do.call(order, result_df), ]

  # Reset the row numbers
  row.names(sorted_df) <- NULL

  return(sorted_df)
}

#for calc_cond_prob
adjust_equal_ranges <- function(range_ele) {
  lapply(range_ele, function(pair) {
    if (pair[1] == pair[2]) {
      pair[2] <- pair[2] + 1/10000
    }
    return(pair)
  })
}

#' @importFrom stats na.omit
#' @importFrom stats quantile
findBoundary= function (data, numGroup) {
    data=na.omit(data)
    boundary_list <- lapply(1:numGroup, function(i) {
    prob_lower <- (i - 1) / numGroup
    prob_upper <- i / numGroup
    c(lower = quantile(data, prob_lower), upper = quantile(data, prob_upper))
    })
    retList=list()
    for (i in 1:length(boundary_list))
    {
       retList[[i]]=c(round(as.numeric(boundary_list[[i]][1]),5), round(as.numeric(round(boundary_list[[i]][2]*9999/10000, 4)),5))
    }
    return (retList)
}
#findBoundary(clean_data$Weekday, 5)

#for calc_cond_prob
convert2Range=function( breaks=c( 1, 2, 3, 4,5))
{
    elelist=list()
    for (i in 1:(length(breaks)-1))
    {
        elelist[[i]]=c(breaks[i], breaks[i+1])
    }
    return(elelist)
}

#for calc_cond_prob
fixColonFormat=function(df, col_name='Weekday')
{
    for (i in 1:nrow(df))
    {
        ele=df[i, col_name]
        has_colon <- grepl(":", ele, fixed = TRUE)
        if (has_colon)
        {
          leftVal=strsplit(ele, ":")[[1]][1]
          rightVal=strsplit(ele, ":")[[1]][2]
          if (leftVal==rightVal) df[i, col_name]=leftVal
        }
    }
    return(df)
}

#' Filter Data Based on Odds
#'
#' @param df A data.frame containing the data to be evaluated. 
#'            The DataFrame must include the column specified by `col_name` containing odds values.
#' @param col_name A string representing the name of the column in the DataFrame that contains the odds values.
#'                 The default is 'odd', which means the function will look for an 'odd' column in the DataFrame.
#' @param upper A numeric threshold for the upper bound of the odds. 
#'              Rows with an 'odd' value greater than or equal to this threshold will be included in the output.
#'              The default value is 0.75.
#' @param lower A numeric threshold for the lower bound of the odds. 
#'              Rows with an 'odd' value less than or equal to this threshold and greater than 0 
#'              will also be included in the output. The default value is 0.25.
#' @return A filtered data.frame containing only the rows where the odds meet the specified conditions 
#'         (either above the upper threshold or below the lower threshold and greater than 0).
#' @export
#' @examples
#' df<-data.frame(exam_lang_score=c(80,88,85,82,34,34),age=c(6,7,8,6,7,8),height =c(5,6,6,7,5,7))
#' res=calc_cond_prob(df, "exam_lang_score >= 80 ~ age + height", range_list=list( 3,4))
#' summary_result_list=shortSummary(res[[1]], "age + height ", combination=1)
#' lapply(summary_result_list, goodchance, upper=0.7, lower=0.25)
goodchance=function(df, col_name='odd', upper=0.75, lower=0.25)
{
    return(df[ df$odd>=upper | (df$odd<=lower & df$odd>0), ])
}


#' Generate Short Summary of Grouped Data after the Output by calc_cond_prob
#'
#' @param df A data.frame containing the raw data to be summarized. 
#'            The DataFrame must include the columns specified in the `coln` parameter for grouping.
#' @param coln A comma-separated string of column names to be used for grouping in the summary. 
#'             Whitespace will be trimmed from the specified column names.
#'             For example: "Weekday, wkhwk.c.bp".
#' @param combination An integer indicating how to handle column combinations for the summary.
#'                    When set to 1, the function generates all possible combinations of the columns 
#'                    specified in `coln`. For any other value, only the specified columns will be used.
#' @return A list of data.frames containing the summarized results for each group based on the specified columns.
#'         Each data.frame will include the specified grouping columns, 
#'         the sum of hits (`hit_sum`), the sum of totals (`total_sum`), 
#'         and the calculated odds (`odd`).         
#' @return A list.
#' @export
#' @import dplyr
#' @importFrom utils combn
#' @examples
#' df<-data.frame(exam_lang_score=c(80,88,85,82,34,34),age=c(6,7,8,6,7,8),height =c(5,6,6,7,5,7))
#' res=calc_cond_prob(df, "exam_lang_score >= 80 ~ age + height", range_list=list( 3,4))
#' shortSummary(res[[1]], "age + height ", combination=1)
shortSummary <- function(df, coln = "Weekday , wkhwk.c.bp", combination=1) {
  hit <- NULL
  total <- NULL
  total_sum <- NULL
  hit_sum <- NULL
  if (!is.data.frame(df)) { stop("input must be data.frame")}
  coln=gsub("\\+", ",", coln)
  cols <- trimws(unlist(strsplit(coln, ",")))
  if (combination==1)
  {
     vec=cols
     all_combs <- do.call(c, lapply(1:length(vec), function(i) combn(vec, i, simplify = FALSE)))
     com_res=lapply(all_combs, paste, collapse = ", ")
  } else
  {
      com_res=list(cols)
  }
  #print(com_res)
  res_list=list()
  #return()
  for (i in 1:length(com_res))
  {

      cols_name_ele=com_res[[i]]
      cols_ele <- trimws(unlist(strsplit(cols_name_ele, ",")))
      #print(cols_ele)
      res=df %>%
        group_by(across(all_of(cols_ele))) %>%
        summarise(
         hit_sum = sum(hit, na.rm = TRUE),
         total_sum = sum(total, na.rm = TRUE),
         odd = round(ifelse(total_sum > 0, hit_sum / total_sum, NA_real_), 2),
         .groups = "drop"
       )
       names(res)=c(cols_ele, 'hit', 'total', 'odd')
       res_list[[i]]=as.data.frame(res)
    }
    return(res_list)
}

#' Calculate Conditional Probability
#'
#' @param clean_data A data.frame containing input data for analysis. 
#'                   It must include all variables referenced in `formula_string` and `col_name_list`.
#' @param formula_string An optional formula string in the format 'y ~ x1 + x2 + ...'.
#'                       This specifies the relationship between dependent and independent variables.
#'                       If provided, it determines the conditional evaluation and the list of column names. 
#' @param range_list A list of ranges or boundaries corresponding to each column in `col_name_list`.
#'                   This parameter is mandatory and must contain appropriate range definitions.
#' @param cond_evaluation An optional string for the conditional evaluation expression.
#'                        If not provided, it defaults to the left-hand side of `formula_string`.
#' @param col_name_list An optional list of column names for the analysis.
#'                      If not specified, it is derived from `formula_string`.
#' @param debug An integer indicating the debugging mode (0 = off, 1 = on). 
#'              When set to 1, additional output will be printed to help trace the computation steps.
#'
#' @return A list containing the results of the conditional probability calculation, 
#'         the good chance evaluation, and the adjusted range list.                                    
#' @export
#' @examples
#' df<-data.frame(exam_lang_score=c(80,88,85,82,34,34),age=c(6,7,8,6,7,8),height =c(5,6,6,7,5,7))
#' calc_cond_prob(df, "exam_lang_score >= 80  ~ age ",  range_list=list(3))
calc_cond_prob=function(clean_data, formula_string=NULL, range_list, cond_evaluation=NULL,  col_name_list=NULL,  debug=0)
{
    if (is.list(range_list)==FALSE) stop("range_list is mandatory. It must be a list type")

    if (!is.null(formula_string))
    {
        #print("Use formula_string")
        #formula_string <- "y ~ x1 + x2"
        parts <- strsplit(formula_string, "~")[[1]]
        lhs <- trimws(parts[1])
        rhs <- trimws(parts[2])
        if (is.null(cond_evaluation))
        {
            cond_evaluation=lhs
            if (debug==1) print(paste0("Use formula_string for cond_evaluation:", cond_evaluation))
        }
        if (is.null(col_name_list))
        {
            rhs_list <- strsplit(rhs, " *\\+ *")[[1]]
            col_name_list <-  trimws(rhs_list)
            col_name_list = as.list(col_name_list)
            if (debug==1) print(paste0("Use formula_string for col_name_list:", col_name_list))
        }
    }

    if (length(col_name_list)<length(range_list))
    {
        print(paste0('col_name_list is ',length(col_name_list),' and we will truncate(range_list)'))
        range_list=range_list[1: length(col_name_list)]
    }

    if (length(range_list)!=length(col_name_list)) stop('Error due to length(range_list)!=length(col_name_list)')

    for ( dx in  1:length(range_list))
    {
         #print(dx)
         my_var=range_list[[dx]]
         if (is.list(my_var)==TRUE)
         {
            if (debug==1) print("calling the function adjust_equal_ranges")
            range_list[[dx]]=adjust_equal_ranges(my_var)
         } else if (is.character(my_var) && length(my_var) == 1 && grepl("^auto", my_var))
         {
            if (debug==1) print("use auto conversion for auto")
            numGroup=gsub('auto', '', my_var)
            numGroup=as.numeric(numGroup)
            tempName=col_name_list[[dx]]
            range_list[[dx]]=findBoundary(clean_data[ , tempName], numGroup)
         } else if (is.numeric(my_var) && length(my_var) == 1)
         {
             if (debug==1) print("use auto conversion for single numeric")
             numGroup=my_var
             tempName=col_name_list[[dx]]
             tempdf=clean_data[ , tempName]
             range_list[[dx]]=findBoundary(tempdf , numGroup)
         } else if (is.numeric(my_var) && length(my_var) > 1)
         {
             if (debug==1) print("calling convert2Range")
             range_list[[dx]]=convert2Range(my_var)
         } else
         {
            stop(paste0("Please check range_list[[",dx,"]]"))
         }
    }
    #print(range_list)

    if (length(col_name_list[!col_name_list %in% names(clean_data)]) >= 1) {
        stop('Check col_name_list: One or more column names are not found in the input data (clean_data.)')
    }

    if (!grepl("conditional_probability\\$", cond_evaluation))
    {
        tokens <- regmatches(cond_evaluation, gregexpr("[a-zA-Z][a-zA-Z0-9._]*", cond_evaluation, perl = TRUE))[[1]]
        ftokens=paste0("conditional_probability$", tokens)
        for ( k in 1: length(tokens ))
        {
            if (!(tokens[k] %in% names(clean_data ))){ stop(paste0(tokens[k],' not found in any column names of input dataframe'))  }
            cond_evaluation=gsub( tokens[k], ftokens[k], cond_evaluation )
        }
    }


    if (debug==1) print (cond_evaluation)

    alst <- toCountListElement(range_list)
    com.df <- gen_combination(alst)
    if (is.vector(com.df))
    {
        com.df=data.frame(com.df)
    }
    results = NULL
    resultsIndex = NULL

    cond_list=list()
    for (icol in 1:length(col_name_list))
    {
        cond_col_name=col_name_list[[icol]]
        cond_list[[icol]]=gsub('COL_NAME', cond_col_name, 'range_list[[k]][[com.df[idx, k]]][1] <= COL_NAME & COL_NAME < range_list[[k]][[com.df[idx, k]]][2]')
    }
    #print(paste0('nrow(clean_data):',nrow(clean_data)))
    # Iterate over combinations
    for (idx in 1:nrow(com.df)) {

        conditional_probability = clean_data

        for (k in seq_along(cond_list)) {

            if (idx == 1 && debug==1) {
                print(cond_list[[k]])
                print(paste0(range_list[[k]][[com.df[idx, k]]][1],':',range_list[[k]][[com.df[idx, k]]][2]))
                print(parse(text = cond_list[[k]]))
            }
            # Safely evaluate the condition
            conditional_probability <- conditional_probability %>%
                filter(eval(parse(text = cond_list[[k]])))
            if (debug==1) print(paste0('nrow(conditional_probability):',nrow(conditional_probability)))
        }
        #print(conditional_probability)

        # Calculate hits and odds
        hit = sum(eval(parse(text = cond_evaluation)))
        total = nrow(conditional_probability)
        odd = ifelse(total != 0, round(hit / total, 2), 0)

        # Format the condition strings
        temp_df <- data.frame(dummy = 'dummy', stringsAsFactors = FALSE)
        for  (kk in seq_along(cond_list))
        {
            #print(kk)
            LowerRangeValue=round( range_list[[kk]][[com.df[idx, kk]]][1] , 2)
            UpperRangeValue=round( range_list[[kk]][[com.df[idx, kk]]][2] , 2)
            tmpSingle=data.frame(paste0(LowerRangeValue , ":", UpperRangeValue ))
            names(tmpSingle)= col_name_list[[kk]]
            temp_df=cbind(temp_df, tmpSingle)
        }
        temp_df$dummy=NULL
        temp_df
        if (total != 0) {

            result_temp_df_single=cbind(temp_df, data.frame(hit = hit, total = total, odd = odd))
            #result_index_temp_df_single=cbind(temp_df, data.frame(hit = hit, total = total, odd = odd))
            results <- rbind(results,result_temp_df_single)
            resultsIndex = rbind(results,result_temp_df_single)
            if (debug==1) print(result_temp_df_single)
        }
    }
    res=results
    if ('Weekday' %in% names(results))  res =fixColonFormat(results, 'Weekday')
    goodchanceRes=goodchance(res)
    return(list( results=res,  goodchance=goodchanceRes, range_list=range_list))
}
