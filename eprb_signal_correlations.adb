--********************************************************************
-- This is free and unencumbered software released into the public domain.
--
-- Anyone is free to copy, modify, publish, use, compile, sell, or
-- distribute this software, either in source code form or as a compiled
-- binary, for any purpose, commercial or non-commercial, and by any
-- means.
--
-- In jurisdictions that recognize copyright laws, the author or authors
-- of this software dedicate any and all copyright interest in the
-- software to the public domain. We make this dedication for the benefit
-- of the public at large and to the detriment of our heirs and
-- successors. We intend this dedication to be an overt act of
-- relinquishment in perpetuity of all present and future rights to this
-- software under copyright law.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
-- OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
-- ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--
-- For more information, please refer to <https://unlicense.org>
----------------------------------------------------------------------
-- A novel solution to a two-channel Bell test, by treating it as a
-- problem in random signal analysis, and a simulation based on the
-- solution.
--
-- Author: Barry Schwartz
-- Mastodon address: @ chemoelectric at masto.ai
-- Date completed: 4 Sept 2023
----------------------------------------------------------------------
--
-- The simulation is written in Ada. A free software Ada compiler is
-- widely available: GCC. Many readers can compile this program,
-- optimized and with runtime checks, by saving it in a file called
-- ‘eprb_signal_correlations.adb’ and then running the command
--
--   gnatmake -O2 -gnata eprb_signal_correlations
--
-- which will create an executable program called
-- ‘eprb_signal_correlations’.  Alternatively, translate the program
-- into the language of your choice.
--
----------------------------------------------------------------------

pragma ada_2022;
pragma wide_character_encoding (utf8);

with ada.assertions;
with ada.wide_wide_text_io;
with ada.containers;
with ada.containers.doubly_linked_lists;
with ada.numerics;
with ada.numerics.generic_elementary_functions;
with ada.numerics.generic_complex_types;

----------------------------------------------------------------------

procedure eprb_signal_correlations is

-- A ‘scalar’ is a double precision floating point number.
  type scalar is digits 15;

  subtype scalar_in_0_1 is scalar range 0.0 .. 1.0;
  subtype correlation_coefficient is scalar range -1.0 .. 1.0;

  use ada.assertions;
  use ada.wide_wide_text_io;
  use ada.numerics;
  use ada.containers;

  package scalar_elementary_functions is
    new ada.numerics.generic_elementary_functions (scalar);
  use scalar_elementary_functions;

  package scalar_io is new float_io (scalar);
  use scalar_io;

  π     : constant scalar := pi;
  π_2   : constant scalar := π / 2.0;
  π_3   : constant scalar := π / 3.0;
  π_4   : constant scalar := π / 4.0;
  π_6   : constant scalar := π / 6.0;
  π_8   : constant scalar := π / 8.0;
  π_180 : constant scalar := π / 180.0;
  two_π : constant scalar := 2.0 * π;

  subtype pair_range is integer range 1 .. 2;

----------------------------------------------------------------------

-- For the sake of reproducibility, let us write our own random number
-- generator. It will be a simple linear congruential generator. The
-- author has used one like it, in quicksorts and quickselects to
-- select the pivot. It is good enough for our purpose.

  type uint64 is mod 2 ** 64;

-- The multiplier lcg_a comes from Steele, Guy; Vigna, Sebastiano (28
-- September 2021). ‘Computationally easy, spectrally good multipliers
-- for congruential pseudorandom number generators’.
-- arXiv:2001.05304v3 [cs.DS]

  lcg_a : constant uint64 := 16#F1357AEA2E62A9C5#;

-- The value of lcg_c is not critical, but should be odd.

  lcg_c : constant uint64 := 1;

  seed  : uint64 := 0;

--
-- random_scalar: returns a non-negative scalar less than 1.
--
  function random_scalar
  return scalar_in_0_1
  with post => random_scalar'result < 1.0 is
    randval : scalar;
  begin
    -- Take the high 48 bits of the seed and divide it by 2**48.
    randval := scalar (seed / (2**16)) / scalar (2**48);

    -- Update the seed.
    seed := (lcg_a * seed) + lcg_c;

    return randval;
  end random_scalar;

----------------------------------------------------------------------

--
-- Assume there are two communications channels, which can carry one
-- of two orthogonal SIGNAL values, thus:
--

  type SIGNAL is ('↶', '↷');

--
-- Each channel assigns a TAG to its SIGNAL before delivering it to
-- the receiver. The TAG values are thus:
--

  type TAG is ('⊕', '⊖');

  type TAGGED_SIGNAL is
    record
      τ : TAG;
      σ : SIGNAL;
    end record;

--
-- The algorithm for assigning a tag depends upon a parameter ζ.
--

  function assign_TAG (ζ : scalar; σ : SIGNAL)
  return TAGGED_SIGNAL is
    r : constant scalar := random_scalar;
    τ : TAG;
  begin
    case σ is
      when '↶' => τ := (if r < cos (ζ) ** 2 then '⊕' else '⊖');
      when '↷' => τ := (if r < sin (ζ) ** 2 then '⊕' else '⊖');
    end case;
    return (τ => τ, σ => σ);
  end assign_TAG;

