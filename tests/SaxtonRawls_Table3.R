#-------------------------------------------------------------------------------------------------------------
# file: SaxtonRawls_Table3.R
#
# Use the soil textures from table 3 in Saxton and Rawls (2006)
# to produce estimates of WP, FC, thetaS, and Ks, and display
# the differences from table 3.
#
# run:
#   Rscript SaxtonRawls_Table3.R
#-------------------------------------------------------------------------------------------------------------

message( "\nComparison of SWCharEst estimates and Saxton and Rawls table 3" )

source( "../src/SWCharEst.R" )

#---- data from table 3 ----

soilTable3 <- list(
    ompc   = 2.5,
    sand   = c( 88, 80, 65, 40, 20, 10, 60, 30, 10, 10, 50, 25 ),			# weight %
    clay   = c(  5,  5, 10, 20, 15,  5, 25, 35, 35, 45, 40, 50 ),			# weight %
    WP     = c(  5,  5,  8, 14, 11,  6, 17, 22, 22, 27, 25, 30 ),			# volume %
    FC     = c( 10, 12, 18, 28, 31, 30, 27, 36, 38, 41, 36, 42 ),			# volume %
    thetaS = c( 46, 46, 45, 46, 48, 48, 43, 48, 51, 52, 44, 50 ),			# volume %
    Ks     = c( 108.1, 96.7, 50.3, 15.5, 16.1, 22.0, 11.3, 4.3, 5.7, 3.7, 1.4, 1.1 ) ) 	# mm/hour

#---- conversion factors ----

cf <- list( vf.to.vp = 100.0,
	    cmsec.to.mmhour = 36000.0 )

#---- make table of results from class SWCharEst ----

df <- data.frame( soilTable3$sand/100, soilTable3$clay/100, rep( soilTable3$ompc, length(soilTable3$sand) ) )
names(df) <- c("sand", "clay", "ompc")

varNames <- c( "WP", "FC", "thetaS", "Ks" )
est <- data.frame()
for ( i in 1:nrow(df) )
    est = rbind( est, SWCharEst()$Get( df$sand[i], df$clay[i], df$ompc[i] ) )
names(est) <- varNames
est$WP     <- round( est$WP * cf$vf.to.vp )
est$FC     <- round( est$FC * cf$vf.to.vp )
est$thetaS <- round( est$thetaS * cf$vf.to.vp )
est$Ks     <- round( est$Ks * cf$cmsec.to.mmhour, digits=1 )

disp.vec <- function( varName, values )
{
    print( paste( varName, ":", paste( values, collapse=", " ) ) )
}

message( "Differences in units of table 3:")
disp.vec( varNames[1], est$WP - soilTable3$WP )
disp.vec( varNames[2], est$FC - soilTable3$FC )
disp.vec( varNames[3], est$thetaS - soilTable3$thetaS )
disp.vec( varNames[4], signif( est$Ks - soilTable3$Ks, digits=3 ) )
