// file:	Test_SWCharEst.cpp
// 		Test of class teh::SWCharEst
// build:
//	g++ -std=c++11 -g -Wall -I../src -o Test_SWCharEst Test_SWCharEst.cpp ../src/SWCharEst.cpp
// run:
//	./Test_SWCharEst

#include <iostream>
using std::cout;
using std::endl;
#include <vector>
#include <cmath>
#include "SWCharEst.h"
using teh::SWCharEst;

//	Returns true if fabs(a-b) / a <= threshold (a != 0)
//	or if fabs(a-b) / b <= threshold (b != 0)
//	or true if a = b = 0.
template
<
    typename T	///< floating-point type
>
inline bool AreClose (
	T const a, T const b, T const threshold )
{
	bool result = true;
	if ( 1.0f + (a - b) - 1.0f != 0.0f )
	{
		if ( a != 0.0f )
		    result = (std::fabs ((a - b) / a) <= threshold);
		else if ( b != 0.0f )
		    result = (std::fabs ((a - b) / b) <= threshold);
	}
	return result;
}

void DisplaySWCharEst (
    char const * const name,
    std::vector<float> const & values )
{
    cout << "  " << name << ": WP, FC, thetaS, Ks = "
	 << values[0] << ", "
	 << values[1] << ", "
	 << values[2] << ", "
	 << values[3] << endl;
}

void Compare (
    std::vector<float> const & expected,
    std::vector<float> const & results)
{
    bool passed = AreClose( expected[0], results[0], 1.0e-4f ) &&
		  AreClose( expected[1], results[1], 1.0e-4f ) &&
		  AreClose( expected[2], results[2], 1.0e-4f ) &&
		  AreClose( expected[3], results[3], 1.0e-3f );
    if ( passed )
	cout << "  passed" << endl;
    else
	cout << "  failed" << endl;
}

void Test1 ()
{
    cout << "Test: SWCharEst( 0.85, 0.04, 2.08 )" << endl;

    // sand fraction, clay fraction, organic matter wt %
    std::vector<float> const soilTexture = { 0.85, 0.04, 2.08 };

    //                                    WP      FC       thetaS  Ks
    std::vector<float> const expected = { 0.0400, 0.09785, 0.4545, 0.003096 };

    SWCharEst swc;
    std::vector<float> const results = swc.Get( soilTexture );
    DisplaySWCharEst( "expected", expected );
    DisplaySWCharEst( "results ", results );
    Compare( expected, results );
}

void Test2 ()
{
    cout << "Test: SWCharEst( 0.15, 0.18, 3.05 )" << endl;

    // sand fraction, clay fraction, organic matter wt %
    std::vector<float> const soilTexture = { 0.15, 0.18, 3.05 };

    //                                    WP      FC       thetaS  Ks
    std::vector<float> const expected = { 0.1286, 0.33148, 0.5050, 0.000433 };

    SWCharEst swc;
    std::vector<float> const results = swc.Get( soilTexture );
    DisplaySWCharEst( "expected", expected );
    DisplaySWCharEst( "results ", results );
    Compare( expected, results );
}

int main ()
{
    SWCharEst::Usage();
    Test1();
    Test2();
    return 0;
}