--
-- We would like to collect data on TAGGED_SIGNAL values received at
-- the terminuses of the two channels, when the same random signal is
-- sent over both channels.
--

  type TAGGED_SIGNAL_PAIR is array (pair_range) of TAGGED_SIGNAL;

  package TAGGED_SIGNAL_PAIR_LISTS is
    new ada.containers.doubly_linked_lists
      (element_type => TAGGED_SIGNAL_PAIR);

  function collect_data (ζ1, ζ2     : scalar;
                         run_length : count_type)
  return TAGGED_SIGNAL_PAIR_LISTS.list is
    use TAGGED_SIGNAL_PAIR_LISTS;
    data   : list := empty_list;
    σ      : SIGNAL;
    σ1, σ2 : TAGGED_SIGNAL;   
  begin
    for i in 1 .. run_length loop
      σ := (if random_scalar < 0.5 then '↶' else '↷');
      σ1 := assign_TAG (ζ => ζ1, σ => σ);
      σ2 := assign_TAG (ζ => ζ2, σ => σ);
      append (data, (σ1, σ2));
    end loop;
    return data;
  end collect_data;

----------------------------------------------------------------------
--
-- Before running a simulation, we MUST do a mathematical analysis of
-- this experiment. Otherwise we will not know what to do with the raw
-- data. So let us do the mathematics.
--
-- We will use subscripts to refer to channel numbers. Thus, for
-- instance, ‘ζ₂’ refers to the ζ parameter for channel 2, and ‘τ₁’ to
-- the TAG value for channel 1. Plain ‘τ’ without a subscript can
-- refer to either τ₁ or τ₂. And so on like that.
--
-- We will use more or less conventional probability notation. Thus,
-- for instance, ‘P(σ=↶ τ₁=⊖ | τ₂=⊖)’ refers to a joint probability of
-- certain values for σ and τ₁ conditional on a given value of τ₂.
--
-- To start with, we have
--
--    P(σ=↶) = ½
--    P(σ=↷) = ½
--
-- and some conditional probabilities are easily determined, as well
--
--    P(τ=⊕ | σ=↶ ζ=φ) = cos²(φ)
--    P(τ=⊖ | σ=↶ ζ=φ) = sin²(φ)
--    P(τ=⊕ | σ=↷ ζ=φ) = sin²(φ)
--    P(τ=⊖ | σ=↷ ζ=φ) = cos²(φ)
--
-- It is easy to get the probabilities of τ=⊕ and τ=⊖ individually,
-- and see that they are the constant ½.
--
--    P(τ=⊕ | ζ=φ) = P(σ=↶) P(τ=⊕ | σ=↶ ζ=φ) +
--                        P(σ=↷) P(τ=⊕ | σ=↷ ζ=φ)
--                 = ½ cos²(φ) + ½ sin²(φ) = ½
--
--    P(τ=⊖ | ζ=φ) = P(σ=↶) P(τ=⊖ | σ=↶ ζ=φ) +
--                        P(σ=↷) P(τ=⊖ | σ=↷ ζ=φ)
--                 = ½ sin²(φ) + ½ cos²(φ) = ½
--
-- Probability theory further tells us that
--
--    P(σ=↶ τ₁=⊕ τ₂=⊕ | ζ₁=φ₁ ζ₂=φ₂)
--         = P(σ=↶) P(τ₁=⊕ τ₂=⊕ | σ=↶ ζ₁=φ₁ ζ₂=φ₂)
--         = P(σ=↶) P(τ₁=⊕ | σ=↶ ζ₁=φ₁) P(τ₂=⊕ | σ=↶ ζ₁=φ₁ ζ₂=φ₂)
--         = P(σ=↶) P(τ₁=⊕ | σ=↶ ζ₁=φ₁) P(τ₂=⊕ | σ=↶ ζ₂=φ₂)
--
-- where in the last expression the ζ₁ parameter is removed from the
-- factor for the channel 2, because it plays no role in channel 2.
-- By the previous calculation and similar ones, the following table
-- can be constructed.
--
--    P(σ=↶ τ₁=⊕ τ₂=⊕ | ζ₁=φ₁ ζ₂=φ₂) = ½ cos²(φ₁) cos²(φ₂)
--    P(σ=↶ τ₁=⊕ τ₂=⊖ | ζ₁=φ₁ ζ₂=φ₂) = ½ cos²(φ₁) sin²(φ₂)
--    P(σ=↶ τ₁=⊖ τ₂=⊕ | ζ₁=φ₁ ζ₂=φ₂) = ½ sin²(φ₁) cos²(φ₂)
--    P(σ=↶ τ₁=⊖ τ₂=⊖ | ζ₁=φ₁ ζ₂=φ₂) = ½ sin²(φ₁) sin²(φ₂)
--    P(σ=↷ τ₁=⊕ τ₂=⊕ | ζ₁=φ₁ ζ₂=φ₂) = ½ sin²(φ₁) sin²(φ₂)
--    P(σ=↷ τ₁=⊕ τ₂=⊖ | ζ₁=φ₁ ζ₂=φ₂) = ½ sin²(φ₁) cos²(φ₂)
--    P(σ=↷ τ₁=⊖ τ₂=⊕ | ζ₁=φ₁ ζ₂=φ₂) = ½ cos²(φ₁) sin²(φ₂)
--    P(σ=↷ τ₁=⊖ τ₂=⊖ | ζ₁=φ₁ ζ₂=φ₂) = ½ cos²(φ₁) cos²(φ₂)
--
-- From that table, we easily get the following table of probabilities
-- of coincidence pairs.
--
--    P(τ₁=⊕ τ₂=⊕ | ζ₁=φ₁ ζ₂=φ₂) = ½ cos²(φ₁) cos²(φ₂) +
--                                       ½ sin²(φ₁) sin²(φ₂)
--    P(τ₁=⊕ τ₂=⊖ | ζ₁=φ₁ ζ₂=φ₂) = ½ cos²(φ₁) sin²(φ₂) +
--                                       ½ sin²(φ₁) cos²(φ₂)
--    P(τ₁=⊖ τ₂=⊕ | ζ₁=φ₁ ζ₂=φ₂) = ½ sin²(φ₁) cos²(φ₂) +
--                                       ½ cos²(φ₁) sin²(φ₂)
--    P(τ₁=⊖ τ₂=⊖ | ζ₁=φ₁ ζ₂=φ₂) = ½ sin²(φ₁) sin²(φ₂) +
--                                       ½ cos²(φ₁) cos²(φ₂)
--
-- Suppose we want to evaluate the correlation between τ₁ and τ₂ for
-- given ζ₁ and ζ₂. Mapping (τ=⊕)↦(τ′=+1) and (τ=⊖)↦(τ′=-1), we can
-- compute a correlation coefficient ρ. We will use the notation E(x)
-- to represent the expectation (average weighted by probabilities) of
-- x. Intuitively E(τ′)=0, and I will not belabor this page with the
-- calculation. Therefore the formula for ρ simplifies to
--
--    ρ = E(τ′₁τ′₂)/(√E((τ′₁)²) √E((τ′₂)²))
--
-- where the numerator is the covariance and the denominator is the
-- product of the standard deviations. The standard deviations are
-- trivial. Using P(τ=⊕ | ζ=φ) = P(τ=⊖ | ζ=φ) = ½, one gets
--
--    √E(τ′²) = √((+1)²(½) + (-1)²(½)) = 1
--
-- Thus ρ = E(τ′₁τ′₂). Expanding that gives
--
--    ρ = (+1)(+1) P(τ₁=⊕ τ₂=⊕ | ζ₁=φ₁ ζ₂=φ₂) +
--           (+1)(-1) P(τ₁=⊕ τ₂=⊖ | ζ₁=φ₁ ζ₂=φ₂) +
--              (-1)(+1) P(τ₁=⊖ τ₂=⊕ | ζ₁=φ₁ ζ₂=φ₂) +
--                 (-1)(-1) P(τ₁=⊖ τ₂=⊖ | ζ₁=φ₁ ζ₂=φ₂)
--      = cos²(φ₁) cos²(φ₂) - cos²(φ₁) sin²(φ₂)
--              - sin²(φ₁) cos²(φ₂) + sin²(φ₁) sin²(φ₂)
--      = (cos²(φ₂) - sin²(φ₂)) (cos²(φ₁) - sin²(φ₁))
--      = cos(2φ₂) cos(2φ₁)
--
-- And what we are going to do, right now, is plug in the Bell test
-- angles.
--
--    φ₁=0    φ₂=π/8       ρ=√½
--    φ₁=0    φ₂=3π/8      ρ=-√½
--    φ₁=π/4  φ₂=π/8       ρ=0
--    φ₁=π/4  φ₂=3π/8      ρ=0
--
-- This is a disappointing result—but we have computed the
-- expectations incorrectly. It is easy to overlook that one has
-- assumed a particular coordinate system, and that is what we have
-- done for the ζ settings. However, look at the answer we got: it
-- SHOULD be, but is not, in terms of φ₂-φ₁. It is not
-- coordinate-free. We should always have had an angular origin
-- written into our probabilities as another condition.
--
-- Therefore let us assume that condition implicitly written in, and
-- begin again exactly where we left off, but with the variables
-- renamed.
--
--    ρ′ = cos(2φ′₂) cos(2φ′₁)
--
-- Let φ′₁ be the angular origin and take on any value in [-π/4,π/4].
-- Compute the expectation
--
--        π/4                π/4
--    ρ = ∫ ρ′ φ′₁ = cos(2φ′₂) ∫ cos(2φ′₁) dφ′₁
--       -π/4               -π/4
--
--                                 = cos(2φ′₂) = cos²(φ′₂) - sin²(φ′₂)
--
-- Let φ′₂=(φ₂-φ₁)+δ, where δ is an arbitrary number. Thus a solution is
--
--    ρ = cos²(φ₂-φ₁) - sin²(φ₂-φ₁),  φ₁+δ ∈ [-π/4,π/4]
--
-- Because δ is arbitrary, we may drop the quadrant restriction and
-- write
--
--    ρ = cos²(φ₂-φ₁) - sin²(φ₂-φ₁) = cos(2(φ₂-φ₁))
--
-- which, finally, is a solution in the desired, coordinate-free form.
--
-- Plugging in the Bell test angles gives
--
--    φ₁=0    φ₂=π/8       ρ=√½
--    φ₁=0    φ₂=3π/8      ρ=-√½
--    φ₁=π/4  φ₂=π/8       ρ=√½
--    φ₁=π/4  φ₂=3π/8      ρ=√½
--
-- which is more satisfactory.
--
----------------------------------------------------------------------
--
-- It is certain that most quantum theorists seeking solutions to
-- similar problems via probability theory have neglected the last
-- step, where we integrated over a probability distribution function
-- of angular origins. The reason I say this with certainty is that
-- the solution above is proof that it is possible to violate Bell
-- inequalities with a ‘locally realistic’ model, and that Einstein,
-- Podolsky, and Rosen were correct.
--
-- Two questions immediately arise. One is why do experimenters get
-- Bell inequality violations, despite that they may have incorrect
-- formulas for their correlation calculations? This is a question for
-- which I have no answer. I am not in the least a scholar of the
-- experimental techniques employed.
--
-- The other question is how do Bell and others arrive at their
-- ‘inequalities’ in the first place? That question was answered at
-- least as early as [2] in the References section below. As Bell
-- explains at great length in his famous address [1], his argument
-- rests entirely on what we might call an ‘axiom of causality’. This
-- axiom states that if two random variables have no ‘causal
-- influence’ on each other then they are statistically
-- independent. It is easily demonstrated that this axiom makes
-- mathematics inconsistent, so that any proofs that follow (such as
-- Bell inequalities) are meaningless.
--
-- Suppose I mail a quartz to Fred Flintstone and a topaz to Barney
-- Rubble, or a quartz to Barney Rubble and a topaz to Fred
-- Flintstone. No matter how one writes expressions for them in
-- ordinary probability theory, the joint probabilities are
--
--    P(Fred-quartz Barney-quartz) = 0
--    P(Fred-quartz Barney-topaz)  = ½
--    P(Fred-topaz  Barney-quartz) = ½
--    P(Fred-topaz  Barney-topaz)  = 0
--
-- But suppose we add the ‘axiom of causality’ to the mix and use
-- that. Then we get
--
--    P(Fred-quartz Barney-quartz) = ¼
--    P(Fred-quartz Barney-topaz)  = ¼
--    P(Fred-topaz  Barney-quartz) = ¼
--    P(Fred-topaz  Barney-topaz)  = ¼
--
-- which yields the contradiction 0=¼=½. Thus Bell’s mathematics is
-- inconsistent, and all ‘Bell inequalities’ are meaningless.
--
-- Bell, of course, concludes he has contradicted the assumption that
-- the ‘causation’ in his axiom took place ‘locally’. But the fact
-- remains that, with his axiom in place, mathematics is inconsistent
-- and thus useless to prove ANYTHING.
--
----------------------------------------------------------------------

