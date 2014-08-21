library(GenABEL)
data(ge03d2ex)
# QC 1st round 
qc1 <- check.marker(ge03d2ex, p.level=0)
data1 <- ge03d2ex[qc1$idok, qc1$snpok]
data1 <- Xfix(data1)
attach(phdata(data1))
length(dm2) # (there are only 128 people left in the ’clean’ data set)
# QC 2nd round
data1.gkin <- ibs(data1[, autosomal(data1)], weight="freq")
data1.dist <- as.dist(0.5-data1.gkin)
data1.mds <- cmdscale(data1.dist)
# get outliers out
km <- kmeans(data1.mds, centers=2, nstart=1000)
cl1 <- names(which(km$cluster==1))
cl2 <- names(which(km$cluster==2))
if (length(cl1) > length(cl2)) {x<-cl2; cl2<-cl1; cl1<-x}
data2 <- data1[cl2, ]
mdta2 <- data2[41:nids(data2),]
mdf2 <- formetascore(bmi~sex+age,mdta2,transform=rntransform, verbosity = 2 )
save(mdf2,file="mdf2.RData")
# remove all the objects 
rm(list=ls()) 
