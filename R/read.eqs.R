# function for reading eqs-output files (*.ets) into R
# *.CBK and *.ETP file with meta information needed as well


read.eqs <- function(file)
{
# file ... the name or path (string) of the ets-file which the data are to be read from. If it does not contain an _absolute_ path,
#          the file name is _relative_ to the current working directory, 'getwd()'. The *.CBK and *.ETP file has to be of the
#          same name and in the same directory.
  
  file.ets <- file
  file.split <- strsplit(file.ets, "\\.")
  if (length(file.split[[1]]) > 2) stop("File name or folders should not contain '.'")
  if (file.split[[1]][2] != "ets") stop("File should be of the form 'xxxxxx.ets'")

  file.cbk <- paste(file.split[[1]][1], ".CBK",sep = "" )
  file.etp <- paste(file.split[[1]][1], ".ETP",sep = "" )

  cbk.info1 <- scan(file.cbk, skip = 2, nlines = 2, quiet = TRUE)   #read metainfo from cbk lines (first 4 lines)
  cbk.info2 <- scan(file.cbk, skip = 4, nlines = 2, quiet = TRUE)
  cbk.info.mat <- cbind(cbk.info2, cbk.info1)         #matrix of meta informations
  rownames(cbk.info.mat) <- c("Parameter estimates", "Standard errors", "Robust standard errors",
  "Corrected standard errors", "Gradients", "Sample covariance matrix", "Model Covariance Matrix (Sigma hat)",
  "Inverted Information matrix", "Robust inverted information matrix", "Corrected inverted information matrix",
  "First derivatives", "4th Moment weight matrix", "Standardized Elements", "R-squares", "Factor means",
  "Univariate statistics (means)", "Univariate statistics (standard deviations)", "Univariate statistics (skewness)",
  "Univariate statistics (kurtosis)", "Univariate statistics (sample size)", "Independent variable standardization vector",
  "Dependent variable standardization vector")
  colnames(cbk.info.mat) <- c("Line Number","Number of Elements")
  
  #contains the basic information only
  cbk.base <- read.fwf(file.cbk, widths = c(13, 3), skip = 6, col.names = c("variable", "line"), buffersize = 1, n = 98)        #data frame 

  #--------------- model info  ----------------------
  nminfo <- length(which(cbk.base[,2] == 2))                              #how many lines with model infos
  minfo.val <- scan(file.ets, skip = 1, nlines = 1, quiet = TRUE)
  minfo.dframe <- data.frame(minfo.val)
  colnames(minfo.dframe) <- "values"
  rownames(minfo.dframe) <- cbk.base[1:nminfo,1]                          #data frame with model infos
  #------------- end model info  --------------------
  
  #------------------ p-values ----------------------
  start.cbk <- nminfo + 1
  ntprobs <- length(c(which(cbk.base[,2] == 3), which(cbk.base[,2] == 4)))     #number of tail probabilites
  probs.val <- scan(file.ets, skip = 2, nlines = 2, quiet = TRUE)
  probs.val[which(probs.val == -1)] <- NA                            #-1 becomes NA
  probs.dframe <- data.frame(probs.val, row.names = cbk.base[start.cbk:(start.cbk+ntprobs-1),1])
  colnames(probs.dframe) <- "p-values"
  #--------------- end p-values ---------------------

  #---------------- fit indices/tests ---------------
  start.cbk <- start.cbk + ntprobs
  nfit <- 60
  fit.val <- scan(file.ets, skip = 4, nlines = 6, quiet = TRUE)
  fit.val[which(fit.val == -9)] <- NA
  fit.dframe <- data.frame(fit.val, row.names = cbk.base[start.cbk:(start.cbk+nfit-1),1])
  colnames(fit.dframe) <- "fit values"
  #-------------- end fit indices/tests -------------

  #----------------- descriptives -------------------
  start.cbk <- start.cbk + nfit
  ndesc <- 9
  desc.val <- scan(file.ets, skip = 11-1, nlines = 1, quiet = TRUE)    
  desc.dframe <- data.frame(desc.val, row.names = cbk.base[start.cbk:(start.cbk+ndesc-1),1])
  colnames(desc.dframe) <- "values"
  #---------------- end descriptives ----------------
  
  #-------------- parameter index matrices ----------
  n.ind <- desc.dframe[8,1]          #number of independent variables
  n.dep <- desc.dframe[9,1]          #number of dependent variables
  n.tot <- n.ind + n.dep
  if (n.ind%%32 == 0) {              #number of header lines to be skipped in .ETP
    skiplines <- n.ind/32            #21 elements per line (then new line)
  } else {
    skiplines <- trunc(n.ind/32)+1
  }

  if (n.dep%%32 == 0) {              #number of header lines to be skipped in .ETP
    skiplines <- skiplines + n.dep/32            #21 elements per line (then new line)
  } else {
    skiplines <- skiplines + trunc(n.dep/32)+1
  }
  
  parindvec <- scan(file.etp, skip = skiplines, quiet = TRUE)       #index vector from etp file
  varnames.string <- readLines(file.etp, n = skiplines)             #read variable names
  varnames.chvec <- unlist(strsplit(varnames.string, split =" "))
  varnames.vec <- varnames.chvec[which(varnames.chvec != "")]
  #------------ end parameter index matrices --------

  #-------------- read parameters and friends into list -----------
  nout <- dim(cbk.info.mat)[1]                                    #total number of outputs (22)
  model.list <- as.list(rep(NA, nout))                            #initialize list
  
  for (i in 1:nout) {
    startline <- cbk.info.mat[i,1]                                #starting line
    if (i != nout) {
      endlinevec <- cbk.info.mat[(i+1):nout,1]                    #avoid that next line is 0
      endline <- (endlinevec[endlinevec > 0])[1]                  #ending lines
      nlines <- endline-startline                                  #number of lines
    } else {                                                      #last element
      nlines <- 0
    }
  
    if (startline != 0) {
      vals <- scan(file.ets, skip = startline-1, nlines = nlines, quiet = TRUE)
    } else {                                                      #no output provided
      vals <- NA
    }
    model.list[[i]] <- vals                                       #write values into list
  } 
  #-------------------- end read values --------------------
  
  #-------------------- reorganize values into phi, gamma, beta ------------------
  par.val <- model.list[[1]]                                      #vector with parameter values
  
  par.pos <- which(parindvec > 0)                                 #cumulating parameter indices
  phi.dim <- n.ind*n.ind
  gamma.dim <- n.dep*n.ind
  indpos1 <- (par.pos > (phi.dim)) + (par.pos < (phi.dim+gamma.dim))
  cumpos1 <- par.pos[indpos1 == 2]                                #position for incrementing Gamma index
  cumpos2 <- par.pos[par.pos > (phi.dim+gamma.dim)]               #position for incrementing Beta matrix
  if (length(cumpos1) > 0)  parindvec[cumpos1] <- parindvec[cumpos1] + max(parindvec)
  if (length(cumpos2) > 0)  parindvec[cumpos2] <- parindvec[cumpos2] + max(parindvec)
  negpos <- which(parindvec == -1)                                #position of -1 values
  parindvec[parindvec <= 0] <- NA                                 #replace 0's and -1's by NA
  parvec <- par.val[parindvec]                                    #read parameter values
  parvec[negpos] <- -1                                            #plug-in -1's
  parvec[is.na(parvec)] <- 0                                      #plug in 0's
  
  cuts <- c(n.ind*n.ind, n.dep*n.ind, n.dep*n.dep)                #vector cut index for matrix re-organisation
  dimlist <- list(c(n.ind, n.ind), c(n.dep,n.ind), c(n.dep,n.dep))
  cutfac <- rep(1:3, cuts)                                        #list with parameter vectors
  parlist <- split(parvec, cutfac)                                #vector splitting
  parmat <- mapply(function(xx, dd) {                             #list of phi, gamma, beta matrices
                    matrix(xx, nrow = dd[1], ncol = dd[2], byrow = TRUE)
                   }, parlist, dimlist)
  names(parmat) <- c("Phi", "Gamma", "Beta")
  colnames(parmat$Phi) <- rownames(parmat$Phi) <- colnames(parmat$Gamma) <- varnames.vec[1:n.ind]
  rownames(parmat$Gamma) <- rownames(parmat$Beta) <- colnames(parmat$Beta) <- varnames.vec[(n.ind+1):length(varnames.vec)]        
  #-------------------- end phi, gamma, beta -------------------

 
  #----------------------se, rse, cse, gradient  ---------------------------
  parse.mat <- NULL
  for (i in 1:5) parse.mat <- cbind(parse.mat, model.list[[i]])
  colnames(parse.mat) <- c("Parameter", "SE", "RSE", "CSE", "Gradient")
  npar <- dim(parse.mat)[1]

  namesvec <- NULL
  for (i in 1:3) {
    if (i == 1) {                                                                  #Phi is symmetric
      combmat <- combinations(dim(parmat[[i]])[1], 2, repeats.allowed = TRUE)      #index matrix for name combinations
      comb.names <- apply(combmat, 2, function(rn) rownames(parmat[[i]])[rn])      #matrix with name combinations
      par.val0 <- parmat[[i]][lower.tri(parmat[[i]], diag = TRUE)]                 #parameter vector with 0's
    } else {                                                                       #gamma not symmetric
      comb.names <- as.matrix(expand.grid(rownames(parmat[[i]]), colnames(parmat[[i]])))
      par.val0 <- as.vector(parmat[[i]])  
    }
    par.val.ind <- which(((par.val0 != 0)+(par.val0 != -1)) == 2)
    names.mat <- rbind(comb.names[par.val.ind,])
    names <- apply(names.mat, 1, function(ss) paste("(",ss[1],",",ss[2],")", sep = ""))
    namesvec <- c(namesvec, names)
  }
  rownames(parse.mat) <- namesvec

  #------------------- end se, rse, cse, gradient --------------------------

  #----------------- covariance and information matrices -------------------
  meanjn <-  scan(file.cbk, skip = 1, nlines = 1, quiet = TRUE)[3]          #whether mean was computed or not
  depnames <- rownames(parmat$Beta)
  if (meanjn == 0) {                            
    p <- n.dep                                   #p is needed for derivatives
  } else {
    p <- n.dep + 1
    depnames <- c(depnames, "mean")          #needed for sigma hat dimnames  
  }

  cov.list <- as.list(rep(NA, 5))
  names(cov.list) <- c("sample.cov","sigma.hat","inv.infmat","rinv.infmat","cinv.infmat") 
  for (i in 6:10) {
    if (length(model.list[[i]]) > 1) {
      cov.list[[i-5]] <- matrix(model.list[[i]], nrow = sqrt(length(model.list[[i]])))
      if (i <= 7) dimnames(cov.list[[i-5]]) <- list(depnames, depnames)
      if (i >= 8) dimnames(cov.list[[i-5]]) <- list(namesvec, namesvec)
      }
  }
  #--------------- end covariance and information matrices -----------------
  
  #----------------------------- first derivatives -------------------------

  pstar <- p*(p+1)/2
  if (length(model.list[[11]]) > 1) {
    deriv1 <- matrix(model.list[[11]], nrow = npar, ncol = pstar)
  } else {
    deriv1 <- NA
  }
  #-------------------------- end first derivatives ------------------------

  #----------------------------- 4th moments -------------------------------
  if (length(model.list[[12]]) > 1) {
    moment4 <- matrix(model.list[[12]], nrow = pstar, ncol = pstar)
  } else {
    moment4 <- NA
  }
  #---------------------------- end 4th moments ----------------------------

  #--------------------------- univariate statistics -----------------------
  ustatmat <- cbind(model.list[[16]], model.list[[17]], model.list[[18]], model.list[[19]], model.list[[20]])
  if(dim(ustatmat)[1] == 1) ustatmat <- NA else colnames(ustatmat) <- c("means","sd","skewness","kurtosis","n")
  #-------------------------- end univariate statistics --------------------
  
  result <- c(list(model.info = minfo.dframe), list(pval = probs.dframe), list(fit.indices = fit.dframe), list(model.desc = desc.dframe),
              parmat, list(par.table = parse.mat), cov.list, list(derivatives = deriv1), list(moment4 = moment4),
              list(ssolution = model.list[[13]]), list(Rsquared = model.list[[14]]), list(fac.means = model.list[[15]]),
              list(var.desc = ustatmat), list(indstd = model.list[[21]]), list(depstd = model.list[[22]]))

  
  result
}
