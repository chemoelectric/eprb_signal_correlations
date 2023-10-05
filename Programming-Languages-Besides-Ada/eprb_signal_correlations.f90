! This is free and unencumbered software released into the public domain.
!
! Anyone is free to copy, modify, publish, use, compile, sell, or
! distribute this software, either in source code form or as a compiled
! binary, for any purpose, commercial or non-commercial, and by any
! means.
!
! In jurisdictions that recognize copyright laws, the author or authors
! of this software dedicate any and all copyright interest in the
! software to the public domain. We make this dedication for the benefit
! of the public at large and to the detriment of our heirs and
! successors. We intend this dedication to be an overt act of
! relinquishment in perpetuity of all present and future rights to this
! software under copyright law.
!
! THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
! EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
! MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
! IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
! OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
! ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
! OTHER DEALINGS IN THE SOFTWARE.

program eprb_signal_correlations
  implicit none

  integer, parameter :: run_length = 1000000

  real, parameter :: pi     = atan (1.0) * 4.0
  real, parameter :: pi_2   = atan (1.0) * (4.0 / 2.0)
  real, parameter :: pi_3   = atan (1.0) * (4.0 / 3.0)
  real, parameter :: pi_4   = atan (1.0) * (4.0 / 4.0)
  real, parameter :: pi_6   = atan (1.0) * (4.0 / 6.0)
  real, parameter :: pi_8   = atan (1.0) * (4.0 / 8.0)
  real, parameter :: pi_180 = atan (1.0) * (4.0 / 180.0)
  real, parameter :: two_pi = atan (1.0) * (4.0 * 2.0)

  integer, parameter :: COUNTERCLOCKWISE = 1
  integer, parameter :: CLOCKWISE = 2

  integer, parameter :: CIRCLED_PLUS = 1
  integer, parameter :: CIRCLED_MINUS = 2

  type :: tagged_signal
     integer :: tau
     integer :: sigma
  end type tagged_signal

  integer, allocatable :: random_scalar_seed(:)

  call seed_random_scalars (random_scalar_seed)
  write (*, "()")
  call print_bell_tests (-pi_8)
  write (*, "()")
  call print_bell_tests (pi_8)
  write (*, "()")
  call print_bell_tests (-3 * pi_8)
  write (*, "()")
  call print_bell_tests (3 * pi_8)
  write (*, "()")

