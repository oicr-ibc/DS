library(GenABEL)
data(ge03d2c)
mdf3 <- formetascore(bmi~sex+age,ge03d2c,transform=rntransform, verbosity = 2 )
save(mdf3,file="mdf3.RData")
# remove all the objects 
rm(list=ls()) 
