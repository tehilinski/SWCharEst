/*! ----------------------------------------------------------------------------------------------------------
@file		SWCharEst.h
@class		teh::SWCharEst
@brief 		Estimate soil hydrologic properties from soil texture and organic matter.
@details {
		Estimate values for wilting point, field capacity,
		saturated water content, and saturated hydraulic conductivity
		from soil texture and organic matter.
		Output units are, respectively,
		volume %, volume %, volume %, cm/sec.
		Uses the equations from Saxton & Rawls, 2006.
		Spreadsheet available at: @n
		http://hydrolab.arsusda.gov/soilwater/Index.htm
}
@example {
	Example - sand:
	    SWCharEst( 0.85, 0.04, 2.08 )
	       WP       FC  thetaS         Ks
	    0.0400  0.09785  0.4545  0.0030959

	Example - silt loam:
	    SWCharEst( 0.15, 0.18, 3.05 )
	       WP       FC  thetaS         Ks
	    0.1286  0.33148  0.5050  0.0004327
}
@author		Thomas E. Hilinski <https://github.com/tehilinski>
@copyright	Copyright 2020 Thomas E. Hilinski. All rights reserved.
		This software library, including source code and documentation,
		is licensed under the Apache License version 2.0.
		See the file "LICENSE.md" for more information.
----------------------------------------------------------------------------------------------------------*/
#ifndef INC_teh_SWCharEst_h
#define INC_teh_SWCharEst_h

#include <vector>

namespace teh {


    class SWCharEst
    {
      public:

	SWCharEst ()
	  {
	  }

	/// Returns a vector containing WP, FC, thetaS, Ks, in that order.
	std::vector<float> & Get (
	    float const sand,			///< sand fraction (0-1)
	    float const clay,			///< clay fraction (0-1)
	    float const ompc);			///< organic matter wt %

	/// Returns a vector containing WP, FC, thetaS, Ks, in that order.
	std::vector<float> & Get (
	    std::vector<float> const & soil )	///< 3 soil values; sand, clay fractions, OM%
	{
	    // does not check vector size
	    return Get( soil[0], soil[1], soil[2] );
	}

	static void Usage ();

      private:

	std::vector<float> results;	// calculated WP, FC, thetaS, Ks

	bool CheckArgs (
	    float const sand,		// sand fraction (0-1)
	    float const clay,		// clay fraction (0-1)
	    float const ompc);		// organic matter wt %

	// not used
	SWCharEst (SWCharEst const & rhs);
	SWCharEst & operator= (SWCharEst const & rhs);

    };


} // namespace teh

#endif // INC_teh_SWCharEst_h
