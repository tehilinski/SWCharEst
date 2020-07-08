!-------------------------------------------------------------------------------------------------------------
! file: Test_SWCharEst.f90
! Test of module SWCharEst.
! build:
!    gfortran -g -o Test_SWCharEst ../src/SWCharEst.f90 Test_SWCharEst.f90
! run:
!    ./Test_SWCharEst
!-------------------------------------------------------------------------------------------------------------

subroutine DisplaySWCharEst ( name, values )

    implicit none
    character (len = *) :: name
    real :: values(1:4)

    print*, "  ", name, ": WP, FC, thetaS, Ks = ", &
	    values(1), ", ",  &
	    values(2), ", ",  &
	    values(3), ", ",  &
	    values(4)

end subroutine DisplaySWCharEst

! Returns true if fabs(a-b) / a <= threshold (a != 0)
! or if fabs(a-b) / b <= threshold (b != 0)
! or true if a = b = 0.
function AreClose ( a, b, threshold ) result( isClose )

    implicit none
    real :: a, b, threshold
    logical :: isClose

    isClose = .true.
    if ( 1.0 + (a - b) - 1.0 .ne. 0.0 ) then
	    if ( a .ne. 0.0 ) then
		isClose = ( abs ((a - b) / a) .le. threshold )
	    else if ( b .ne. 0.0 ) then
		isClose = ( abs ((a - b) / b) .le. threshold )
	    end if
    end if

end function AreClose

subroutine Compare ( expected, results )

    implicit none
    real :: expected(1:4), results(1:4)
    logical :: AreClose, passed

    passed = AreClose( expected(1), results(1), 1.0e-4 ) .and. &
	     AreClose( expected(2), results(2), 1.0e-4 ) .and. &
	     AreClose( expected(3), results(3), 1.0e-4 ) .and. &
	     AreClose( expected(4), results(4), 1.0e-3 )

    if ( passed ) then
	print*, "  passed"
    else
	print*, "  failed"
    endif

end subroutine Compare


program Test_SWCharEst

    use SWCharEst

    call Usage()
    call Test1()
    call Test2()

    contains

	subroutine Test1 ()
	    ! Example - sand:

	    implicit none
	    ! sand fraction, clay fraction, organic matter wt %
	    real :: soilTexture(1:3) = (/ 0.85, 0.04, 2.08 /)
	    !                          WP      FC       thetaS  Ks
	    real :: expected(1:4) = (/ 0.0400, 0.09785, 0.4545, 0.003096 /)
	    real :: results(1:4)

	    print*, "Test: SWCharEst( 0.85, 0.04, 2.08 )"
	    results = Get( soilTexture(1), soilTexture(2), soilTexture(3) );
	    call DisplaySWCharEst( "expected", expected );
	    call DisplaySWCharEst( "results", results );
	    call Compare( expected, results )

	end subroutine Test1

	subroutine Test2 ()
	    ! Example - silt loam:

	    implicit none
	    ! sand fraction, clay fraction, organic matter wt %
	    real :: soilTexture(1:3) = (/ 0.15, 0.18, 3.05 /)
	    !                          WP      FC       thetaS  Ks
	    real :: expected(1:4) = (/ 0.1286, 0.33148, 0.5050, 0.000433 /)
	    real :: results(1:4)

	    print*, "Test: SWCharEst( 0.15, 0.18, 3.05 )"
	    results = Get( soilTexture(1), soilTexture(2), soilTexture(3) );
	    call DisplaySWCharEst( "expected", expected );
	    call DisplaySWCharEst( "results ", results );
	    call Compare( expected, results )

	end subroutine Test2

end program
