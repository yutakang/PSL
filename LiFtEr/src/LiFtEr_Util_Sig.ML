(*  Title:      PSL/LiFtEr/src/LiFtEr_Util_Sig.ML
    Author:     Yutaka Nagashima, Czech Technical University in Prague, the University of Innsbruck

Helper functions for LiFtEr.
*)

(*** LIFTER_UTIL ***)
signature LIFTER_UTIL =
sig

type     path   = ints;
(* print: the printed format of a sub-tree in the syntax tree of a term. *)
datatype print  = Print of string;
type     prints = print list;
val same_prints           : print -> print -> bool;
val same_normalized_prints: Proof.context -> print -> print -> bool;
val path_to_string        : path -> string;

val dest_print           : print -> string;
val is_subprint_of       : print -> print -> bool;
val ctxt_n_print_to_cname: Proof.context -> print -> string option;

(* modifiers for the induct method *)
datatype induct_on   = Ind_On      of print;
datatype induct_arb  = Ind_Arb     of print;
datatype induct_rule = Ind_Rule    of string;
datatype ind_mods    = Ind_Mods    of {ons: induct_on list, arbs: induct_arb list, rules: induct_rule list};

val dest_induct_on  : induct_on   -> print;
val dest_induct_arb : induct_arb  -> print;
val dest_induct_rule: induct_rule -> string;
val dest_mods       : ind_mods    -> {ons: induct_on list, arbs: induct_arb list, rules: induct_rule list};

val string_to_induct_on  : string -> induct_on;
val string_to_induct_arb : string -> induct_arb;
val string_to_induct_rule: string -> induct_rule;

val induct_on_to_string  : induct_on   -> string;
val induct_arb_to_string : induct_arb  -> string;
val induct_rule_to_string: induct_rule -> string;

end;