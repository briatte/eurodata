#' Panel data properties
#'
#' Function to check for panel data properties in a data frame. The syntax is
#' provided in the 'Details' of \code{\link{xtset}}. Intended for programming
#' purposes.
#'
#' @export
#' @param dataset the dataset in which to check for \code{xtdata} attributes.
#' @value an error if the data frame has no \code{xtdata} attributes, or 
#' \code{TRUE} if the data frame has an \code{xtdata} attribute that conforms 
#' to the syntax of \code{\link{xtset}}.
#' @seealso \code{\link{xtset}}
#' @examples
#' # Load QOG demo datasets.
#' data(qog.demo)
#' # Check xtdata attribute of QOG time series demo dataset.
#' xtdata(qog.ts.demo)
#' ## Unsuccessful checks send back an error (not run).
#' # xtdata(qog.cs.demo)

xtdata <- function(dataset) {
  if(is.null(attr(dataset, "xtdata")))
    stop("data frame has no xtdata attribute")
  all(sapply(xt(dataset), is.character)) &
    all(sapply(attr(dataset, "xtdata")$data[1:2], nchar) > 0) &
    all(sapply(attr(dataset, "xtdata")$spec[1:2], nchar) > 0)
}

#' Get panel data properties
#'
#' Function to extract the panel data properties of a data frame. The syntax is
#' provided in the 'Details' of \code{\link{xtset}}. Intended for programming
#' purposes.
#'
#' @export
#' @param dataset the dataset from which to return the \code{xtdata} attributes.
#' @value a list of \code{xtdata} attributes, if it exists.
#' @seealso \code{\link{xtset}}
#' @examples
#' # Load QOG demo datasets.
#' data(qog.demo)
#' # Identify the QOG Basic time series data properties.
#' xt(qog.ts.demo)

xt <- function(dataset) {
  x = attr(dataset, "xtdata")
  return(x)
}

#' Set panel data properties
#'
#' Function to specify the panel data properties of a data frame. The syntax is
#' provided in the 'Details'. Intended for country-year cross-sectional 
#' time series (CSTS) data, but should fit any panel data format.
#'
#' @export
#' @param dataset the panel data frame to set the attributes to.
#' @param data the \code{data} parameters to pass to the data:
#' unique identifier and time period, optionally followed by short and long 
#' observation names. 
#' Defaults to QOG country-year data settings. See 'Details'.
#' @param spec the \code{spec} parameters to pass to the data:
#' formats of unique identifier and time period, optionally followed by formats
#' of short and long observation names. 
#' Defaults to QOG country-year data settings. See 'Details'.
#' @param type the type of observations in the panel data. 
#' Defaults to \code{"country"}, which will read the \code{spec} parameters as
#' \code{\link{countrycode}} formats.
#' @param name a description of the dataset.
#' @param url a URI locator for the dataset (the website address).
#' @param quiet whether to return some details. Defaults to \code{FALSE} (verbose).
#' @details an \code{xtdata} attribute is a list of 5 to 11 panel data 
#' paramaters stored in the following named vectors: 
#' \itemize{
#'   \item \bold{data}, a vector of variable names coding for the unique 
#'   identifier and time period, optionally followed by the variable names for
#'   the short and long observation names, as with alphabetical country codes
#'   and country names.
#'   \item \bold{spec}, a vector of variable formats that match the \code{data} 
#'   variables; this allows to store \code{countrycode} formats in the dataset 
#'   and can theoretically work with any other format, like FIPS or households. 
#'   \item \bold{type}, a single-element vector that defines the type of 
#'   observations contained in the data; \code{"country"} is the only type that
#'   currently produces any specific behaviour from \code{xtdata}.
#'   \item \bold{name}, an optional single-element vector that defines the 
#'   dataset name, which is printed on top of the function results.
#'   \item \bold{url}, an optional URI locator for the data source (typically,
#'   where to find codebooks and publications).
#' }
#' These characteristics mimic the behaviour of the \code{xtset} and 
#' \code{label data} commands in Stata.
#' @value a data frame with the \code{xtdata} attribute.
#' @seealso \code{\link[countrycode]{countrycode}}
#' @examples
#' # Load QOG demo datasets.
#' data(qog.demo)
#' # Set xtdata attribute on QOG time series.
#' Q = xtset(qog.ts.demo)
#' # Set xtdata attribute on recent years.
#' Q.200x = xtset(subset(qog.ts.demo, year > 1999))
#' # Manually set xtdata attribute for UDS dataset.
#' UDS = get_uds()
#' UDS = xtset(UDS, 
#'             data = c("ccodecow", "year"), 
#'             spec = c("cown", "year"), 
#'             type = "country", 
#'             name = "Unified Democracy Scores"
#'     )

