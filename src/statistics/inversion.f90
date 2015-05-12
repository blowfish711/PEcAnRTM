subroutine invert_basic(observed, inits, pmin, ngibbs, results)
    use mod_types
    use mod_statistics
    use mod_dataspec_wavelength
    implicit none

    ! Inputs
    real(kind=r2), intent(in) :: observed(nw,1), inits(6)
    integer(kind=i2), intent(in) :: ngibbs

    ! Internals
    integer(kind=i1) :: i, ng
    integer(kind=i1) :: nspec, npars, adapt
    real(kind=r2) :: rp1, rp2, rinv, rsd
    real(kind=r2) :: LRT(nw,2), PrevError(nw,size(observed,2)), PrevSpec(nw)
    real(kind=r2), dimension(size(inits)) :: Jump, ar, pmin
    real(kind=r1) :: adj_min

    ! Outputs
    real(kind=r2), intent(out) :: results(ngibbs, size(observed,2)+1)

    nspec = size(observed, 2)
    npars = size(inits)
    rp1 = 0.001 + nspec*nw/2
    rsd = 0.5
    print *, "Initial spec"
    call prospect_5b(inits(1), inits(2), inits(3), inits(4), inits(5), inits(6), LRT)
    PrevSpec = LRT(:,1)
    do i=1,nspec
        PrevError(:,i) = PrevSpec - observed(:,i)
    enddo
    Jump = inits * 0.05
    print *, Jump(1)
    adapt = 20
    adj_min = 0.1
    print *, "ngibbs= ", ngibbs
    do ng=1,ngibbs
    !if(BLAH)
    !    ! ----
    !    ! Adaptation goes here
    !    ! ----
    !endif
        print *, inits(1)
        call mh_sample(npars, inits, rsd, observed, nspec, &
                    Jump, pmin, PrevError, ar)

        results(ng,1:npars) = inits
        rp2 = 0.001 + sum(PrevError * PrevError)/2
        rinv = rgamma(rp1, 1/rp2)
        rsd = 1/sqrt(rinv)
        results(ng,npars+1) = rsd
    enddo
end subroutine
