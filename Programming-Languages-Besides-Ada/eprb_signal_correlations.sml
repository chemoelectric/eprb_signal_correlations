(* 
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <https://unlicense.org>
*)

(*------------------------------------------------------------------*)
(* Run with ‘poly --script eprb_signal_correlations.sml’ *)

val pi     = Math.pi;
val pi_2   = pi / 2.0;
val pi_3   = pi / 3.0;
val pi_4   = pi / 4.0;
val pi_6   = pi / 6.0;
val pi_8   = pi / 8.0;
val pi_180 = pi / 180.0;
val two_pi = pi + pi;

fun cos2 x = let val y = Math.cos x in y * y end
fun sin2 x = let val y = Math.sin x in y * y end

(*------------------------------------------------------------------*)
(* The same random number generator as in the Ada. *)

val SOME lcgA = LargeWord.fromString "F1357AEA2E62A9C5";
val SOME lcgC = LargeWord.fromString "0000000000000001";
val SOME randomDenom = LargeReal.fromString "281474976710656.0";

val seed = ref (LargeWord.fromInt 0);

fun random () =
    let
        val seedVal = !seed
        val bits = LargeWord.>> (seedVal, Word.fromInt 16)
        val i = LargeWord.toLargeInt bits
        val numer = LargeReal.fromLargeInt i
        val denom = randomDenom
    in
        seed := (lcgA * seedVal) + lcgC; (* Update the seed. *)
        numer / denom
    end;

(*------------------------------------------------------------------*)

datatype signal = counterclockwise | clockwise;
datatype tag = circledPlus | circledMinus;

fun assignTag zeta counterclockwise =
    if random () < cos2 zeta then circledPlus else circledMinus
  | assignTag zeta clockwise =
    if random () < sin2 zeta then circledPlus else circledMinus;

(*------------------------------------------------------------------*)
