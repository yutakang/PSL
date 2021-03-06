(*  Title:      PSL/SeLFiE/src/From_Variable_To_Quantifier.ML
    Author:     Yutaka Nagashima, Czech Technical University in Prague, the University of Innsbruck
*)
functor from_Variable_to_Quantifier
 (structure Eval_Variable:EVAL_VARIABLE
  and       Quantifier_Domain:QUANTIFIER_DOMAIN
  sharing type Eval_Variable.parameter = Quantifier_Domain.parameter): EVAL_QUANTIFIER =
struct

structure EV  = Eval_Variable;
structure QD  = Quantifier_Domain;
structure SU  = SeLFiE_Util;

type path    = EV.path;
type command = Pattern.command;

datatype parameter = Path of path | Non_Path of SeLFiE_Util.non_path_parameter;

fun here_to_there (Path     p ) = EV.Path p
  | here_to_there (Non_Path np) = EV.Non_Path np;

fun there_to_here (EV.Path     p ) = Path p
  | there_to_here (EV.Non_Path np) = Non_Path np;

datatype expr =
  Variable of string
| Lambda   of string * expr
| Apply    of expr   * expr
| Literal  of parameter
| Assert   of SU.assert * expr list
| All      of string * SU.qtyp * expr
| Some     of string * SU.qtyp * expr;

type path_to_node_table   = QD.path_to_node_table;
type print_to_paths_table = QD.print_to_paths_table;

fun convert_result (EV.Literal ee_bool) = Literal (there_to_here ee_bool)
  | convert_result  _ = error "eval in Eval_Quantifier_Struct failed. Evaluation is not complete.";

fun eval (trm:term) (pst:Proof.state) (induct_args:SeLFiE_Util.induct_arguments) expr =
  let
    fun vname_n_subexpr_n_qtyp_to_apps (vname:string) (subexpr:expr) (qtyp:SU.qtyp) (ands_or_ors:SU.assert) =
      let
        val params = QD.qtyp_to_qdomain qtyp pst trm induct_args: QD.parameter list;
        val apps = map (fn param => Apply (Lambda (vname, subexpr), Literal (there_to_here param))) params: expr list;
      in
        Assert (ands_or_ors, apps): expr
      end;
    fun eval' (Variable vname)              = EV.eval trm pst (EV.Variable vname)
      | eval' (Lambda (vname, subexpr))     = EV.eval trm pst (EV.Lambda (vname, eval' subexpr))
      | eval' (Apply   pair           )     = EV.eval trm pst (EV.Apply (apply2 eval' pair))
      | eval' (Literal ps             )     = EV.eval trm pst (EV.Literal (here_to_there ps))
      | eval' (Assert (assrt, ps))          = EV.eval trm pst (EV.Assert (assrt, map eval' ps))
      | eval' (All  (vname, qtyp, subexpr)) = eval' (vname_n_subexpr_n_qtyp_to_apps vname subexpr qtyp SU.Ands)
      (*Note that we cannot treat Some as a syntax sugar for All because Not has to take Literals due to the restriction imposed in From_Parameter_To_Parameter_With_Bool.ML.*)
      | eval' (Some (vname, qtyp, subexpr)) = eval' (vname_n_subexpr_n_qtyp_to_apps vname subexpr qtyp SU.Ors)
    val ev_result  = eval' expr              : EV.expr;
    val result     = convert_result ev_result: expr;
  in
    result
  end;

end;