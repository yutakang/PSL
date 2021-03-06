(*  Title:      PSL/SeLFiE/src/Interpreter/Eval_Surface.ML
    Author:     Yutaka Nagashima, Czech Technical University in Prague, the University of Innsbruck

*)

(*** signature: EVAL_SURFACE ***)
signature EVAL_SURFACE =
sig

datatype assert =
(*bool*)
  True
| False
| Not      of assert
| And      of assert * assert
| Or       of assert * assert
| Nor      of assert * assert
| Imply    of assert * assert
| Ands     of assert list
| Ors      of assert list
(*Eval_Node*)
| Is_Cnst    of assert
| Is_Free    of assert
| Is_Var     of assert
| Is_Bound   of assert
| Is_Lambda  of assert
| Is_App     of assert
(*Eval_Unode*)
| Has_Same_Prnt_As  of assert * assert
| Is_In_Trm_Prnt    of assert * assert
| Is_Deeper_Than    of assert * assert
| Is_Shallower_Than of assert * assert
| Is_Path_Above     of assert * assert
| Is_Same_Path_As   of assert * assert
(*Eval_Print*)
| Are_Same_Prints   of assert * assert
(*Eval_Path*)
| Unode_Has_Print   of assert * assert
(*Eval_Number*)
| Are_Same_Number of assert * assert
| Is_Less_Than    of assert * assert
(*Parameter*)
| Print  of string
| Number of int
(*expr*)
| Variable            of string
| Lambdas             of strings * assert
| Applies             of assert  * assert list
| Alls                of (string * SeLFiE_Util.qtyp) list * assert
| Somes               of (string * SeLFiE_Util.qtyp) list * assert
| In_All_Definitions  of (assert * assert * assert list)
| In_Some_Definitions of (assert * assert * assert list)
| Outermost           of assert;

val eval: term -> Proof.state -> SeLFiE_Util.induct_arguments -> assert -> assert;

end;

(*** Eval_Surface ***)
structure Eval_Surface: EVAL_SURFACE =
struct

structure ED = Eval_Deep;
structure SU = SeLFiE_Util;

datatype assert =
(*bool*)
  True
| False
| Not      of assert
| And      of assert * assert
| Or       of assert * assert
| Nor      of assert * assert
| Imply    of assert * assert
| Ands     of assert list
| Ors      of assert list
(*Eval_Node*)
| Is_Cnst    of assert
| Is_Free    of assert
| Is_Var     of assert
| Is_Bound   of assert
| Is_Lambda  of assert
| Is_App     of assert
(*Eval_Unode*)
| Has_Same_Prnt_As  of assert * assert
| Is_In_Trm_Prnt    of assert * assert
| Is_Deeper_Than    of assert * assert
| Is_Shallower_Than of assert * assert
| Is_Path_Above     of assert * assert
| Is_Same_Path_As   of assert * assert
(*Eval_Print*)
| Are_Same_Prints   of assert * assert
(*Eval_Path*)
| Unode_Has_Print   of assert * assert
(*Eval_Number*)
| Are_Same_Number of assert * assert
| Is_Less_Than    of assert * assert
(*Parameter*)
| Print  of string
| Number of int
(*expr*)
| Variable            of string
| Lambdas             of strings * assert
| Applies             of assert  * assert list
| Alls                of (string * SU.qtyp) list * assert
| Somes               of (string * SU.qtyp) list * assert
| In_All_Definitions  of (assert * assert * assert list)
| In_Some_Definitions of (assert * assert * assert list)
| Outermost           of assert;

fun come_back_expression (ED.Outer_Literal (ED.Outer_Non_Path (SU.Bool bool))) = if bool then True else False
  | come_back_expression  _                                                    = error "come_back_expression in Eval_Surface.ML failed."