contains

  function assign_tag (zeta, sigma) result (taggedsig)
    real, intent(in) :: zeta
    integer, intent(in) :: sigma
    type(tagged_signal) :: taggedsig
    real :: r
    r = random_scalar ()
    select case (sigma)
    case (COUNTERCLOCKWISE)
       if (r < cos (zeta) ** 2) then
          taggedsig%tau = CIRCLED_PLUS
       else
          taggedsig%tau = CIRCLED_MINUS
       end if
    case (CLOCKWISE)
       if (r < sin (zeta) ** 2) then
          taggedsig%tau = CIRCLED_PLUS
       else
          taggedsig%tau = CIRCLED_MINUS
       end if
    end select
    taggedsig%sigma = sigma
  end function assign_tag

  subroutine collect_data (zeta1, zeta2, raw_data)
    real, intent(in) :: zeta1, zeta2
    type(tagged_signal), intent(out) :: raw_data(1:2, 1:run_length)
    integer :: i, sigma
    do i = 1, run_length
       if (random_scalar () < 0.5) then
          sigma = COUNTERCLOCKWISE
       else
          sigma = CLOCKWISE
       end if
       raw_data(1,i) = assign_tag (zeta1, sigma)
       raw_data(2,i) = assign_tag (zeta2, sigma)
    end do
  end subroutine collect_data

  function count_pairs (raw_data, sigma, tau1, tau2) result (n)
    type(tagged_signal), intent(in) :: raw_data(1:2, 1:run_length)
    integer, intent(in) :: sigma, tau1, tau2
    integer :: n
    integer :: i
    n = 0
    do i = 1, run_length
       if (raw_data(1,i)%sigma /= raw_data(2,i)%sigma) error stop
       if (raw_data(1,i)%sigma == sigma .and. &
            & raw_data(1,i)%tau == tau1 .and. &
            & raw_data(2,i)%tau == tau2) n = n + 1
    end do
  end function count_pairs

  function frequency (raw_data, sigma, tau1, tau2) result (freq)
    type(tagged_signal), intent(in) :: raw_data(1:2, 1:run_length)
    integer, intent(in) :: sigma, tau1, tau2
    real :: freq
    freq = real (count_pairs (raw_data, sigma, tau1, tau2)) / run_length
  end function frequency

  elemental function cosine_sign (phi) result (s)
    real, intent(in) :: phi
    real :: s
    if (cos (phi) < 0.0) then
       s = -1.0
    else
       s = 1.0
    end if
  end function cosine_sign

  elemental function sine_sign (phi) result (s)
    real, intent(in) :: phi
    real :: s
    if (sin (phi) < 0.0) then
       s = -1.0
    else
       s = 1.0
    end if
  end function sine_sign

  elemental function cc_sign (phi1, phi2) result (s)
    real, intent(in) :: phi1, phi2
    real :: s
    s = cosine_sign (phi1) * cosine_sign (phi2)
  end function cc_sign

  elemental function cs_sign (phi1, phi2) result (s)
    real, intent(in) :: phi1, phi2
    real :: s
    s = cosine_sign (phi1) * sine_sign (phi2)
  end function cs_sign

  elemental function sc_sign (phi1, phi2) result (s)
    real, intent(in) :: phi1, phi2
    real :: s
    s = sine_sign (phi1) * cosine_sign (phi2)
  end function sc_sign

  elemental function ss_sign (phi1, phi2) result (s)
    real, intent(in) :: phi1, phi2
    real :: s
    s = sine_sign (phi1) * sine_sign (phi2)
  end function ss_sign

  function estimate_rho_from_raw_data (raw_data, phi1, phi2) result (rho)
    type(tagged_signal), intent(in) :: raw_data(1:2, 1:run_length)
    real, intent(in) :: phi1, phi2
    real :: rho

    real :: ac2c2, ac2s2, as2c2, as2s2
    real :: cc2c2, cc2s2, cs2c2, cs2s2
    real :: c2c2, c2s2, s2c2, s2s2
    real :: cc, cs, sc, ss, c12, s12

    ac2c2 = frequency (raw_data, COUNTERCLOCKWISE, &
         &             CIRCLED_PLUS, CIRCLED_PLUS)
    ac2s2 = frequency (raw_data, COUNTERCLOCKWISE, &
         &             CIRCLED_PLUS, CIRCLED_MINUS)
    as2c2 = frequency (raw_data, COUNTERCLOCKWISE, &
         &             CIRCLED_MINUS, CIRCLED_PLUS)
    as2s2 = frequency (raw_data, COUNTERCLOCKWISE, &
         &             CIRCLED_MINUS, CIRCLED_MINUS)
    cs2s2 = frequency (raw_data, CLOCKWISE,        &
         &             CIRCLED_PLUS, CIRCLED_PLUS)
    cs2c2 = frequency (raw_data, CLOCKWISE,        &
         &             CIRCLED_PLUS, CIRCLED_MINUS)
    cc2s2 = frequency (raw_data, CLOCKWISE,        &
         &             CIRCLED_MINUS, CIRCLED_PLUS)
    cc2c2 = frequency (raw_data, CLOCKWISE,        &
         &             CIRCLED_MINUS, CIRCLED_MINUS)
    
    c2c2 = ac2c2 + cc2c2
    c2s2 = ac2s2 + cc2s2
    s2c2 = as2c2 + cs2c2
    s2s2 = as2s2 + cs2s2

    cc = cc_sign (phi1, phi2) * sqrt (c2c2)
    cs = cs_sign (phi1, phi2) * sqrt (c2s2)
    sc = sc_sign (phi1, phi2) * sqrt (s2c2)
    ss = ss_sign (phi1, phi2) * sqrt (s2s2)

    c12 = cc + ss
    s12 = sc - cs

    rho = (c12 * c12) - (s12 * s12)
  end function estimate_rho_from_raw_data

  function estimate_rho (phi1, phi2) result (rho)
    real, intent(in) :: phi1, phi2
    real :: rho
    type(tagged_signal), save :: data(1:2, 1:run_length)
    call collect_data (phi1, phi2, data)
    rho = estimate_rho_from_raw_data (data, phi1, phi2)
  end function estimate_rho

  subroutine print_bell_tests (delta_phi)
    real, intent(in) :: delta_phi
    integer :: i
    real :: phi1, phi2, phi1_, phi2_, rho_
    write (*, "('    φ₂ − φ₁ = ', F6.2)") delta_phi / pi_180
    do i = 0, 32
       phi1 = i * pi / 16.0
       phi2 = phi1 + delta_phi
       phi1_ = phi1 / pi_180
       phi2_ = phi1 / pi_180
       rho_ = estimate_rho (phi1, phi2)
       write (*, "('    φ₁ = ', F6.2, &
            & '°  φ₂ = ', F6.2, &
            & '°   ρ est. = ', F8.5)") &
            & phi1_, phi2_, rho_
    end do
  end subroutine print_bell_tests

  subroutine seed_random_scalars (seed)
    integer, allocatable, intent(inout) :: seed(:)
    integer :: seed_size
    call random_seed (size = seed_size)
    allocate (seed(seed_size))
    seed = 0
    call random_seed (put = seed)
  end subroutine seed_random_scalars

  function random_scalar () result (r)
    real :: r
    call random_number (r)
  end function random_scalar

end program eprb_signal_correlations
