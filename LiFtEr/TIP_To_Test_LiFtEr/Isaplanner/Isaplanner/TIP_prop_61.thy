(* Property from Case-Analysis for Rippling and Inductive Proof, 
   Moa Johansson, Lucas Dixon and Alan Bundy, ITP 2010. 
   This Isabelle theory is produced using the TIP tool offered at the following website: 
     https://github.com/tip-org/tools 
   This file was originally provided as part of TIP benchmark at the following website:
     https://github.com/tip-org/benchmarks 
   Yutaka Nagashima at CIIRC, CTU changed the TIP output theory file slightly 
   to make it compatible with Isabelle2017.*)
  theory TIP_prop_61
  imports "../../Test_Base"
begin

datatype 'a list = nil2 | cons2 "'a" "'a list"

datatype Nat = Z | S "Nat"

fun x :: "'a list => 'a list => 'a list" where
  "x (nil2) z = z"
| "x (cons2 z2 xs) z = cons2 z2 (x xs z)"

fun last :: "Nat list => Nat" where
  "last (nil2) = Z"
| "last (cons2 z (nil2)) = z"
| "last (cons2 z (cons2 x2 x3)) = last (cons2 x2 x3)"

fun lastOfTwo :: "Nat list => Nat list => Nat" where
  "lastOfTwo y (nil2) = last y"
| "lastOfTwo y (cons2 z2 x2) = last (cons2 z2 x2)"

theorem property0 :
  "((last (x xs ys)) = (lastOfTwo xs ys))"
  oops

end
