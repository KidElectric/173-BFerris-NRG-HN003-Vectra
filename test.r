args = commandArgs(trailingOnly=TRUE)
i = 0
start <- Sys.time() # get start time
for (arg in args){
    print(paste(i,arg))
    i = i + 1
}
stop <- Sys.time()
print(paste('Time elapsed:',(stop-start)/60,'minutes'))