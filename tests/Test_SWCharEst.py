#!python3
#-------------------------------------------------------------------------------------------------------------
# file: Test_SWCharEst.py
# Test of class SWCharEst.
# run:
#   python3 Test_SWCharEst.py
#-------------------------------------------------------------------------------------------------------------

import sys

exec(open("../src/SWCharEst.py").read())

def DisplaySWCharEst( name, values ):
    print( " ", name, ": WP, FC, thetaS, Ks =",
	    round( values[0], 4), ",",
	    round( values[1], 4), ",",
	    round( values[2], 4), ",",
	    round( values[3], 6) )

def AreClose ( a, b, threshold ):
    """
    Returns true if fabs(a-b) / a <= threshold (a != 0)
    or if fabs(a-b) / b <= threshold (b != 0)
    or true if a = b = 0.
    """
    result = True
    if ( 1.0 + (a - b) - 1.0 != 0.0 ):
        if ( a != 0.0 ):
            result = ( abs ((a - b) / a) <= threshold )
        elif ( b != 0.0 ):
            result = ( abs ((a - b) / b) <= threshold )
    return result

def Compare( expected, results ):
    passed = ( AreClose( expected[0], results[0], 1.0e-4 ) and
               AreClose( expected[1], results[1], 1.0e-4 ) and
               AreClose( expected[2], results[2], 1.0e-4 ) and
               AreClose( expected[3], results[3], 1.0e-3 ) )
    if ( passed ):
        print( "  passed" )
    else:
        print( "  failed" )

def Test1():
    """
    Example - sand:
    """
    print( "\nTest: SWCharEst( 0.85, 0.04, 2.08 )" )

    # sand fraction, clay fraction, organic matter wt %
    soilTexture = [ 0.85, 0.04, 2.08 ]
    #            WP      FC       thetaS  Ks
    expected = [ 0.0400, 0.09785, 0.4545, 0.003096 ]

    swc = SWCharEst()
    results = swc.Get( soilTexture[0], soilTexture[1], soilTexture[2] )
    results = list( results.values() )
    DisplaySWCharEst( "expected", expected );
    DisplaySWCharEst( "results ", results );
    Compare( expected, results );

def Test2():
    """
    Example - silt loam
    """
    print( "\nTest: SWCharEst( 0.15, 0.18, 3.05 )" )

    # sand fraction, clay fraction, organic matter wt %
    soilTexture = [ 0.15, 0.18, 3.05 ]
    #            WP      FC       thetaS  Ks
    expected = [ 0.1286, 0.33148, 0.5050, 0.000433 ]

    swc = SWCharEst()
    results = swc.Get( soilTexture[0], soilTexture[1], soilTexture[2] )
    results = list( results.values() )
    DisplaySWCharEst( "expected", expected );
    DisplaySWCharEst( "results ", results );
    Compare( expected, results );

def main():
    SWCharEst.Usage()
    Test1()
    Test2()

if __name__ == '__main__':
    main()
