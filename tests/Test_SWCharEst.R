#-------------------------------------------------------------------------------------------------------------
# file: Test_SWCharEst.R
# Test of class SWCharEst.
# run:
#   Rscript Test_SWCharEst.R
#-------------------------------------------------------------------------------------------------------------

source( "../src/SWCharEst.R" )

AreClose <- function ( a, b, threshold )
{
	result <- TRUE
	if ( 1.0 + (a - b) - 1.0 != 0.0 )
	{
		if ( a != 0.0 )
		    result = ( abs ((a - b) / a) <= threshold )
		else if ( b != 0.0 )
		    result = ( abs ((a - b) / b) <= threshold )
	}
	return( result )
}

DisplaySWCharEst <- function ( name, values )
{
    message( "  ", name, ": WP, FC, thetaS, Ks = ",
	    signif( values[1], 4), ", ",
	    signif( values[2], 4), ", ",
	    signif( values[3], 4), ", ",
	    signif( values[4], 4) )
}

Compare <- function ( expected, results )
{
    passed <- AreClose( expected[1], results[1], 1.0e-4 ) &&
	      AreClose( expected[2], results[2], 1.0e-4 ) &&
	      AreClose( expected[3], results[3], 1.0e-4 ) &&
	      AreClose( expected[4], results[4], 1.0e-3 )
    if ( passed )
	message( "  passed" )
    else
	message( "  failed" )
}

Test1 <- function ()
{
    message( "\nTest: SWCharEst( 0.85, 0.04, 2.08 )" )

    # sand fraction, clay fraction, organic matter wt %
    soilTexture <- c( 0.85, 0.04, 2.08 )

    #             WP      FC       thetaS  Ks
    expected <- c( 0.0400, 0.09785, 0.4545, 0.003096 )

    swc <- SWCharEst()
    results <- swc$Get( soilTexture[1], soilTexture[2], soilTexture[3] )
    DisplaySWCharEst( "expected", expected )
    DisplaySWCharEst( "results ", results )
    Compare( expected, results )
}

Test2 <- function ()
{
    message( "\nTest: SWCharEst( 0.15, 0.18, 3.05 )" )

    # sand fraction, clay fraction, organic matter wt %
    soilTexture <- c( 0.15, 0.18, 3.05 )

    #            WP      FC       thetaS  Ks
    expected <- c( 0.1286, 0.33148, 0.5050, 0.000433 )

    swc <- SWCharEst()
    results <- swc$Get( soilTexture[1], soilTexture[2], soilTexture[3] )
    DisplaySWCharEst( "expected", expected )
    DisplaySWCharEst( "results ", results )
    Compare( expected, results )
}

# run now
SWCharEst()$Usage()
Test1()
Test2()