xtset <- function(dataset = NULL, 
                  data = c("ccode", "year", "ccodealp", "cname"), 
                  spec = c("iso3n", "year", "iso3c", "country.name"),
                  type = "country",
                  name = "Quality of Government, time series data",
                  url = "http://www.qog.pol.gu.se/",
                  quiet = FALSE) {
  if(!class(dataset) == "data.frame")
    warning("Untested with objects of class other than data.frame.")
  
  # set attributes
  attr(dataset, "xtdata") = list(
    data = data,
    spec = spec,
    type = type,
    name = name,
    url = url)
  
  if(!all(sapply(xt(dataset), is.character))) {
    stop("Invalid xtdata specification: all parameters must be character strings.")
  }
  xtcheck <- function(dataset, x, y = 0) {
    a = xt(dataset)[[x]]
    if(y > 0) a = a[y]
    if(is.null(a) | is.na(a) | !nchar(a))
      stop("Invalid xtdata specification: ", 
           ifelse(y > 0, 
                  paste0(ifelse(y == 1, "unit group", "time period"),
                         ifelse(x == "data", " variable", " format")),
                  x),
           " is missing, null or null-length.")
  }
  xtcheck(dataset, "type")
  xtcheck(dataset, "data", 1)
  xtcheck(dataset, "data", 2)
  xtcheck(dataset, "spec", 1)
  xtcheck(dataset, "spec", 2)
  if(!xtdata(dataset))
    stop("Invalid xtdata specification (please report this bug).")
  
  # print name
  if(!is.null(xt(dataset)$name) & !quiet)
    message(xt(dataset)$name)
  
  # print panel variable
  id = xt(dataset)$data[1]
  
  # enforce iso3n recommendation
  if(xt(dataset)$type == "country" & xt(dataset)$spec[1] == "iso3n")
    msg = "ISO-3166-1 numeric standard"
  else if (xt(dataset)$type == "country")
    msg = "possibly non-unique"
  else
    msg = "undefined coding scheme"
  if(!quiet)
    message("Panel variable: ", id, " (N = ", 
            length(unique(dataset[, id])), ", ",
            msg, ")")
  
  # print time variable
  time = xt(dataset)$data[2]
  r = range(dataset[, time], na.rm = TRUE)
  if(!quiet)
    message("Time variable: ", 
            time, 
            " (", r[1], "-", r[2], ", T = ", r[2] - r[1] + 1, ")" )
  return(dataset)
}

#' Try ISO-3N country code conversion on \code{xtdata} data frames
#' 
#' This function tests conversions to ISO3-N country codes on the country 
#' codes, acronyms and names identified in a data frame that carries the
#' \code{\link{xtdata}} attribute with the \code{country} type. Used by
#' \code{\link{xtmerge}}.
#' 
#' @export
#' @param dataset a data frame with the \code{\link{xtdata}} attribute. The 
#' \code{type} parameter must be set to \code{"country"}.
#' @value a vector of how many observations were successfully matched on their
#' country code, short country name and long country name, based on the 
#' variable names specified as \code{\link{xtdata}} properties.
#' @seealso \code{\link{xtdata}}, \code{\link{xtmerge}}
#' @author Francois Briatte \email{f.briatte@@ed.ac.uk}
#' @examples
#' ## Test the country identifiers in the QOG dataset (not run).
#' # data(qog.demo)
#' # xtcountry(qog.ts.demo)
#' ## Test the country identifiers in the UDS dataset (not run).
#' # UDS = get_uds()
#' # xtcountry(UDS)
xtcountry <- function(dataset) {
  stopifnot(xtdata(dataset))
  stopifnot(xt(dataset)$type == "country")
  data = xt(dataset)$data
  spec = xt(dataset)$spec
  countrytest <- function(x, y = NULL, data = NULL, spec = NULL) {
    if(is.na(data[x]) | is.na(spec[x]) | !data[x] %in% names(y)) {
      y = 0
    }
    else {
      y = sum(as.numeric(!is.na(countrycode(y[, data[x]], spec[x], "iso3n"))))
    }
    y
  }
  data = sapply(c(1, 3, 4), countrytest, y = dataset, data = data, spec = spec)
  names(data) = xt(dataset)$data[-2]
  return(data)
}

#' Merge \code{xtdata} data frames
#'
#' This function merges panel data based on their \code{"xtdata"} attributes.
#' 
#' @export
#' @param x, y data frames with the \code{\link{xtdata}} attribute. IF the 
#' \code{type} parameter must be set to \code{"country"}, the function will
#' try to resolve data frames with different country codes by matching them
#' to \code{iso3n} codes with the \code{\link{countrycode}} package.
#' @param t, t.x, t.y the time variable(s) by their names in the data frames.
#' Defaults to \code{"year"}, which propagates to \code{t.x} and \code{t.y}.
#' @param ... other methods passed to \code{\link{merge}}
#' @value a data frame
#' @seealso \code{\link{xtdata}}, \code{\link{merge}}
#' @author Francois Briatte \email{f.briatte@@ed.ac.uk}
#' @examples
#' # Load QOG demo datasets.
#' data(qog.demo)
#' # Load UDS democracy scores.
#' UDS = get_uds()
#' # Merge QOG and UDS time series.
#' xt(xtmerge(qog.ts.demo, UDS))
#' names(xtmerge(qog.ts.demo, UDS))

xtmerge <- function(x, y, t = "year", t.x = NULL, t.y = NULL, ...) {
  stopifnot(xtdata(x))
  stopifnot(xtdata(y))
  if(is.null(t.x)) t.x = t
  if(is.null(t.y)) t.y = t
  if(xt(x)$data[2] != t.x)
    stop("t.x different from xtdata time period of x")
  if(xt(y)$data[2] != t.y)
    stop("t.y different from xtdata time period of y")
  if(xt(x)$type != xt(y)$type)
    stop("different xtdata types")
  if(xt(x)$spec[2] != xt(y)$spec[2])
    stop("different xtdata time period formats")
  if(xt(x)$spec[1] != xt(y)$spec[1] & 
       xt(x)$type == "country" & 
       require(countrycode)) {
    warning("Different country code formats, merged on iso3n best matches.")
    mx = xtcountry(x)
    my = xtcountry(y)
    p = rbind(round(100 * mx / nrow(x)),
              round(100 * my / nrow(y)))
    rownames(p) = c("x", "y")
    # compare
    ox = order(mx, decreasing = TRUE)[1]
    oy = order(my, decreasing = TRUE)[1]
    x[, "iso3n"] <- countrycode(x[, xt(x)$data[ox]], xt(x)$spec[ox], "iso3n")
    y[, "iso3n"] <- countrycode(y[, xt(y)$data[oy]], xt(y)$spec[oy], "iso3n")
    x = xtset(x, 
              data = c("iso3n", xt(x)$data[-1]), 
              spec = c("iso3n", xt(x)$spec[-1]), 
              type = xt(x)$type, 
              name = xt(x)$name,
              quiet = TRUE)
    y = xtset(y, 
              data = c("iso3n", xt(y)$data[-1]), 
              spec = c("iso3n", xt(y)$spec[-1]), 
              type = xt(y)$type, 
              name = xt(y)$name,
              quiet = TRUE)
  }
  stopifnot(xt(x)$spec[1] == xt(y)$spec[1])
  d = merge(x, y, 
            by.x = c(xt(x)$data[1], xt(x)$data[2]),
            by.y = c(xt(y)$data[1], xt(y)$data[2]), ...)
  d = xtset(d, 
            data = xt(x)$data, 
            spec = xt(x)$spec,
            type = xt(x)$type,
            name = paste(xt(x)$name, xt(y)$name, sep = "/"))
  return(d)
}