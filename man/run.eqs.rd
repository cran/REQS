\name{run.eqs}
\alias{run.eqs}

\title{Run EQS from R}
\description{Calls an EQS script file from R, executes EQS, and imports the results into R. Basically
it is a wrapper function of \code{call.eqs} and the subsequent \code{read.eqs}.
}
\usage{
run.eqs(EQSpgm, EQSmodel, serial, Rmatrix = NA, datname = NA, LEN = 2000000)

}
\arguments{
  \item{EQSpgm}{String containing path where EQS is located (see details)}
  \item{EQSmodel}{String containing path where .eqs script file is located (see details)}
  \item{serial}{EQS serial number as integer value}
  \item{Rmatrix}{Optional matrix argument if data or covariances are stored in R}
  \item{datname}{If \code{data} is specified, a filename (string) must be provided for saving the data in text format (blank separated; see details)}
  \item{LEN}{Integer containing number of working array units. By default, it is 2000000 8 bytes units}
}
\details{If the path in \code{EQSpgm} and \code{EQSmodel} contains a blank, single quotes and double quotes
are required in argument. See \code{EQSpgm} argument in examples. The last statement in the \code{EQSpgm} argument refers 
to the name of the executable program file. Under Windows it is \code{".../WINEQS"} (referring to WINEQS.exe), under Mac \code{".../MACEQS"} and 
under Linux \code{".../EQS"}. When specifying the path, use slash instead of backslash. 

The .ETS, .CBK and .ETP files are written in the directory where the .eqs file is located. 
Note that these 3 files must be in the same directory than the .eqs file. 

The argument \code{datname} must match with the input data specified in the corresponding .eqs file. 
This option can be used for simulations: Generate data in R, \code{run.eqs()} on with the corresponding
\code{data} argument, pick out the relevant return values.

The value list below provides objects for the full EQS output. If in EQS some objects are not computed, the corresponding values in R are \code{NA}.
}

\value{Returns a list with the following objects:
  \item{success}{\code{TRUE} if estimation was successful, \code{FALSE} otherwise}
  \item{model.info}{General model information}
  \item{pval}{p-values for various test statistics}
  \item{fit.indices}{Variuos fit indices}
  \item{model.desc}{Descriptive measures}
  \item{Phi}{Phi matrix}
  \item{Gamma}{Gamma matrix}
  \item{Beta}{Beta matrix}
  \item{par.table}{Parameter table (with standard errors)}
  \item{sample.cov}{Sample covariance matrix}
  \item{sigma.hat}{Model covariance matrix}
  \item{inv.infmat}{Inverse information matrix}
  \item{rinv.infmat}{Robust inverse information matrix}
  \item{cinv.infmat}{Corrected inverse information matrix}
  \item{derivatives}{First derivatives}
  \item{moment4}{Matrix with 4th moments}
  \item{ssolution}{Standardized elements}
  \item{Rsquared}{R-squared measures}
  \item{fac.means}{Factor means}
  \item{var.desc}{Descriptive measures for the variables (univariate statistics)}
  \item{indstd}{Independent variable standardization vector}
  \item{depstd}{Dependent variable standardization vector}
}

\references{Bentler, P. M. (1995). EQS Program Manual. Encino, CA: Multivariate Software Inc.}
\author{Patrick Mair, Eric Wu}

\seealso{\code{\link{read.eqs}}, \code{\link{call.eqs}}
}

\examples{

\dontrun{
##not executable, valid serial number has to be provided
res <- run.eqs(EQSpgm = "C:/Program Files/EQS61/WINEQS.EXE", 
               EQSmodel = "c:/eqs61/examples/manul7.eqs", serial = "1234")

##For instance, to extract the parameter table you can do
res$par.table

##simulation example: not executable, provide serial number and proper eqs script file
##simulated 100 replications, extract CFI
cfivec <- NULL
for (i in 1:100) {
  X <- matrix(rnorm(1000), ncol = 10, nrow = 100)
  res <- run.eqs(EQSpgm = "C:/Program Files/EQS61/WINEQS.EXE", 
                 EQSmodel = "c:/eqs61/examples/manul7.eqs", data = X, 
                 datname = "manul7.dat", serial = "1234")
cfivec <- c(cfivec, res.run$fit.indices[9,])
}
}

}

\keyword{ utilities }

