!-------------------------------------------------------------------------------------------------------------
!< @file	SWCharEst.f90
!<
!< @brief	class SWCharEst:
!<		Estimate values for wilting point, field capacity,
!<		saturated water content, and saturated hydraulic conductivity
!<		from soil texture and organic matter.
!<		Output units are, respectively,
!<		volume %, volume %, volume %, cm/sec.
!<		Uses the equations from Saxton & Rawls, 2006.
!<		Spreadsheet available at:
!<		http://hydrolab.arsusda.gov/soilwater/Index.htm
!<
!< @author	Thomas E. Hilinski <https://github.com/tehilinski>
!< copyright	Copyright 2020 Thomas E. Hilinski. All rights reserved.
!<		This software library, including source code and documentation,
!<		is licensed under the Apache License version 2.0.
!<		See the file "LICENSE.md" for more information.
!-------------------------------------------------------------------------------------------------------------

module SWCharEst
    implicit none

    public  :: Usage, Get
    private :: CheckArgs

    contains

	!< Displays the use of the class.
	subroutine Usage ()

	    print*, "Usage:"
	    print*, "   use SWCharEst"
	    print*, "   Get( sand-fraction, clay-fraction, SOM-percent )"
	    print*, "Arguments:"
	    print*, "   sand-fraction = sand weight fraction *,0-1"
	    print*, "   clay-fraction = clay weight fraction *,0-1"
	    print*, "   SOM-percent   = soil organic matter *,weight %"
	    print*, "Results:"
	    print*, "   WP     = wilting point *,volume %"
	    print*, "   FC     = field capacity *,volume %"
	    print*, "   thetaS = saturated water content *,volume %"
	    print*, "   Ks     = Saturated hydraulic conductivity *,cm/sec"

	end subroutine Usage

	function CheckArgs ( sand, clay, ompc ) result ( ok )

	    real, intent (in) :: sand, clay, ompc
	    logical :: ok

	    ok = .true.
	    if ( sand < 0.0 .or. sand > 1.0 ) then
		ok = .false.
	    end if
	    if ( clay < 0.0 .or. clay > 1.0 ) then
		ok = .false.
	    end if
	    if ( ompc < 0.0 .or. ompc > 70.0 ) then
		ok = .false.
	    end if
	    if ( sand + clay > 1.0 ) then
		ok = .false.
	    end if

	end function CheckArgs

	!< Returns a vector containing WP, FC, thetaS, Ks, in that order.
	!< sand fraction (0-1)
	!< clay fraction (0-1)
	!< organic matter wt %
	function Get ( sand, clay, ompc, DEBUG ) result ( results )

	    real, intent (in) :: sand, clay, ompc
	    logical, intent (in), optional :: DEBUG
	    real :: results(1:4)

	    real :: om, theta1500t, theta1500, theta33t, theta33, &
		    thetaS33t, thetaS33, thetaS, B, lamda, Ks
	    character :: NL =  NEW_LINE('a')

	    results = 0

	    om = min ( 70.0, ompc ) 				! upper limit OM%
	    if ( .not. CheckArgs(sand, clay, om) ) then
		return
	    end if

	    theta1500t = -0.024 * sand + 0.487 * clay + 0.006 * om &
			 + 0.005 * sand * om &
			 - 0.013 * clay * om &
			 + 0.068 * sand * clay &
			 + 0.031

	    theta1500 = max( 0.01, &				! constrain
			     theta1500t + 0.14 * theta1500t - 0.02 )

	    theta33t = -0.251 * sand + 0.195 * clay + 0.011 * om &
		       + 0.006 * sand * om &
		       - 0.027 * clay * om &
		       + 0.452 * sand * clay &
		       + 0.299

	    theta33 = min( &
			0.80, & 					! constrain
			theta33t + 1.283 * theta33t * theta33t - 0.374 * theta33t - 0.015 )

	    theta1500 = min( theta1500, &
			     0.80 * theta33 ) 		! constrain

	    thetaS33t = 0.278 * sand + 0.034 * clay + 0.022 * om &
			- 0.018 * sand * om &
			- 0.027 * clay * om &
			- 0.584 * sand * clay &
			+ 0.078

	    thetaS33 = thetaS33t + 0.636 * thetaS33t - 0.107

	    thetaS = theta33 + thetaS33 - 0.097 * sand + 0.043

	    B = 3.816713 / ( log(theta33) - log(theta1500) )

	    lamda = 1.0 / B

	    Ks = 1930.0 * ( thetaS - theta33 )**( 3.0 - lamda ) / 36000.0

	    if ( present(DEBUG) ) then
		if ( DEBUG ) then
		    print*, "sand, clay, om = ", sand, " ", clay, " ", om, NL, &
			    " theta1500t     = ", theta1500t, NL, &
			    " theta1500      = ", theta1500, NL, &
			    " theta33t       = ", theta33t, NL, &
			    " theta33        = ", theta33, NL, &
			    " thetaS33t      = ", thetaS33t, NL, &
			    " thetaS33       = ", thetaS33, NL, &
			    " thetaS         = ", thetaS, NL, &
			    " B              = ", B, NL, &
			    " lamda          = ", lamda, NL, &
			    " Ks             = ", Ks, NL
		end if
	    end if

	    ! "WP"  "FC"  "thetaS"  "Ks"
	    results = (/ theta1500, theta33, thetaS, Ks  /)

	end function Get

end module SWCharEst
