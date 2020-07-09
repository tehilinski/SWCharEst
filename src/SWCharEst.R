#-------------------------------------------------------------------------------------------------------------
#' @file		SWCharEst.R
#'
#' @brief	R script:
#'		Estimate values for wilting point, field capacity,
#'		saturated water content, and saturated hydraulic conductivity
#'		from soil texture and organic matter.
#'		Output units are, respectively,
#'		volume fraction, volume fraction, volume fraction, cm/sec.
#'		Uses the equations from Saxton & Rawls, 2006.
#'		Spreadsheet available at:
#'		http://hydrolab.arsusda.gov/soilwater/Index.htm
#'
#' @author	Thomas E. Hilinski <https://github.com/tehilinski>
#' @copyright	Copyright 2020 Thomas E. Hilinski. All rights reserved.
#'		This software library, including source code and documentation,
#'		is licensed under the Apache License version 2.0.
#'		See the file "LICENSE.md" for more information.
#-------------------------------------------------------------------------------------------------------------
# Usage:
#	source("SWCharEst.R")       # load this file
#	SWCharEst()$Usage()          # display usage
#	SWCharEst()$Get( sandFraction, clayFraction, somPercent )
#
# Example - sand:
#   signif( SWCharEst()$Get( 0.85, 0.04, 2.08 ), digits=3 )
#       WP     FC thetaS     Ks
#   0.0400 0.0978 0.4540 0.0031
#
# Example - silt loam:
#   signif( SWCharEst()$Get( 0.15, 0.18, 3.05 ), digits=3 )
#         WP       FC   thetaS       Ks
#   0.129000 0.331000 0.505000 0.000433
#
# Example - Read tab-delimited file of %, calc, and save to CSV file:
#   source( "SWCharEst.R" )
#   data <- read.delim( "SoilTextures.txt", header=F )
#   str(data)                              # look at structure of data
#   options(digits=4, scipen=-2)           # set numeric format
#   summary(data)                          # statistical summary
#   data[,1] <- data[,1] * 0.01            # convert % to fraction
#   data[,2] <- data[,2] * 0.01            # convert % to fraction
#   swProps <- SWCharEst()$Get( data[,1], data[,2], data[,3] )
#   summary(swProps)                       # statistical summary
#   write.csv( swProps, "SoilWaterProperties.csv", row.names=F )
#-----------------------------------------------------------------------
# Following is for inclusion in a package:
# @export SWCharEst
# @exportClass SWCharEst
SWCharEst = setRefClass( "SWCharEst",
    methods = list(

	#' Displays the use of the class.
	#' @export
	Usage = function ()
	{
	    message( "\nUsage:" )
	    message( "  SWCharEst()$Usage()  # display usage" )
	    message( "  SWCharEst()$Get( sand-fraction, clay-fraction, SOM-percent )" )
	    message( "Arguments:" )
	    message( "  sand-fraction = sand weight fraction (0-1)" )
	    message( "  clay-fraction = clay weight fraction (0-1)" )
	    message( "  SOM-percent   = soil organic matter (weight %)" )
	    #message( "  Arguments can be a scalar or a vector of identical lengths." )
	    message( "Results:" )
	    message( "  WP     = wilting point (volume %)" )
	    message( "  FC     = field capacity (volume %)" )
	    message( "  thetaS = saturated water content (volume %)" )
	    message( "  Ks     = Saturated hydraulic conductivity (cm/sec)" )
	},

	# Check the arguments T if ok, else F if error
	# private
	CheckArgs = function (
	    sand,				# sand fraction (0-1)
	    clay,				# clay fraction (0-1)
	    ompc)				# organic matter wt %
	{
	    ok <- T
	    if ( any(sand < 0.0) | any(sand > 1.0) )
		ok <- F
	    if ( any(clay < 0.0) | any(clay > 1.0) )
		ok <- F
	    if ( any(ompc < 0.0) | any(ompc > 70.0) )
		ok <- F
	    if ( length(sand) != length(clay) | length(sand) != length(ompc) )
		ok <- F
	    if ( any( sand + clay > 1.0 ) )
		ok <- F
	    return( ok )
	},

	#' Returns a vector containing WP, FC, thetaS, Ks, in that order.
	#' @export
	Get = function (			# calc soil water properties
	    sand,				# sand fraction (0-1)
	    clay,				# clay fraction (0-1)
	    ompc,				# organic matter wt %
	    verbose=F)
	{
	    om = min ( 70.0, ompc );		# upper limit OM%
	    if ( verbose & length(sand) == 1 )
		message(paste( "sand, clay, om =", sand, clay, om ) )

	    if ( !CheckArgs( sand, clay, om ) )
	    {
		message( "\nSWCharEst: Invalid value found.")
		Usage ()
		return(NULL)
	    }

	    theta1500t <- (
		(-0.024) * sand + 0.487 * clay + 0.006 * om
		+ (0.005 * sand * om)
		- (0.013 * clay * om)
		+ (0.068 * sand * clay)
		+ 0.031 )
	    if (verbose)
		message("theta1500t = ", theta1500t)

	    theta1500 <- theta1500t + 0.14 * theta1500t - 0.02
	    theta1500 <- ifelse( (theta1500 <= 0.0), 1.0e-6, theta1500 )
	    if (verbose)
		message("theta1500 = ", theta1500)

	    theta33t <- (
		-0.251 * sand + 0.195 * clay + 0.011 * om
		+ 0.006 * sand * om
		- 0.027 * clay * om
		+ 0.452 * sand * clay
		+ 0.299 )
	    if (verbose)
		message("theta33t = ", theta33t)

	    theta33 <- ( theta33t + 1.283 * theta33t * theta33t - 0.374 * theta33t - 0.015 )
	    if (verbose)
		message("theta33 = ", theta33)

	    thetaS33t <- (
		0.278 * sand + 0.034 * clay + 0.022 * om
		- 0.018 * sand * om
		- 0.027 * clay * om
		- 0.584 * sand * clay
		+ 0.078 )
	    if (verbose)
		message("thetaS33t = ", thetaS33t)

	    thetaS33 <- ( thetaS33t + 0.636 * thetaS33t - 0.107 )
	    if (verbose)
		message("thetaS33 = ", thetaS33)

	    thetaS <- ( theta33 + thetaS33 - 0.097 * sand + 0.043 )
	    if (verbose)
		message("thetaS = ", thetaS)

	    B <- ( 3.816713 / ( log(theta33) - log(theta1500) ) )
	    if (verbose)
		message("B = ", B)

	    lamda <- 1.0 / B
	    if (verbose)
		message("lamda = ", lamda)

	    Ks <- 1930.0 * ( ( thetaS - theta33 ) ^ (3.0 - lamda) ) / 36000.0
	    if (verbose)
		message("Ks = ", Ks)

	    if ( length(sand) == 1 )
		results <- c( theta1500, theta33, thetaS, Ks )
	    else
		results <- data.frame( theta1500, theta33, thetaS, Ks )
	    names( results ) <- c("WP", "FC", "thetaS", "Ks")
	    return( results )
	} # Get

    ) # methods
) # setRefClass
