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
(* Run with ‘poly --script eprb_signal_correlations.sml’ or compile
   with mlton. *)

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

exception rngException;

val lcgA = case LargeWord.fromString "F1357AEA2E62A9C5" of
               SOME v => v
             | NONE => raise rngException;
val lcgC = LargeWord.fromInt 1;
val randomDenom : LargeReal.real = 281474976710656.0;

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
    (if random () < cos2 zeta then circledPlus else circledMinus,
     counterclockwise)
  | assignTag zeta clockwise =
    (if random () < sin2 zeta then circledPlus else circledMinus,
     clockwise)

fun collectData (zeta1, zeta2) runLength =
    let
        fun loop data 0 = data
          | loop data n =
            let
                val sigma =
                    if random () < 0.5 then
                        counterclockwise
                    else
                        clockwise
                val pair = (assignTag zeta1 sigma,
                            assignTag zeta2 sigma)
            in
                loop (pair :: data) (n - 1)
            end
    in
        loop [] runLength
    end;

fun count rawData sigma tau1 tau2 =
    let
        fun loop n [] = n
          | loop n (((t1, s), (t2, _)) :: rest) =
            if s = sigma andalso t1 = tau1 andalso t2 = tau2 then
                loop (n + 1) rest
            else
                loop n rest
    in
        loop 0 rawData
    end;

fun frequency rawData sigma tau1 tau2 =
    let
        val numer = LargeReal.fromInt (count rawData sigma tau1 tau2)
        and denom = LargeReal.fromInt (length rawData)
    in
        numer / denom
    end;

fun cosineSign phi = if Math.cos phi < 0.0 then ~1.0 else 1.0;
fun sineSign phi = if Math.sin phi < 0.0 then ~1.0 else 1.0;
fun ccSign (phi1, phi2) = cosineSign phi1 * cosineSign phi2;
fun csSign (phi1, phi2) = cosineSign phi1 * sineSign phi2;
fun scSign (phi1, phi2) = sineSign phi1 * cosineSign phi2;
fun ssSign (phi1, phi2) = sineSign phi1 * sineSign phi2;

fun estimate_rho_fromRawData rawData (phi1, phi2) =
    let
        val ac2c2 = frequency rawData counterclockwise
                              circledPlus circledPlus
        val ac2s2 = frequency rawData counterclockwise
                              circledPlus circledMinus
        val as2c2 = frequency rawData counterclockwise
                              circledMinus circledPlus
        val as2s2 = frequency rawData counterclockwise
                              circledMinus circledMinus
        val cs2s2 = frequency rawData clockwise
                              circledPlus circledPlus
        val cs2c2 = frequency rawData clockwise
                              circledPlus circledMinus
        val cc2s2 = frequency rawData clockwise
                              circledMinus circledPlus
        val cc2c2 = frequency rawData clockwise
                              circledMinus circledMinus

        val c2c2 = ac2c2 + cc2c2
        val c2s2 = ac2s2 + cc2s2
        val s2c2 = as2c2 + cs2c2
        val s2s2 = as2s2 + cs2s2

        val cc = ccSign (phi1, phi2) * Math.sqrt c2c2
        val cs = csSign (phi1, phi2) * Math.sqrt c2s2
        val sc = scSign (phi1, phi2) * Math.sqrt s2c2
        val ss = ssSign (phi1, phi2) * Math.sqrt s2s2

        val c12 = cc + ss
        val s12 = sc - cs
    in
        (c12 * c12) - (s12 * s12)
    end;

fun estimate_rho (phi1, phi2) runLength =
  estimate_rho_fromRawData (collectData (phi1, phi2) runLength)
                           (phi1, phi2);

exception printingException;

val phi1String = 
    case String.fromCString "\\xCF\\x86\\xE2\\x82\\x81" of
        SOME s => s
      | NONE => raise printingException;

val phi2String = 
    case String.fromCString "\\xCF\\x86\\xE2\\x82\\x82" of
        SOME s => s
      | NONE => raise printingException;

val rhoString = 
    case String.fromCString "\\xCF\\x81" of
        SOME s => s
      | NONE => raise printingException;

val minusSignString =
    case String.fromCString "\\xE2\\x88\\x92" of
        SOME s => s
      | NONE => raise printingException;

val degreeSignString =
    case String.fromCString "\\xC2\\xB0" of
        SOME s => s
      | NONE => raise printingException;

fun printBellTests delta_phi =
    let
        val runLength = 1000000
    in
        print "    ";
        print phi2String;
        print " ";
        print minusSignString;
        print " ";
        print phi1String;
        print " = ";
        print (LargeReal.fmt (StringCvt.FIX (SOME 2))
                             (delta_phi / pi_180));
        print degreeSignString;
        print "\n";
        let
            fun loop i =
                if i = 33 then
                    ()
                else
                    let
                        val phi1 = LargeReal.fromInt i * pi / 16.0
                        val phi2 = phi1 + delta_phi
                        val rho_estimate =
                            estimate_rho (phi1, phi2) runLength
                    in
                        print "    ";
                        print phi1String;
                        print " = ";
                        print (LargeReal.fmt (StringCvt.FIX (SOME 2))
                                             (phi1 / pi_180));
                        print degreeSignString;
                        print "  ";
                        print phi2String;
                        print " = ";
                        print (LargeReal.fmt (StringCvt.FIX (SOME 2))
                                             (phi2 / pi_180));
                        print degreeSignString;
                        print "   ";
                        print rhoString;
                        print " est. = ";
                        print (LargeReal.fmt (StringCvt.FIX (SOME 5))
                                             rho_estimate);
                        print "\n";
                        loop (i + 1)
                    end
        in
            loop 0
        end
    end;

print "\n";
printBellTests (~ pi_8);
print "\n";
printBellTests pi_8;
print "\n";
printBellTests (~3.0 * pi_8);
print "\n";
printBellTests (3.0 * pi_8);
print "\n";

(*------------------------------------------------------------------*)
