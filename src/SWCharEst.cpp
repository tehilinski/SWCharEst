//-----------------------------------------------------------------------------
// file		SWCharEst.h
// class	teh::SWCharEst
// brief 	Estimate values for wilting point, field capacity,
//		saturated water content, and saturated hydraulic conductivity
//		from soil texture and organic matter.
//		Output units are, respectively,
//		volume %, volume %, volume %, cm/sec.
//		Uses the equations from Saxton & Rawls, 2006.
//		Spreadsheet available at:
//		http://hydrolab.arsusda.gov/soilwater/Index.htm
// author	Thomas E. Hilinski <https://github.com/tehilinski>
// copyright	Copyright 2020 Thomas E. Hilinski. All rights reserved.
//		This software library, including source code and documentation,
//		is licensed under the Apache License version 2.0.
//		See the file "LICENSE.md" for more information.
//-----------------------------------------------------------------------------

#include "SWCharEst.h"
#include <cmath>
#include <iostream>
using std::cout;
using std::endl;

#undef DEBUG_SWCharEst
//#define DEBUG_SWCharEst


namespace teh {


void SWCharEst::Usage ()
{
    char const NL = '\n';
    cout << "\nUsage:" << NL
	 << "  teh::SWCharEst::Usage();" << NL
	 << "  teh::SWCharEst swc();" << NL
	 << "  std::vector<float> results = swc.Get( sand-fraction, clay-fraction, SOM-percent );" << NL
	 << "Arguments:" << NL
	 << "  sand-fraction = sand weight fraction (0-1)" << NL
	 << "  clay-fraction = clay weight fraction (0-1)" << NL
	 << "  SOM-percent   = soil organic matter (weight %)" << NL
	 << "Results:" << NL
	 << "  WP     = wilting point (volume %)" << NL
	 << "  FC     = field capacity (volume %)" << NL
	 << "  thetaS = saturated water content (volume %)" << NL
	 << "  Ks     = Saturated hydraulic conductivity (cm/sec)"
	 << endl;
}

bool SWCharEst::CheckArgs (
    float const sand,				// sand fraction (0-1)
    float const clay,				// clay fraction (0-1)
    float const ompc)				// organic matter wt %
{
    bool ok = true;
    if ( sand < 0.0f || sand > 1.0f )
	ok = false;
    if ( clay < 0.0f || clay > 1.0f )
	ok = false;
    if ( ompc < 0.0f || ompc > 70.0f )
	ok = false;
    if ( sand + clay > 1.0f )
	ok = false;
    return ok;
}

std::vector<float> & SWCharEst::Get (	// returns WP, FC, thetaS, Ks
    float const sand,			// sand fraction (0-1)
    float const clay,			// clay fraction (0-1)
    float const ompc)			// organic matter wt %
{
    results.resize(4);
    results.assign( 4, 0.0f );

    float const om = std::min ( 70.0f, ompc );		// upper limit OM%
    if ( !CheckArgs(sand, clay, om) )
	return results;

    float const theta1500t =
		-0.024f * sand + 0.487f * clay + 0.006f * om
		+ 0.005f * sand * om
		- 0.013f * clay * om
		+ 0.068f * sand * clay
		+ 0.031f;

    float theta1500 = std::max(
		0.01f,	// constrain
		theta1500t + 0.14f * theta1500t - 0.02f );

    float const theta33t =
		-0.251f * sand + 0.195f * clay + 0.011f * om
		+ 0.006f * sand * om
		- 0.027f * clay * om
		+ 0.452f * sand * clay
		+ 0.299f;

    float const theta33 = std::min(
		0.80f,	// constrain
		theta33t + 1.283f * theta33t * theta33t - 0.374f * theta33t - 0.015f);

    theta1500 = std::min( theta1500, 0.80f * theta33 );		// constrain

    float const thetaS33t =
		0.278f * sand + 0.034f * clay + 0.022f * om
		- 0.018f * sand * om
		- 0.027f * clay * om
		- 0.584f * sand * clay
		+ 0.078f;

    float const thetaS33 = thetaS33t + 0.636f * thetaS33t - 0.107f;

    float const thetaS = theta33 + thetaS33 - 0.097f * sand + 0.043f;

    float const B = 3.816713f / ( std::log(theta33) - std::log(theta1500) );

    float const lamda = 1.0f / B;

    float const Ks = 1930.0f * std::pow( ( thetaS - theta33 ), (3.0f - lamda) ) / 36000.0;

#ifdef DEBUG_SWCharEst
    char const NL = '\n';
    cout <<  "sand, clay, om = " << sand << " " << clay << " " << om << NL
	 << "theta1500t = " << theta1500t << NL
	 << "theta1500  = " << theta1500 << NL
	 << "theta33t   = " << theta33t << NL
	 << "theta33    = " << theta33 << NL
	 << "thetaS33t  = " << thetaS33t << NL
	 << "thetaS33   = " << thetaS33 << NL
	 << "thetaS     = " << thetaS << NL
	 << "B          = " << B << NL
	 << "lamda      = " << lamda << NL
	 << "Ks         = " << Ks << NL
	 << endl;
#endif

    results[0] = theta1500;	// WP
    results[1] = theta33;	// FC
    results[2] = thetaS;	// thetaS
    results[3] = Ks;		// Ks
    return results;
}


} // namespace teh