--
-- Back to the simulation. The data analysis follows the mathematics
-- derived above, and not anything you will find in the usual
-- Bell-test literature. That literature, we have found, is riddled
-- with faulty mathematics. It can be relied on for nothing.
--
-- Our methods will be very similar to those of reference [3],
-- although not identical. We substitute frequencies in the data for
-- probabilities in the closed-form analysis.
--

  function count (raw_data : TAGGED_SIGNAL_PAIR_LISTS.list;
                  σ        : SIGNAL;
                  τ1, τ2   : TAG)
  return count_type is
    use TAGGED_SIGNAL_PAIR_LISTS;
    n    : count_type := 0;
    curs : cursor := first (raw_data);
    pair : TAGGED_SIGNAL_PAIR;
  begin
    while has_element (curs) loop
      pair := element (curs);
      assert (pair(1).σ = pair(2).σ);
      if pair(1).σ = σ and pair(1).τ = τ1 and pair(2).τ = τ2 then
        n := n + 1;
      end if;
      curs := next (curs);
    end loop;
    return n;
  end count;

  function frequency (raw_data : TAGGED_SIGNAL_PAIR_LISTS.list;
                      σ        : SIGNAL;
                      τ1, τ2   : TAG)
  return scalar
  with post => 0.0 <= frequency'result and frequency'result <= 1.0 is
    use TAGGED_SIGNAL_PAIR_LISTS;
    n_total : count_type := length (raw_data);
  begin
    return (scalar (count (raw_data, σ, τ1, τ2)) / scalar (n_total));
  end frequency;

  function cosine_sign (φ : scalar)
  return scalar
  with post => cosine_sign'result = -1.0
                 or cosine_sign'result = 1.0 is
  begin
    return (if cos (φ) < 0.0 then -1.0 else 1.0);
  end cosine_sign;

  function sine_sign (φ : scalar)
  return scalar
  with post => sine_sign'result = -1.0 or sine_sign'result = 1.0 is
  begin
    return (if sin (φ) < 0.0 then -1.0 else 1.0);
  end sine_sign;

  function cc_sign (φ1, φ2 : scalar)
  return scalar
  with post => cc_sign'result = -1.0 or cc_sign'result = 1.0 is
  begin
    return cosine_sign (φ1) * cosine_sign (φ2);
  end cc_sign;

  function cs_sign (φ1, φ2 : scalar)
  return scalar
  with post => cs_sign'result = -1.0 or cs_sign'result = 1.0 is
  begin
    return cosine_sign (φ1) * sine_sign (φ2);
  end cs_sign;

  function sc_sign (φ1, φ2 : scalar)
  return scalar
  with post => sc_sign'result = -1.0 or sc_sign'result = 1.0 is
  begin
    return sine_sign (φ1) * cosine_sign (φ2);
  end sc_sign;

  function ss_sign (φ1, φ2 : scalar)
  return scalar
  with post => ss_sign'result = -1.0 or ss_sign'result = 1.0 is
  begin
    return sine_sign (φ1) * sine_sign (φ2);
  end ss_sign;

  function estimate_ρ (raw_data : TAGGED_SIGNAL_PAIR_LISTS.list;
                       φ1, φ2   : scalar)
  return correlation_coefficient is
    ac2c2, ac2s2 : scalar;
    as2c2, as2s2 : scalar;
    cc2c2, cc2s2 : scalar;
    cs2c2, cs2s2 : scalar;
    c2c2, c2s2   : scalar;
    s2c2, s2s2   : scalar;
    cc, cs       : scalar;
    sc, ss       : scalar;
    c12, s12     : scalar;
    ρ_estimate   : scalar;
  begin
    -- P(σ=↶ τ₁=⊕ τ₂=⊕ | ζ₁=φ₁ ζ₂=φ₂) = ½ cos²(φ₁) cos²(φ₂)
    ac2c2 := frequency (raw_data, '↶', '⊕', '⊕');
    -- P(σ=↶ τ₁=⊕ τ₂=⊖ | ζ₁=φ₁ ζ₂=φ₂) = ½ cos²(φ₁) sin²(φ₂)
    ac2s2 := frequency (raw_data, '↶', '⊕', '⊖');
    -- P(σ=↶ τ₁=⊖ τ₂=⊕ | ζ₁=φ₁ ζ₂=φ₂) = ½ sin²(φ₁) cos²(φ₂)
    as2c2 := frequency (raw_data, '↶', '⊖', '⊕');
    -- P(σ=↶ τ₁=⊖ τ₂=⊖ | ζ₁=φ₁ ζ₂=φ₂) = ½ sin²(φ₁) sin²(φ₂)
    as2s2 := frequency (raw_data, '↶', '⊖', '⊖');
    -- P(σ=↷ τ₁=⊕ τ₂=⊕ | ζ₁=φ₁ ζ₂=φ₂) = ½ sin²(φ₁) sin²(φ₂)
    cs2s2 := frequency (raw_data, '↷', '⊕', '⊕');
    -- P(σ=↷ τ₁=⊕ τ₂=⊖ | ζ₁=φ₁ ζ₂=φ₂) = ½ sin²(φ₁) cos²(φ₂)
    cs2c2 := frequency (raw_data, '↷', '⊕', '⊖');
    -- P(σ=↷ τ₁=⊖ τ₂=⊕ | ζ₁=φ₁ ζ₂=φ₂) = ½ cos²(φ₁) sin²(φ₂)
    cc2s2 := frequency (raw_data, '↷', '⊖', '⊕');
    -- P(σ=↷ τ₁=⊖ τ₂=⊖ | ζ₁=φ₁ ζ₂=φ₂) = ½ cos²(φ₁) cos²(φ₂)
    cc2c2 := frequency (raw_data, '↷', '⊖', '⊖');

    -- cos²(φ₁) cos²(φ₂)
    c2c2 := ac2c2 + cc2c2;
    -- cos²(φ₁) sin²(φ₂)
    c2s2 := ac2s2 + cc2s2;
    -- sin²(φ₁) cos²(φ₂)
    s2c2 := as2c2 + cs2c2;
    -- sin²(φ₁) sin²(φ₂)
    s2s2 := as2s2 + cs2s2;

    -- cos(φ₁) cos(φ₂)
    cc := cc_sign (φ1, φ2) * sqrt (c2c2);
    -- cos(φ₁) sin(φ₂)
    cs := cs_sign (φ1, φ2) * sqrt (c2s2);
    -- sin(φ₁) cos(φ₂)
    sc := sc_sign (φ1, φ2) * sqrt (s2c2);
    -- sin(φ₁) sin(φ₂)
    ss := ss_sign (φ1, φ2) * sqrt (s2s2);

    -- cos(φ1 - φ2) = cos(φ₁) cos(φ₂) + sin(φ₁) sin(φ₂)
    c12 := cc + ss;
    -- sin(φ1 - φ2) = sin(φ₁) cos(φ₂) - cos(φ₁) sin(φ₂)
    s12 := sc - cs;

    ρ_estimate := (c12 * c12) - (s12 * s12);

    return scalar'min (1.0, scalar'max (-1.0, ρ_estimate));
  end estimate_ρ;

