
rm(list=ls())
library(chron)
library(plotly)

D = read.csv('Stadtlauf.csv', row.names = NULL, sep = '\t')
D = D[,c(1,2,3,4,5,6,7)]
C = unique(D$Country)
nC = length(C)

D1 = data.frame(Country = rep(0,nC), Runners = rep(0,nC), Tmin = chron(times = rep(0,nC)), Tmax = chron(times = rep(0,nC)), Tavg = chron(times = rep(0,nC)))
for(i in seq(1,nC)){
  t = chron(times = D[D$Country == C[i], c('Netto')])
  D1[i,'Country'] = as.character(C[i])  
  D1[i,'Runners'] = length(t)
  D1[i,c(3:5)] = chron(times = c(min(t),max(t),mean(t)))
}

D1 = D1[order(D1$Tavg),]

t = chron(times = D[, c('Netto')])
binSize = 2*IQR(t)/(dim(D)[1])^(1/3)
numBins = round((as.numeric(max(t))-as.numeric(min(t)))/binSize)

tMin = (hours(t)*3600 + minutes(t)*60 + seconds(t))/60
plot_ly(x = tMin, type = "histogram") %>%
  layout(xaxis = list(title = 'Half Marathon Time (min)'),
         yaxis = list(title = 'Number of Runners'))




F = sort(table(D$Country))
F20 = names(F[F>=20]) # countries with more than 19 runners
D2 = D[D$Country %in% F20,]
BoxP = data.frame(Country = as.character(D2$Country), Netto = chron(times = D2[, c('Netto')]))
BoxP$NettoSec  = hours(BoxP$Netto)*3600 + minutes(BoxP$Netto)*60 + seconds(BoxP$Netto)
boxplot((NettoSec/60)~Country, data=BoxP, outline = FALSE, horizontal = TRUE, las = 2
        , col = 'red', xlab = 'Half Marathon Time (min)', main = 'Countries with at least 20 runners')

V = sort(table(D$Verein), decreasing = TRUE)
V15 = names(V[V>=15]) # teams with more than 14 runners
V15 = V15[2:length(V15)]
D2 = D[D$Verein %in% V15,]
BoxP = data.frame(Verein = as.character(D2$Verein), Netto = chron(times = D2[, c('Netto')]))
BoxP$NettoSec  = hours(BoxP$Netto)*3600 + minutes(BoxP$Netto)*60 + seconds(BoxP$Netto)
boxplot((NettoSec/60)~Verein, data=BoxP, outline = FALSE, horizontal = TRUE, las = 2, col = 'blue',
        xlab = 'Half Marathon Time (min)', main = 'Teams with at least 15 runners')

DV = data.frame(Verein = rep(0,length(V15)), Runners = rep(0,length(V15)), Tavg = chron(times = rep(0,length(V15))))
for(i in seq(1,length(V15))){
  t = chron(times = D[D$Verein == V15[i], c('Netto')])
  DV[i,'Verein'] = as.character(V15[i])  
  DV[i,'Runners'] = length(t)
  DV[i,c(3)] = chron(times = mean(t))
}
DV$NettoMin = (hours(DV$Tavg)*3600 + minutes(DV$Tavg)*60 + seconds(DV$Tavg))/60
DV = DV[order(DV$NettoMin),]

colfunc = colorRampPalette(c("green", "red"))
pie(DV$Runners, labels = DV$Verein, col = colfunc(9), main = 'Speed (color) and number of runners (size) in teams with at least 15 runners')