fun eval (term:term) (pst:Proof.state) (induct_args:SeLFiE_Util.induct_arguments) (assert:assert) =
  let
    fun ed_eval_outer                    (outer_expr:ED.outer_expression)                    = ED.eval_outer pst induct_args outer_expr term                   : ED.outer_expression;
    fun ed_eval_outer_param              (param     :ED.outer_parameter)                     = ed_eval_outer (ED.Outer_Literal param)                          : ED.outer_expression;
    fun ed_eval_outer_assert_one         (ass:SU.assert,          arg:assert)                = ed_eval_outer (ED.Outer_Assert (ass, [eval_out arg]))           : ED.outer_expression
    and ed_eval_outer_assert_atomic_one  (atom:SU.atomic_assert,  arg:assert)                = ed_eval_outer_assert_one (SU.Atomic atom, arg)                  : ED.outer_expression
    and ed_eval_outer_assert_pair        (ass:SU.assert,         (arg1:assert, arg2:assert)) = ed_eval_outer (ED.Outer_Assert (ass, map eval_out [arg1, arg2])): ED.outer_expression
    and ed_eval_outer_assert_atomic_pair (atom:SU.atomic_assert, (arg1:assert, arg2:assert)) = ed_eval_outer_assert_pair (SU.Atomic atom, (arg1, arg2))        : ED.outer_expression
    and ed_eval_outer_assert_list        (assert:SU.assert,  args: assert list)              = ed_eval_outer (ED.Outer_Assert (assert, map eval_out args))     : ED.outer_expression
    and eval_enter (Outermost ass) = eval_out ass
      | eval_enter _ = error "eval in From_Deep_To_Surface.ML failed. eval is defined only for Outermost."
    and eval_out True                         = ed_eval_outer_param              (ED.Outer_Non_Path (SU.Bool true ))
      | eval_out False                        = ed_eval_outer_param              (ED.Outer_Non_Path (SU.Bool false))
      | eval_out (Not               ass)      = ed_eval_outer_assert_one         (SU.Not,               ass)
      | eval_out (And               pair)     = ed_eval_outer_assert_pair        (SU.And,               pair)
      | eval_out (Or                pair)     = ed_eval_outer_assert_pair        (SU.Or,                pair)
      | eval_out (Nor               pair)     = ed_eval_outer_assert_pair        (SU.Nor,               pair)
      | eval_out (Imply             pair)     = ed_eval_outer_assert_pair        (SU.Imply,             pair)
      | eval_out (Ands              asses)    = ed_eval_outer_assert_list        (SU.Ands,              asses)
      | eval_out (Ors               asses)    = ed_eval_outer_assert_list        (SU.Ors,               asses)
      | eval_out (Is_Cnst           ass)      = ed_eval_outer_assert_atomic_one  (SU.Is_Cnst,           ass)
      | eval_out (Is_Free           ass)      = ed_eval_outer_assert_atomic_one  (SU.Is_Free,           ass)
      | eval_out (Is_Var            ass)      = ed_eval_outer_assert_atomic_one  (SU.Is_Var,            ass)
      | eval_out (Is_Bound          ass)      = ed_eval_outer_assert_atomic_one  (SU.Is_Bound,          ass)
      | eval_out (Is_Lambda         ass)      = ed_eval_outer_assert_atomic_one  (SU.Is_Lambda,         ass)
      | eval_out (Is_App            ass)      = ed_eval_outer_assert_atomic_one  (SU.Is_App,            ass)
      | eval_out (Has_Same_Prnt_As  pair)     = ed_eval_outer_assert_atomic_pair (SU.Has_Same_Prnt_As,  pair)
      | eval_out (Is_In_Trm_Prnt    pair)     = ed_eval_outer_assert_atomic_pair (SU.Is_In_Trm_Prnt,    pair)
      | eval_out (Is_Deeper_Than    pair)     = ed_eval_outer_assert_atomic_pair (SU.Is_Deeper_Than,    pair)
      | eval_out (Is_Shallower_Than pair)     = ed_eval_outer_assert_atomic_pair (SU.Is_Shallower_Than, pair)
      | eval_out (Is_Path_Above     pair)     = ed_eval_outer_assert_atomic_pair (SU.Is_Path_Above,     pair)
      | eval_out (Is_Same_Path_As   pair)     = ed_eval_outer_assert_atomic_pair (SU.Is_Same_Path_As,   pair)
      | eval_out (Are_Same_Prints   pair)     = ed_eval_outer_assert_atomic_pair (SU.Are_Same_Prints,   pair)
      | eval_out (Unode_Has_Print   pair)     = ed_eval_outer_assert_atomic_pair (SU.Unode_Has_Print,   pair)
      | eval_out (Are_Same_Number   pair)     = ed_eval_outer_assert_atomic_pair (SU.Are_Same_Number,   pair)
      | eval_out (Is_Less_Than      pair)     = ed_eval_outer_assert_atomic_pair (SU.Is_Less_Than,      pair)
      | eval_out (Print            print)     = ed_eval_outer_param              (ED.Outer_Non_Path (SU.Print  print ))
      | eval_out (Number          number)     = ed_eval_outer_param              (ED.Outer_Non_Path (SU.Number number))
      | eval_out (Variable        string)     = ed_eval_outer (ED.Outer_Variable string)
      | eval_out (Lambdas (strings, sub_ass)) = ed_eval_outer (ED.Outer_Lambdas (strings,       eval_out sub_ass ))
      | eval_out (Applies (func,    args))    = ed_eval_outer (ED.Outer_Applies (eval_out func, map eval_out args))
      | eval_out (Alls    (pairs,   sub_ass)) = ed_eval_outer (ED.Outer_Alls    (pairs, eval_out sub_ass))
      | eval_out (Somes   (pairs,   sub_ass)) = ed_eval_outer (ED.Outer_Somes   (pairs, eval_out sub_ass))
      | eval_out (In_All_Definitions  (target, inner_ass as Lambdas _, outer_args)) = ED.eval_outer pst induct_args (ED.Dive_In (eval_out target, eval_in inner_ass, map eval_out outer_args)) term
      | eval_out (In_Some_Definitions (target, Lambdas (vnames, body), outer_args)) =
        let
          val sugar = (ED.Dive_In (eval_out target, ED.Inner_Assert (SU.Not, [eval_in (Lambdas (vnames, Not body))]), map eval_out outer_args))
        in
          ED.eval_outer pst induct_args sugar term
        end
      | eval_out (In_All_Definitions  _) = error "eval_out in From_Deep_To_Surface.ML failed. The inner part of In_All_Definitions has to be a lambda abstraction."
      | eval_out (In_Some_Definitions _) = error "eval_out in From_Deep_To_Surface.ML failed. The inner part of In_Some_Definitions has to be a lambda abstraction."
      | eval_out (Outermost _)           = error "eval_out in From_Deep_To_Surface.ML failed. eval_out is not defined for Outermost."
    and ed_eval_inner                    (inner_expr:ED.inner_expression)                    = ED.eval_inner pst induct_args inner_expr term                   : ED.inner_expression
    and ed_eval_inner_param              (param     :ED.inner_parameter)                     = ed_eval_inner (ED.Inner_Literal param)                          : ED.inner_expression
    and ed_eval_inner_assert_one         (ass:SU.assert,          arg:assert)                = ed_eval_inner (ED.Inner_Assert (ass, [eval_in arg]))            : ED.inner_expression
    and ed_eval_inner_assert_atomic_one  (atom:SU.atomic_assert,  arg:assert)                = ed_eval_inner_assert_one (SU.Atomic atom, arg)                  : ED.inner_expression
    and ed_eval_inner_assert_pair        (ass:SU.assert,         (arg1:assert, arg2:assert)) = ed_eval_inner (ED.Inner_Assert (ass, map eval_in [arg1, arg2])) : ED.inner_expression
    and ed_eval_inner_assert_atomic_pair (atom:SU.atomic_assert, (arg1:assert, arg2:assert)) = ed_eval_inner_assert_pair (SU.Atomic atom, (arg1, arg2))        : ED.inner_expression
    and ed_eval_inner_assert_list        (assert:SU.assert,  args: assert list)              = ed_eval_inner (ED.Inner_Assert (assert, map eval_in args))      : ED.inner_expression
    and eval_in True      = ed_eval_inner_param (ED.Inner_Non_Path (SU.Bool true ))
      | eval_in False     = ed_eval_inner_param (ED.Inner_Non_Path (SU.Bool false))
      | eval_in (Not ass) = ed_eval_inner_assert_one (SU.Not, ass)
      | eval_in (And               pair)     = ed_eval_inner_assert_pair        (SU.And,               pair)
      | eval_in (Or                pair)     = ed_eval_inner_assert_pair        (SU.Or,                pair)
      | eval_in (Nor               pair)     = ed_eval_inner_assert_pair        (SU.Nor,               pair)
      | eval_in (Imply             pair)     = ed_eval_inner_assert_pair        (SU.Imply,             pair)
      | eval_in (Ands              asses)    = ed_eval_inner_assert_list        (SU.Ands,              asses)
      | eval_in (Ors               asses)    = ed_eval_inner_assert_list        (SU.Ors,               asses)
      | eval_in (Is_Cnst           ass)      = ed_eval_inner_assert_atomic_one  (SU.Is_Cnst,           ass)
      | eval_in (Is_Free           ass)      = ed_eval_inner_assert_atomic_one  (SU.Is_Free,           ass)
      | eval_in (Is_Var            ass)      = ed_eval_inner_assert_atomic_one  (SU.Is_Var,            ass)
      | eval_in (Is_Bound          ass)      = ed_eval_inner_assert_atomic_one  (SU.Is_Bound,          ass)
      | eval_in (Is_Lambda         ass)      = ed_eval_inner_assert_atomic_one  (SU.Is_Lambda,         ass)
      | eval_in (Is_App            ass)      = ed_eval_inner_assert_atomic_one  (SU.Is_App,            ass)
      | eval_in (Has_Same_Prnt_As  pair)     = ed_eval_inner_assert_atomic_pair (SU.Has_Same_Prnt_As,  pair)
      | eval_in (Is_In_Trm_Prnt    pair)     = ed_eval_inner_assert_atomic_pair (SU.Is_In_Trm_Prnt,    pair)
      | eval_in (Is_Deeper_Than    pair)     = ed_eval_inner_assert_atomic_pair (SU.Is_Deeper_Than,    pair)
      | eval_in (Is_Shallower_Than pair)     = ed_eval_inner_assert_atomic_pair (SU.Is_Shallower_Than, pair)
      | eval_in (Is_Path_Above     pair)     = ed_eval_inner_assert_atomic_pair (SU.Is_Path_Above,     pair)
      | eval_in (Is_Same_Path_As   pair)     = ed_eval_inner_assert_atomic_pair (SU.Is_Same_Path_As,   pair)
      | eval_in (Are_Same_Prints   pair)     = ed_eval_inner_assert_atomic_pair (SU.Are_Same_Prints,   pair)
      | eval_in (Unode_Has_Print   pair)     = ed_eval_inner_assert_atomic_pair (SU.Unode_Has_Print,   pair)
      | eval_in (Are_Same_Number   pair)     = ed_eval_inner_assert_atomic_pair (SU.Are_Same_Number,   pair)
      | eval_in (Is_Less_Than      pair)     = ed_eval_inner_assert_atomic_pair (SU.Is_Less_Than,      pair)
      | eval_in (Print            print)     = ed_eval_inner_param              (ED.Inner_Non_Path (SU.Print  print ))
      | eval_in (Number          number)     = ed_eval_inner_param              (ED.Inner_Non_Path (SU.Number number))
      | eval_in (Variable        string)     = ed_eval_inner (ED.Inner_Variable string)
      | eval_in (Lambdas (strings, sub_ass)) = ed_eval_inner (ED.Inner_Lambdas (strings,       eval_in sub_ass ))
      | eval_in (Applies (func,    args))    = ed_eval_inner (ED.Inner_Applies (eval_in func, map eval_in args))
      | eval_in (Alls    (pairs,   sub_ass)) = ed_eval_inner (ED.Inner_Alls    (pairs, eval_in sub_ass))
      | eval_in (Somes   (pairs,   sub_ass)) = ed_eval_inner (ED.Inner_Somes   (pairs, eval_in sub_ass))
      | eval_in (In_All_Definitions  (target, inner_ass as Lambdas _, outer_args)) = ED.eval_inner pst induct_args (ED.Dive_Deeper (eval_in target, eval_in inner_ass, map eval_in outer_args)) term
      | eval_in (In_Some_Definitions (target, Lambdas (vnames, body), outer_args)) =
        let
          val sugar = (ED.Dive_Deeper (eval_in target, ED.Inner_Assert (SU.Not, [eval_in (Lambdas (vnames, Not body))]), map eval_in outer_args))
        in
          ED.eval_inner pst induct_args sugar term
        end
      | eval_in (In_All_Definitions  _) = error "eval_in in From_Deep_To_Surface.ML failed. The inner part of In_All_Definitions has to be a lambda abstraction."
      | eval_in (In_Some_Definitions _) = error "eval_in in From_Deep_To_Surface.ML failed. The inner part of In_Some_Definitions has to be a lambda abstraction."
      | eval_in (Outermost _)           = error "eval_in in From_Deep_To_Surface.ML failed. eval_in is not defined for Outermost."
  in
      eval_enter assert |> come_back_expression
  end

end;