----------------------------------------------------------------------

begin
  declare
    φ1, φ2 : scalar;
    ρ_est  : correlation_coefficient;
  begin
    for i in 0 .. 31 loop
      φ1 := scalar (i) * π / 16.0;
      φ2 := φ1 - π_8;
      ρ_est := estimate_ρ (collect_data (φ1, φ2, 1e6), φ1, φ2);
      put ("   φ1 = ");
      put (φ1 / π_180, 3, 2, 0);
      put ("   φ2 = ");
      put (φ2 / π_180, 3, 2, 0);
      put ("   ρ est. = ");
      put (ρ_est, 2, 5, 0);
      new_line;
    end loop;
    new_line;
    for i in 0 .. 31 loop
      φ1 := scalar (i) * π / 16.0;
      φ2 := φ1 + π_8;
      ρ_est := estimate_ρ (collect_data (φ1, φ2, 1e6), φ1, φ2);
      put ("   φ1 = ");
      put (φ1 / π_180, 3, 2, 0);
      put ("   φ2 = ");
      put (φ2 / π_180, 3, 2, 0);
      put ("   ρ est. = ");
      put (ρ_est, 2, 5, 0);
      new_line;
    end loop;
    new_line;
    for i in 0 .. 31 loop
      φ1 := scalar (i) * π / 16.0;
      φ2 := φ1 - (3.0 * π_8);
      ρ_est := estimate_ρ (collect_data (φ1, φ2, 1e6), φ1, φ2);
      put ("   φ1 = ");
      put (φ1 / π_180, 3, 2, 0);
      put ("   φ2 = ");
      put (φ2 / π_180, 3, 2, 0);
      put ("   ρ est. = ");
      put (ρ_est, 2, 5, 0);
      new_line;
    end loop;
    new_line;
    for i in 0 .. 31 loop
      φ1 := scalar (i) * π / 16.0;
      φ2 := φ1 + (3.0 * π_8);
      ρ_est := estimate_ρ (collect_data (φ1, φ2, 1e6), φ1, φ2);
      put ("   φ1 = ");
      put (φ1 / π_180, 3, 2, 0);
      put ("   φ2 = ");
      put (φ2 / π_180, 3, 2, 0);
      put ("   ρ est. = ");
      put (ρ_est, 2, 5, 0);
      new_line;
    end loop;
  end;
