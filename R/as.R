#' Transcode a vector into numeric.
#'
#' @param x A vector.
#'
#' @return A numeric vector.
#'
#' @export
#' @keywords internal
as_numeric <- function(x) {

  if (all(is.na(x))) {
    return(as.numeric(x))
  }

  if (any(class(x) %in% c("character", "factor")) == TRUE) {

    as_numeric <- stringr::str_match(x, "[\\d\\.,]+") %>%
      stringr::str_replace_all(",", ".") %>%
      as.numeric()

    return(as_numeric)
  }

  if (any(class(x) %in% c("Date", "POSIXct")) == TRUE) {
    return(lubridate::year(x))
  }

  if (any(class(x) == "logical") == TRUE) {

    as_numeric <- rep(NA, length(x)) %>%
      as.numeric()

    return(lubridate::year(x))
  }

  if (class(x) == "integer") {
    return(as.numeric(x))
  }

}

#' Transcode a vector into integer.
#'
#' @param x A vector.
#'
#' @return An integer vector.
#'
#' @export
#' @keywords internal
as_integer <- function(x) {

  if (all(is.na(x))) {
    return(as.numeric(x))
  }

  if (any(class(x) %in% c("character", "factor")) == TRUE) {

    as_integer <- stringr::str_match(x, "^(\\d+)") %>%
      .[, 2] %>%
      as.integer()

    return(as_integer)
  }

  if (any(class(x) %in% c("Date", "POSIXct")) == TRUE) {

    as_integer <- lubridate::year(x) %>%
      as.integer()

    return(as_integer)
  }

  if (any(class(x) == "logical") == TRUE) {

    as_integer <- rep(NA, length(x)) %>%
      as.integer()

    return(as_integer)
  }

  if (any(class(x) == "numeric") == TRUE) {
    return(as.integer(x))
  }
}

#' Transcode a vector into date.
#'
#' @param x A vector.
#'
#' @return A date vector.
#'
#' @export
#' @keywords internal
as_date <- function(x, origin = "1899-12-30") {

  as_date <- as.Date(rep(NA, length(x)))

  if (any(class(x) %in% c("character", "factor")) == TRUE) {

    position <- stringr::str_detect(x, "^\\d{5}(\\.0+)?$") %>% which()
    as_date[position] <- as.Date.numeric(as.integer(x[position]), origin)

    position <- stringr::str_detect(x, "^\\d{1,2}/\\d{1,2}/\\d{4}$") %>% which()
    as_date[position] <- as.Date(x[position], "%d/%m/%Y")

    position <- stringr::str_detect(x, "^\\d{1,2}/\\d{4}$") %>% which()
    as_date[position] <- as.Date(paste0("01/", x[position]), "%d/%m/%Y")

    position <- stringr::str_detect(x, "^\\d{1,2}/\\d{1,2}/\\d{2}$") %>% which()
    as_date[position] <- as.Date(x[position], "%d/%m/%y") %>%
      ifelse(. > lubridate::today(), . - 100 * 365.25, .) %>%
      lubridate::as_date()

    position <- stringr::str_detect(x, "^\\d{1,2}-\\d{1,2}-\\d{4}$") %>% which()
    as_date[position] <- as.Date(x[position], "%d-%m-%Y")

    position <- stringr::str_detect(x, "^\\d{1,2}-\\d{1,2}-\\d{2}$") %>% which()
    as_date[position] <- as.Date(x[position], "%d-%m-%y") %>%
      ifelse(. > lubridate::today(), . - 100 * 365.25, .) %>%
      lubridate::as_date()

    position <- stringr::str_detect(x, "^\\d{4}-\\d{1,2}-\\d{1,2}$") %>% which()
    as_date[position] <- as.Date(x[position])

    position <- stringr::str_detect(x, "^\\d{4}/\\d{1,2}/\\d{1,2}$") %>% which()
    as_date[position] <- as.Date(x[position])

    return(as_date)
  }

  if (any(class(x) %in% c("numeric", "integer")) == TRUE) {
    position <- stringr::str_detect(as.character(x), "^\\d{5}$") %>% which()
    as_date[position] <- as.Date.numeric(x[position], origin)

    return(as_date)
  }

  if (any(class(x) == "POSIXct") == TRUE) {
    return(as.Date.POSIXct(x))
  }

}

#' Transcode a character vector into an factor.
#'
#' An optional table data_levels contains ordered levels a colname. It contains at least three colmuns : colname, order, level.
#'
#' @param string A character vector.
#' @param data_levels An optional correpondance table between colnames and ordered levels.
#'
#' @return A ordered leveled factor.
#'
#' @export
#' @keywords internal
as_factor <- function(string, data_levels = NULL) {

  if (is.null(data_levels)) {
    string <- as.factor(string)
    return(string)
  }

  colname <- dplyr::enquo(string) %>%
    dplyr::quo_name()

  levels <- data_levels %>%
    dplyr::filter(colname == !!colname) %>%
    dplyr::arrange(ordre) %>%
    dplyr::pull(level)

  if (length(levels) != 0) {
    string <- factor(string, levels = levels)
  } else {
    string <- as.factor(string)
  }

  return(string)
}