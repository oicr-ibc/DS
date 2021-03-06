library(MetABEL)
load("mdf1.RData")
load("mdf2.RData")
load("mdf3.RData")
pooled <- metagwa.tables(mdf1,mdf2,name.x="Part1",name.y="Part2")
pooled <- metagwa.tables(pooled,mdf3,name.x="POOLED",name.y="mdf3")
save(pooled,file="pooled.RData")
rm(list=ls()) 

