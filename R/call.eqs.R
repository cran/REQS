call.eqs <- function(EQSpgm, EQSmodel, serial, data = NA, datname = NA, LEN = 2000000)
{
  #EQSpgm ... EQS directory
  #EQSmodel ... path, where eqs-file is located
  #serial ... EQS serial number 
  #LEN ... Number of working array unit.  By default, it is 2,000,000 8 bytes units
  
  #--------- change working directory where eqs file is located ---------
  filedir.split <- strsplit(EQSmodel, "/")[[1]]
  n <- length(filedir.split) 
  filedir <- paste(filedir.split[1:(n-1)], collapse = "/")
  setwd(filedir)
  
  #--------- string specifications -----------
  outname <- strsplit(filedir.split[n], "\\.")[[1]][1]
  file.out <- paste(outname, ".out",sep = "" )
  
  lenstring <- paste("LEN=",as.integer(LEN), sep = "")
  filepathin <- paste("IN=", EQSmodel, sep = "")
  fileout <- paste("OUT=", file.out, sep = "")
  serstring <- paste("SER=", serial, "\n", sep = "")
  
  #----------- sanity check for input data ----------------
  if(length(data) > 1) {                              #write data matrix, to file.dat, blank separated
    if(is.na(datname)) {
      warning(paste("No filename for data specified! ",outname,".dat is used", sep = "")) 
      datname <- paste(outname,".dat", sep = "")
    }
    write.table(as.matrix(data), file = datname, col.names = FALSE, row.names = FALSE)
  }   
  
  
# IN=   input EQS command file (please note that input data is specified in the EQS command file)
# OUT=  EQS output file name

  EQScmd <- paste(EQSpgm, filepathin, fileout, lenstring, serial)
  
  RetCode <- system(EQScmd,intern = FALSE, ignore.stderr = TRUE, wait = TRUE, input = NULL,
      show.output.on.console = FALSE, minimized = FALSE, invisible = FALSE)
  
  return(RetCode)
}



