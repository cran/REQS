run.eqs <- function(EQSpgm, EQSmodel, serial, data = NA, datname = NA, LEN = 2000000)
{
  res <- call.eqs(EQSpgm = EQSpgm, EQSmodel = EQSmodel, serial = serial, data = data, datname = datname, LEN = LEN)
  
  if (res == -1) warning("EQS estimation not successful!")
  
  filedir.split <- strsplit(EQSmodel, "/")[[1]]
  n <- length(filedir.split)
  etsname <- strsplit(filedir.split[n], "\\.")[[1]][1]
  etsfile <- paste(etsname, ".ets",sep = "" )
  
  reslist <- read.eqs(etsfile)
  return(reslist)
}