end eprb_signal_correlations;

----------------------------------------------------------------------
--
-- Afterword.
--
-- Of course, John S. Bell and others have at last been awarded a
-- Nobel Prize, precisely for inventing and using their inconsistent
-- mathematics, and for calculating their correlation coefficients
-- incorrectly. What actually will happen now is that quantum
-- physicists will continue to use inconsistent mathematics, and also
-- will continue to leave probability distribution functions out of
-- their expectation calculations. We will get no return to the
-- classical approach, such as I demonstrated here using the
-- engineering techniques of signal processing analysis. We will
-- continue to get very little progress towards a deeper understanding
-- of our universe—if we do not, in fact, slip considerably backwards.
-- ‘Quantum’ madness seems to be infecting electrical engineering
-- itself more and more deeply. Must I fear signal processing
-- engineers going the same route as physicists? We may be witnessing
-- one of the worst and most quickly accelerating infectious rots ever
-- encountered by our intellectual institutions.
--
-- It is possible, by the way, to arrive at our solution by wave
-- coherence theory instead of probability theory. Probability theory
-- is more mathematically fundamental and so, perhaps, more
-- convincing, but wave coherence is more familiar to some engineers
-- and scientists. Reference [3] uses the wave coherence approach,
-- treating the signals specifically as pulses of plane-polarized
-- light. The wave coherence approach could be used as well with
-- abstract signals, looking for coherence not in electromagnetic
-- waves, but directly within statistical data. The mathematics would
-- be similar.
--
-- Finally, I would like to point out that Bell’s ‘axiom of causality’
-- is actually a corollary of the famous ‘Wishing Theorem’. The
-- Wishing Theorem states: Proposition P is true because I wish it.
--
----------------------------------------------------------------------
--
-- References.
--
-- [1] J. S. Bell, ‘Bertlmann’s socks and the nature of reality’,
--     preprint, CERN-TH-2926 (1980).
--     http://cds.cern.ch/record/142461/ (Open access, CC BY 4.0)
--
-- [2] E. T. Jaynes, ‘Clearing up Mysteries—The Original Goal’, in
--     J. Skilling, ed., Maximum-Entropy and Bayesian Methods, Kluwer,
--     Dordrecht (1989).
--     https://bayes.wustl.edu/etj/articles/cmystery.pdf
--
-- [3] A. F. Kracklauer, ‘EPR-B correlations: non-locality or
--     geometry?’, J. Nonlinear Math. Phys. 11 (Supp.) 104–109 (2004).
--     https://doi.org/10.2991/jnmp.2004.11.s1.13 (Open access, CC
--     BY-NC)
--
----------------------------------------------------------------------
--
-- A copy of the program output.
--
--    φ1 =   0.00   φ2 = -22.50   ρ est. =  0.70795
--    φ1 =  11.25   φ2 = -11.25   ρ est. =  0.70562
--    φ1 =  22.50   φ2 =   0.00   ρ est. =  0.70626
--    φ1 =  33.75   φ2 =  11.25   ρ est. =  0.70621
--    φ1 =  45.00   φ2 =  22.50   ρ est. =  0.70683
--    φ1 =  56.25   φ2 =  33.75   ρ est. =  0.70750
--    φ1 =  67.50   φ2 =  45.00   ρ est. =  0.70796
--    φ1 =  78.75   φ2 =  56.25   ρ est. =  0.70672
--    φ1 =  90.00   φ2 =  67.50   ρ est. =  0.70792
--    φ1 = 101.25   φ2 =  78.75   ρ est. =  0.70641
--    φ1 = 112.50   φ2 =  90.00   ρ est. =  0.70639
--    φ1 = 123.75   φ2 = 101.25   ρ est. =  0.70615
--    φ1 = 135.00   φ2 = 112.50   ρ est. =  0.70959
--    φ1 = 146.25   φ2 = 123.75   ρ est. =  0.70596
--    φ1 = 157.50   φ2 = 135.00   ρ est. =  0.70671
--    φ1 = 168.75   φ2 = 146.25   ρ est. =  0.70553
--    φ1 = 180.00   φ2 = 157.50   ρ est. =  0.70702
--    φ1 = 191.25   φ2 = 168.75   ρ est. =  0.70953
--    φ1 = 202.50   φ2 = 180.00   ρ est. =  0.70713
--    φ1 = 213.75   φ2 = 191.25   ρ est. =  0.70714
--    φ1 = 225.00   φ2 = 202.50   ρ est. =  0.70612
--    φ1 = 236.25   φ2 = 213.75   ρ est. =  0.70811
--    φ1 = 247.50   φ2 = 225.00   ρ est. =  0.70919
--    φ1 = 258.75   φ2 = 236.25   ρ est. =  0.70771
--    φ1 = 270.00   φ2 = 247.50   ρ est. =  0.70738
--    φ1 = 281.25   φ2 = 258.75   ρ est. =  0.70727
--    φ1 = 292.50   φ2 = 270.00   ρ est. =  0.70712
--    φ1 = 303.75   φ2 = 281.25   ρ est. =  0.70765
--    φ1 = 315.00   φ2 = 292.50   ρ est. =  0.70597
--    φ1 = 326.25   φ2 = 303.75   ρ est. =  0.70727
--    φ1 = 337.50   φ2 = 315.00   ρ est. =  0.70733
--    φ1 = 348.75   φ2 = 326.25   ρ est. =  0.70615
-- 
--    φ1 =   0.00   φ2 =  22.50   ρ est. =  0.70704
--    φ1 =  11.25   φ2 =  33.75   ρ est. =  0.70688
--    φ1 =  22.50   φ2 =  45.00   ρ est. =  0.70675
--    φ1 =  33.75   φ2 =  56.25   ρ est. =  0.70772
--    φ1 =  45.00   φ2 =  67.50   ρ est. =  0.70944
--    φ1 =  56.25   φ2 =  78.75   ρ est. =  0.70698
--    φ1 =  67.50   φ2 =  90.00   ρ est. =  0.70745
--    φ1 =  78.75   φ2 = 101.25   ρ est. =  0.70660
--    φ1 =  90.00   φ2 = 112.50   ρ est. =  0.70651
--    φ1 = 101.25   φ2 = 123.75   ρ est. =  0.70768
--    φ1 = 112.50   φ2 = 135.00   ρ est. =  0.70784
--    φ1 = 123.75   φ2 = 146.25   ρ est. =  0.70716
--    φ1 = 135.00   φ2 = 157.50   ρ est. =  0.70511
--    φ1 = 146.25   φ2 = 168.75   ρ est. =  0.70778
--    φ1 = 157.50   φ2 = 180.00   ρ est. =  0.70601
--    φ1 = 168.75   φ2 = 191.25   ρ est. =  0.70930
--    φ1 = 180.00   φ2 = 202.50   ρ est. =  0.70768
--    φ1 = 191.25   φ2 = 213.75   ρ est. =  0.70538
--    φ1 = 202.50   φ2 = 225.00   ρ est. =  0.70691
--    φ1 = 213.75   φ2 = 236.25   ρ est. =  0.70773
--    φ1 = 225.00   φ2 = 247.50   ρ est. =  0.70589
--    φ1 = 236.25   φ2 = 258.75   ρ est. =  0.70642
--    φ1 = 247.50   φ2 = 270.00   ρ est. =  0.70693
--    φ1 = 258.75   φ2 = 281.25   ρ est. =  0.70703
--    φ1 = 270.00   φ2 = 292.50   ρ est. =  0.70632
--    φ1 = 281.25   φ2 = 303.75   ρ est. =  0.70764
--    φ1 = 292.50   φ2 = 315.00   ρ est. =  0.70808
--    φ1 = 303.75   φ2 = 326.25   ρ est. =  0.70540
--    φ1 = 315.00   φ2 = 337.50   ρ est. =  0.70710
--    φ1 = 326.25   φ2 = 348.75   ρ est. =  0.70595
--    φ1 = 337.50   φ2 = 360.00   ρ est. =  0.70710
--    φ1 = 348.75   φ2 = 371.25   ρ est. =  0.70676
-- 
--    φ1 =   0.00   φ2 = -67.50   ρ est. = -0.70675
--    φ1 =  11.25   φ2 = -56.25   ρ est. = -0.70704
--    φ1 =  22.50   φ2 = -45.00   ρ est. = -0.70640
--    φ1 =  33.75   φ2 = -33.75   ρ est. = -0.70595
--    φ1 =  45.00   φ2 = -22.50   ρ est. = -0.70673
--    φ1 =  56.25   φ2 = -11.25   ρ est. = -0.70814
--    φ1 =  67.50   φ2 =   0.00   ρ est. = -0.70717
--    φ1 =  78.75   φ2 =  11.25   ρ est. = -0.70630
--    φ1 =  90.00   φ2 =  22.50   ρ est. = -0.70750
--    φ1 = 101.25   φ2 =  33.75   ρ est. = -0.70602
--    φ1 = 112.50   φ2 =  45.00   ρ est. = -0.70693
--    φ1 = 123.75   φ2 =  56.25   ρ est. = -0.70796
--    φ1 = 135.00   φ2 =  67.50   ρ est. = -0.70756
--    φ1 = 146.25   φ2 =  78.75   ρ est. = -0.70707
--    φ1 = 157.50   φ2 =  90.00   ρ est. = -0.70766
--    φ1 = 168.75   φ2 = 101.25   ρ est. = -0.70598
--    φ1 = 180.00   φ2 = 112.50   ρ est. = -0.70700
--    φ1 = 191.25   φ2 = 123.75   ρ est. = -0.70810
--    φ1 = 202.50   φ2 = 135.00   ρ est. = -0.70828
--    φ1 = 213.75   φ2 = 146.25   ρ est. = -0.70878
--    φ1 = 225.00   φ2 = 157.50   ρ est. = -0.70693
--    φ1 = 236.25   φ2 = 168.75   ρ est. = -0.70774
--    φ1 = 247.50   φ2 = 180.00   ρ est. = -0.70804
--    φ1 = 258.75   φ2 = 191.25   ρ est. = -0.70772
--    φ1 = 270.00   φ2 = 202.50   ρ est. = -0.70717
--    φ1 = 281.25   φ2 = 213.75   ρ est. = -0.70636
--    φ1 = 292.50   φ2 = 225.00   ρ est. = -0.70899
--    φ1 = 303.75   φ2 = 236.25   ρ est. = -0.70777
--    φ1 = 315.00   φ2 = 247.50   ρ est. = -0.70699
--    φ1 = 326.25   φ2 = 258.75   ρ est. = -0.70818
--    φ1 = 337.50   φ2 = 270.00   ρ est. = -0.70656
--    φ1 = 348.75   φ2 = 281.25   ρ est. = -0.70741
-- 
--    φ1 =   0.00   φ2 =  67.50   ρ est. = -0.70720
--    φ1 =  11.25   φ2 =  78.75   ρ est. = -0.70685
--    φ1 =  22.50   φ2 =  90.00   ρ est. = -0.70667
--    φ1 =  33.75   φ2 = 101.25   ρ est. = -0.70794
--    φ1 =  45.00   φ2 = 112.50   ρ est. = -0.70561
--    φ1 =  56.25   φ2 = 123.75   ρ est. = -0.70839
--    φ1 =  67.50   φ2 = 135.00   ρ est. = -0.70680
--    φ1 =  78.75   φ2 = 146.25   ρ est. = -0.70912
--    φ1 =  90.00   φ2 = 157.50   ρ est. = -0.70708
--    φ1 = 101.25   φ2 = 168.75   ρ est. = -0.70705
--    φ1 = 112.50   φ2 = 180.00   ρ est. = -0.70685
--    φ1 = 123.75   φ2 = 191.25   ρ est. = -0.70501
--    φ1 = 135.00   φ2 = 202.50   ρ est. = -0.70737
--    φ1 = 146.25   φ2 = 213.75   ρ est. = -0.70629
--    φ1 = 157.50   φ2 = 225.00   ρ est. = -0.70789
--    φ1 = 168.75   φ2 = 236.25   ρ est. = -0.70808
--    φ1 = 180.00   φ2 = 247.50   ρ est. = -0.70736
--    φ1 = 191.25   φ2 = 258.75   ρ est. = -0.70660
--    φ1 = 202.50   φ2 = 270.00   ρ est. = -0.70670
--    φ1 = 213.75   φ2 = 281.25   ρ est. = -0.70555
--    φ1 = 225.00   φ2 = 292.50   ρ est. = -0.70606
--    φ1 = 236.25   φ2 = 303.75   ρ est. = -0.70866
--    φ1 = 247.50   φ2 = 315.00   ρ est. = -0.70820
--    φ1 = 258.75   φ2 = 326.25   ρ est. = -0.70672
--    φ1 = 270.00   φ2 = 337.50   ρ est. = -0.70769
--    φ1 = 281.25   φ2 = 348.75   ρ est. = -0.70806
--    φ1 = 292.50   φ2 = 360.00   ρ est. = -0.70728
--    φ1 = 303.75   φ2 = 371.25   ρ est. = -0.70809
--    φ1 = 315.00   φ2 = 382.50   ρ est. = -0.70531
--    φ1 = 326.25   φ2 = 393.75   ρ est. = -0.70815
--    φ1 = 337.50   φ2 = 405.00   ρ est. = -0.70800
--    φ1 = 348.75   φ2 = 416.25   ρ est. = -0.70445
--
--********************************************************************
-- Some instructions for the Emacs text editor.
-- local variables:
-- mode: indented-text
-- tab-width: 2
-- end:
