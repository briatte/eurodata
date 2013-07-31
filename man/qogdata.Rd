\name{qogdata}
\alias{qogdata}
\title{qogdata - Import Quality of Government data into R}
\usage{
  qogdata(file = FALSE, replace = FALSE, path = "",
    version = "std", format = "cs", codebook = FALSE,
    variables = NULL, years = NULL, ...)
}
\arguments{
  \item{file}{a filename to save the dataset at. If set to
  \code{TRUE}, the name of the CSV dataset on the QOG
  server will be used. If set to \code{FALSE} (the
  default), the function only returns the link to the
  dataset. QOG datasets other than \code{std} require that
  \code{file} ends in \code{.dta}. QOG dataset \code{csyom}
  requires that \code{file} ends in \code{.csv}.}

  \item{replace}{whether to download the dataset even if a
  file already exists at the download location. Defaults to
  \code{FALSE}.}

  \item{path}{a folder path to append to the filename.}

  \item{version}{the QOG version: \code{std} (Standard),
  \code{soc} (Social Policy), \code{bas} (Basic) or
  \code{exp} (Expert). Defaults to \code{std}.}

  \item{format}{the QOG format, usually \code{cs} for
  cross-sectional data or \code{ts} for time series in the
  \code{std} and \code{bas} versions. QOG dataset
  \code{soc} requires \code{cs}, \code{tsl} (time series,
  long) or \code{tsw} (time series, wide). QOG dataset
  \code{exp} requires \code{cntry} (country-level) or
  \code{ind} (individual survey). If format is
  \code{csyom}, \code{version} must be \code{std} and
  \code{file} must be a CSV file. Defaults to \code{cs}.}

  \item{codebook}{whether to download the codebook. Calls
  \code{qogbook} by passing the \code{codebook},
  \code{version} and \code{path} arguments to it, where
  \code{codebook} is treated as the filename for the
  codebook. Defaults to \code{FALSE}.}

  \item{...}{other arguments supplied to the import method,
  which is `read.csv` by default, or
  \code{foreign::read.dta} if \code{file} is a Stata
  \code{dta} dataset, or \code{Hmisc::spss.get} if
  \code{file} is a SPSS \code{sav} dataset.}
}
\description{
  Function to download Quality of Government (QOG) data and
  load it as a data frame in R. Please visit the QOG
  Institute website at \link{http://www.qog.pol.gu.se/} for
  a presentation of QOG research.
}
\examples{
# Show the URL to the QOG Standard dataset.
qogdata()
# Download QOG Standard time series dataset and codebook.
qogdata(format = "ts", file = "qog.ts.csv", codebook = TRUE)
# Download selected years from the QOG Social Policy dataset.
QOG = qogdata(file = "qog-soc.dta", version = "soc", format = "tsl", years = 2002:2012)
# Download QOG Standard cross-section years of measurement.
QOG = qogdata(tempfile(fileext = ".csv"), format = "csyom")
# Display the years of measurements for the WDI Gini coefficient.
barplot(table(QOG$wdi_gini))
}
\author{
  Francois Briatte \email{f.briatte@ed.ac.uk}
}
\seealso{
  \code{\link{qogbook}}
}
