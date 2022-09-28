\name{read.eqs}
\alias{read.eqs}

\title{Import of EQS outputs into R}
\description{This function reads EQS output files (.ets, .CBK and .ETP) into R and stores the results as objects.
}
\usage{
read.eqs(file)
}
\arguments{
  \item{file}{The name (string) of the .ets file or the full path which the data are to be read from. If it does not contain an absolute path, the file name is relative to the current working directory, 'getwd()'. A .CBK and .ETP file have to be of the same name and in the same directory.}
}
\details{The value list below provides objects for the full EQS output. If in EQS some objects are not computed, the corresponding values in R are \code{NA}.
}
\value{Returns a list with the following objects:

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
\references{Bentler, P. M. (2008). EQS Program Manual. Encino, CA: Multivariate Software Inc.}
\author{Patrick Mair, Eric Wu}

\seealso{\code{\link{call.eqs}}, \code{\link{run.eqs}}
}

\examples{

\dontrun{
##not executable
eqsout <- read.eqs("c:/home/user/eqs/eqsfile.ets")
}

}

\keyword{ utilities }

