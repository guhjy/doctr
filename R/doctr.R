
## PROBLEMS ---------------------------------------------------------

#' Create message with problems found in x
#' 
#' @param x list with data, result, and any errors already found
#' @param name name of column referring to 'x'
problems_ <- function(x, name) {
  if (x$result) {
    return(paste0("No problems found in '", name, "'\n"))
  }
  
  msg <- paste0("Problems found in '", name, "'\n")
  for (i in 3:length(x)) {
    msg <- paste0(msg, "    ", x[[i]], "\n")
  }
  
  return(msg)
}

#' Print messages with problems found in 'X' (or in one of its columns)
#' 
#' @param X list of lists with data, result, and any errors already found for each column
#' @param i index of column from which to print problems
problems <- function(X, i = 0) {
  
  if (i != 0) {
    if(!is.numeric(i)) {
      i <- grep(i, names(X))
    }
    
    msg <- problems_(X[[i]], names(X)[i])
    message(stringr::str_sub(msg, 1, -2))
  }
  else {
    msg <- ""
    
    for (i in 1:length(X)) {
      msg <- paste0(msg, problems_(X[[i]], names(X)[i]))
    }
    message(stringr::str_sub(msg, 1, -2))
  }
}



## CHECKS -----------------------------------------------------------

#' Check if 'x$data' has length > 'len'
#' 
#' @param x list with data, result, and any errors already found
#' @param len minimum length 'x$data' can have
check_len <- function(x, len) {
  if (length(x$data) < len) {
    x$len <- "Data has length 0"
    x$result <- FALSE
  }
  
  return(x)
}

#' Check if 'x$data' is of type 'type'
#' 
#' @param x list with data, result, and any errors already found
#' @param type 'x$data' should have
check_type <- function(x, type) {
  if (typeof(x$data) != type) {
    x$type <- paste0("Data isn't of type ", type)
    x$result <- FALSE
  }
  
  return(x)
}

#' Check if fraction of 'x$data' that is NA is <= 'max_na'
#' 
#' @param x list with data, result, and any errors already found
#' @param max_na maximum fraction of 'x$data' that can be NA
#' @param rm_na whether NAs should be removed once test is over
check_na <- function(x, max_na, rm_na = FALSE) {
  if (sum(is.na(x$data))/length(x$data) > max_na) {
    x$na <- paste0("More than ", max_na*100, "% of entries are NAs")
    x$result <- FALSE
  }
  
  if (rm_na) {
    x$data <- x$data[!is.na(x$data)]
  }
  
  return(x)
}

#' Check if no entry of 'x$data' has more decimal places than 'mdp'
#' 
#' @param x list with data, result, and any errors already found
#' @param mdp maximum number of decimal places an entry in 'x$data' can have
check_mdp <- function(x, mdp) {
  dp <- stringr::str_length(stringr::str_extract(as.character(x$data), "\\.[0-9]*")) - 1
  dp[is.na(dp)] <- 0
  
  if (sum(dp > mdp) > 0) {
    x$mdp <- paste0(sum(dp > mdp), " entries have more than ", mdp, " decimal places")
    x$result <- FALSE
  }
  
  return(x)
}

#' Check if no entry of 'x$data' is larger than 'max_val'
#' 
#' @param x list with data, result, and any errors already found
#' @param max_val maximum value an entry in 'x$data' can have
check_max <- function(x, max_val) {
  if (sum(x$data > max_val) > 0) {
    x$max <- paste0(sum(x$data > max_val), " entries are larger than ", max_val)
    x$result <- FALSE
  }
  
  return(x)
}

#' Check if no entry of 'x$data' is smaller than 'min_val'
#' 
#' @param x list with data, result, and any errors already found
#' @param min_val maximum value an entry in 'x$data' can have
check_min <- function(x, min_val) {
  if (sum(x$data < min_val) > 0) {
    x$min <- paste0(sum(x$data < min_val), " entries are smaller than ", min_val)
    x$result <- FALSE
  }
  
  return(x)
}



## PRE-SET EXAMS ----------------------------------------------------

#' Check if 'x$data' is a continuous variable
#' 
#' @param x list with data, result, and any errors already found
#' @param min_val minimum value 'x$data' can have
#' @param max_val maximum value 'x$data' can have
#' @param max_na fraction of 'x$data' that can be NA
#' @param max_dec_places maximum number of decimal places in values of 'x$data'
#' 
#' @rdname is_continuous
is_continuous <- function(x, min_val = -Inf, max_val = Inf, max_na = 1.0, max_dec_places = Inf) {
  min_val <- as.numeric(min_val)
  max_val <- as.numeric(max_val)
  max_na <- as.numeric(max_na)
  max_dec_places <- as.numeric(max_dec_places)
  
  x <- x %>%
    check_len(0) %>%
    check_type("double") %>%
    check_na(max_na, TRUE) %>%
    check_mdp(max_dec_places) %>%
    check_max(max_val) %>%
    check_min(min_val)
  
  return(x)
}

#' Check if 'x$data' is a count variable
#'
#' @rdname is_continuous
is_count <- function(x, min_val = 0, max_val = Inf, max_na = 1.0, max_dec_places = 0) {
  is_continuous(x, min_val, max_val, max_na, max_dec_places)
}

#' Check if 'x$data' is a quantity variable
#'
#' @rdname is_continuous
is_quantity <- function(x, min_val = 0, max_val = Inf, max_na = 1.0, max_dec_places = Inf) {
  is_continuous(x, min_val, max_val, max_na, max_dec_places)
}

#' Check if 'x$data' is a percentage variable
#'
#' @rdname is_continuous
is_percentage <- function(x, min_val = 0, max_val = 1, max_na = 1.0, max_dec_places = Inf) {
  is_continuous(x, min_val, max_val, max_na, max_dec_places)
}

#' Check if 'x$data' is a money variable
#'
#' @rdname is_continuous
is_money <- function(x, min_val = 0, max_val = 10000, max_na = 1.0, max_dec_places = 2) {
  is_continuous(x, min_val, max_val, max_na, max_dec_places)
}



## RUNNING EXAMS ----------------------------------------------------

#' Run tests on a table to check if it fits it's expected form
#' 
#' @param X table to run tests on
#' @param exams tests to be run on 'X'
#' 
#' @export
diagnose <- function(X, exams) {
  exams[is.na(exams)] <- ""
  funs <- purrr::map(exams$funs, get)
  
  X <- exams %>%
    dplyr::mutate(
      data = purrr::map(exams[[1]], ~X[[.x]])
    ) %>%
    purrr::transpose() %>%
    purrr::map(function(arg) {
      arg$x <- list(data = arg$data, result = TRUE)
      arg$data <- NULL
      
      arg
    }) %>%
    purrr::map(~purrr::keep(.x, function(x) any(x != ""))) %>%
    purrr::map(function(x) {
      x$cols <- NULL
      x$funs <- NULL
      
      x
    })
  
  for (i in 1:length(funs)) {
    suppressWarnings(X[[i]] <- purrr::invoke(funs[[i]], X[[i]]))
  }
  names(X) <- exams[[1]]
  
  return(X)
}





