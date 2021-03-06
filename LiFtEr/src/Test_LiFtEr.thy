(*  Title:      PSL//Test_LiFtEr.thy
    Author:     Yutaka Nagashima, Czech Technical University in Prague, the University of Innsbruck

MeLoId: Machine Learning Induction for Isabelle/HOL, and
LiFtEr: Logical Feature Extractor.
*)
theory Test_LiFtEr
  imports
    "../TIP_TO_Test_LiFtEr/Isaplanner/Isaplanner/TIP_prop_01"
    "../TIP_TO_Test_LiFtEr/TIP15/TIP15/TIP_list_count_nub"
    "../TIP_TO_Test_LiFtEr/TIP15/TIP15/TIP_propositional_AndCommutative"
begin

(* This definition of "evn" is from the official tutorial "A Proof Assistant for Higher-Order Logic". *)
inductive evn :: "nat \<Rightarrow> bool" where
  zero: "evn 0"
| step: "evn n \<Longrightarrow> evn (Suc (Suc n))"

print_theorems

ML{* val _ = @{assert} (Pattern.has_recursive_simp_or_psimp_about_const_name @{context} "Test_LiFtEr.evn");      *}
ML{* val _ = @{assert} (Pattern.has_recursive_simp_or_psimp_about_const_name @{context} "List.nth");             *}
ML{* val _ = @{assert} (Pattern.has_recursive_simp_or_psimp_about_const_name @{context} "HOL.eq"      |> not);   *}
ML{* val _ = @{assert} (Pattern.has_recursive_simp_or_psimp_about_const_name @{context} "List.insert" |> not);   *}
ML{* val _ = @{assert} (Pattern.has_recursive_simp_or_psimp_about_const_name @{context} "xs"          |> not);   *}

(* This definition of "evn" is from the official tutorial "A Proof Assistant for Higher-Order Logic". *)
primrec itrev:: "'a List.list \<Rightarrow> 'a List.list \<Rightarrow> 'a List.list" where
  "itrev [] ys = ys" |
  "itrev (xa#xs) ys = itrev xs (xa#ys)"

print_theorems

ML{* val _ = @{assert} (Pattern.has_recursive_simp_or_psimp_about_const_name @{context} "Test_LiFtEr.itrev"); *}

end