\name{call.eqs}
\alias{call.eqs}

\title{Call EQS from R}
\description{This function calls an EQS script file (.eqs) and executes it. 
}
\usage{
call.eqs(EQSpgm, EQSmodel, serial, Rmatrix = NA, datname = NA, LEN = 2000000)

}
\arguments{
  \item{EQSpgm}{String containing path including program name where EQS is located (see details)}
  \item{EQSmodel}{String containing path where .eqs script file is located (see details)}
  \item{serial}{EQS serial number as character}
  \item{Rmatrix}{Optional matrix argument if data or covariances are stored in R}
  \item{datname}{If \code{data} is specified, a filename (string) must be provided for saving the data in text format (blank separated; see details)}
  \item{LEN}{Integer containing number of working array units. By default, it is 2000000 8 bytes units}
}
\details{If the path in \code{EQSpgm} and \code{EQSmodel} contains a blank, single quotes and double quotes
are required in argument. See \code{EQSpgm} argument in examples. The last statement in the \code{EQSpgm} argument refers 
to the name of the executable program file. Under Windows it is \code{".../WINEQS"} (referring to WINEQS.exe), under Mac \code{".../MACEQS"} and 
under Linux \code{".../EQS"}. When specifying the path, use slash instead of backslash. 

The .ETS, .CBK and .ETP files are written in the directory where the .eqs file is located. Unless 
another path is provided within in the .eqs script file. 

The argument \code{datname} must match with the input data specified in the corresponding .eqs file. 
}

\value{
Returns \code{TRUE} is the estimation was succesfully and \code{FALSE} otherwise. 
}

\references{Bentler, P. M. (1995). EQS Program Manual. Encino, CA: Multivariate Software Inc.}
\author{Patrick Mair, Eric Wu}

\seealso{\code{\link{read.eqs}}, \code{\link{run.eqs}}
}

\examples{

\dontrun{
##not executable, valid serial number has to be provided
res <- call.eqs(EQSpgm = "C:/Program Files/EQS61/WINEQS.EXE", 
                EQSmodel = "c:/eqs61/examples/manul7.eqs", serial = "1234")
}

}

\keyword{ utilities }

