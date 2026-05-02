(* This example file depends on mczify (https://github.com/math-comp/mczify), in order not to lose
   too much time re-doing similar proofs to fuel our knowledge database. *)

(* Dependencies:
   - coq-mathcomp-algebra
   - coq-mathcomp-zify *)

From Stdlib Require Import ZArith ZifyClasses ZifyBool ZifyInst.
From mathcomp Require Import ssrint.

From mathcomp.zify Require Import ssrZ zify_algebra.
Import AlgebraZifyInstances.

Local Delimit Scope Z_scope with Z.

From Trakt Require Import Trakt.

Trakt Set Verbosity 1.

Notation Z_to_int := ssrZ.int_of_Z.

Lemma int_Z_gof_id : forall (x : int), x = Z_to_int (Z_of_int x).
Proof.
  intro x. symmetry. exact (Z_of_intK x).
Qed.

Lemma int_Z_fog_id : forall (z : Z), Z_of_int (Z_to_int z) = z.
Proof.
  intro x. exact (ssrZ.int_of_ZK x).
Qed.

Trakt Add Embedding int Z Z_of_int Z_to_int int_Z_gof_id int_Z_fog_id.

(* symbol *)

Lemma addz_Zadd_embed_eq : forall (x y : int),
  Z_of_int (intZmod.addz x y) = (Z_of_int x + Z_of_int y)%Z.
Proof.
  apply (@TBOpInj _ _ _ _ _ _ _ _ _ _ Op_addz).
Qed.

Trakt Add Symbol intZmod.addz Z.add addz_Zadd_embed_eq.

(* relation *)

Lemma eqint_eqZ_equiv : forall (x y : int), x = y <-> Z_of_int x = Z_of_int y.
Proof.
  apply (@TRInj _ _ _ _ Op_int_eq).
Qed.

Lemma eqint_Zeqb_equiv : forall (x y : int), x = y <-> (Z_of_int x =? Z_of_int y)%Z = true.
Proof.
  intros x y.
  refine (iff_trans (eqint_eqZ_equiv x y) _).
  symmetry.
  apply Z.eqb_eq.
Qed.

Trakt Add Relation 2 (@eq int) Z.eqb eqint_Zeqb_equiv.

Goal forall (x y : int), intZmod.addz x y = intZmod.addz y x.
Proof.
  trakt Z bool.
Abort.

(* ===== nat ==================================================================================== *)

(* embeddings in bool and Prop *)

Lemma nat_Z_gof_id : forall (n : nat), n = Z.to_nat (Z.of_nat n).
Proof.
  symmetry. apply Nat2Z.id.
Qed.

Lemma nat_Z_bool_fog_cond_id : forall (z : Z), (0 <=? z)%Z = true -> Z.of_nat (Z.to_nat z) = z.
Proof.
  intros z HPz.
  refine (Z2Nat.id z _).
  apply (Zle_bool_imp_le _ _ HPz).
Qed.
  
Lemma nat_Z_bool_cond_f_always_true : forall (n : nat), (0 <=? Z.of_nat n)%Z = true.
Proof.
  intros n.
  rewrite Z.leb_le.
  apply Nat2Z.is_nonneg.
Qed.
 
Trakt Add Embedding
  nat Z Z.of_nat Z.to_nat nat_Z_gof_id nat_Z_bool_fog_cond_id
    nat_Z_bool_cond_f_always_true.

Lemma nat_Z_Prop_fog_cond_id : forall (z : Z), (0 <= z)%Z -> Z.of_nat (Z.to_nat z) = z.
Proof.
  apply Z2Nat.id.
Qed.

Lemma nat_Z_Prop_cond_f_always_true : forall (n : nat), (0 <= Z.of_nat n)%Z.
Proof.
  apply Nat2Z.is_nonneg.
Qed.

Trakt Add Embedding
  nat Z Z.of_nat Z.to_nat nat_Z_gof_id nat_Z_Prop_fog_cond_id
    nat_Z_Prop_cond_f_always_true.

(* symbols *)

Lemma Natadd_Zadd_embed_eq : forall (n m : nat),
  Z.of_nat (n + m) = (Z.of_nat n + Z.of_nat m)%Z.
Proof.
  apply Nat2Z.inj_add.
Qed.

Trakt Add Symbol Nat.add Z.add Natadd_Zadd_embed_eq.

Lemma S_Zadd1_embed_eq : forall (n : nat), Z.of_nat (S n) = (1 + Z.of_nat n)%Z.
Proof.
  intros.
  rewrite Z.add_1_l.
  apply Nat2Z.inj_succ.
Qed.

Trakt Add Symbol S (Z.add 1%Z) S_Zadd1_embed_eq.

(* relations *)

Lemma Nateqb_Zeqb_equiv : forall (n m : nat), n =? m = (Z.of_nat n =? Z.of_nat m)%Z.
Proof.
  apply Z_of_nat_eqb_iff.
Qed.

Trakt Add Relation 2 Nat.eqb Z.eqb Nateqb_Zeqb_equiv.

Lemma eqnat_eqZ_equiv : forall (n m : nat), n = m <-> Z.of_nat n = Z.of_nat m.
Proof.
  symmetry.
  apply Nat2Z.inj_iff.
Qed.

Trakt Add Relation 2 (@eq nat) (@eq Z) eqnat_eqZ_equiv.

Lemma eqnat_Zeqb_equiv : forall (n m : nat), n = m <-> (Z.of_nat n =? Z.of_nat m)%Z = true.
Proof.
  intros x y.
  refine (iff_trans (eqnat_eqZ_equiv x y) _).
  symmetry.
  apply Z.eqb_eq.
Qed.

Trakt Add Relation 2 (@eq nat) Z.eqb eqnat_Zeqb_equiv.

Lemma Nateqb_eqnat_refl : forall (n m : nat), Nat.eqb n m = true <-> n = m.
Proof.
  apply Nat.eqb_eq.
Qed.

Trakt Add Relation 2 Nat.eqb (@eq nat) Nateqb_eqnat_refl.

Goal forall (n m : nat), Nat.eqb (S n + m) (m + S n) = true.
Proof.
  trakt Z Prop. (* or trakt Z bool. *)
Abort.

(* ===== decidable type ========================================================================= *)

Inductive E : Type :=
  | E0 : E.

Module E.
  Definition eqb (e e' : E) : bool :=
    match e, e' with
    | E0, E0 => true
    end.

  Lemma eq_eqb : forall (x y : E),
    x = y <-> eqb x y = true.
  Proof.
    intros [] []. split; intros; reflexivity.
  Qed.
End E.

Trakt Add Relation 2 (@eq E) E.eqb E.eq_eqb.

Goal forall (x : E), x = x.
Proof.
  trakt E bool.
Abort.

(* ===== uninterpreted function ================================================================= *)

Trakt Add Relation 2 (@eq nat) Nat.eqb (fun n m => iff_sym (Nateqb_eqnat_refl n m)).

Goal forall (f : nat -> nat) (n m : nat), f (S n + m) = f(m + S n).
Proof.
  (* trakt bool. *)
  trakt Z bool.
Abort.

(* ===== projections ============================================================================ *)

Lemma mulz_Zmul_embed_eq : forall (x y : int),
  Z_of_int (intRing.mulz x y) = (Z_of_int x * Z_of_int y)%Z.
Proof.
  apply (@TBOpInj _ _ _ _ _ _ _ _ _ _ Op_mulz).
Qed.

Trakt Add Symbol intRing.mulz Z.mul mulz_Zmul_embed_eq.

Lemma Posz_id_embed_eq : forall (n : nat), Z_of_int (Posz n) = Z.of_nat n.
Proof.
  apply (@TUOpInj _ _ _ _ _ _ _ Op_Posz).
Qed.

Trakt Add Symbol Posz (@id Z) Posz_id_embed_eq.

From mathcomp Require Import all_boot all_order all_algebra.
Import GRing.Theory.
Delimit Scope Z_scope with Z.

Lemma O_Z0_embed_eq : Z.of_nat O = Z0.
Proof. reflexivity. Qed.

Trakt Add Symbol O Z0 O_Z0_embed_eq.

Lemma one_Z1_embed_eq : Z_of_int 1%R = 1%Z.
Proof. reflexivity. Qed.

Trakt Add Symbol (1%R : int) (1%Z) one_Z1_embed_eq.

Lemma eqopint_eqint_equiv : forall (x y : int), x == y <-> x = y.
Proof.
  by move=> x y; split=> /eqP.
Qed.

Trakt Add Relation 2 (eq_op : int -> int -> bool) (@eq int) eqopint_eqint_equiv.

Trakt Add Relation 2 (@eq int) (@eq Z) eqint_eqZ_equiv.

Local Open Scope ring_scope.

Lemma intmul_Zmul_embed_eq : forall (x y : int),
  Z_of_int (intmul x y) = (Z_of_int x * Z_of_int y)%Z.
Proof.
  apply (@TBOpInj _ _ _ _ _ _ _ _ _ _ Op_int_intmul).
Qed.

Trakt Add Symbol (@intmul _) Z.mul intmul_Zmul_embed_eq.

Trakt Add Conversion GRing.add.
Trakt Add Conversion GRing.mul.
Trakt Add Conversion GRing.one.
Trakt Add Conversion intmul.
Trakt Add Conversion GRing.Zmodule.sort.

(* TO FIX *)
Goal forall (f : int -> int) (x : int), x == 4 = true -> f (2%:Z * x + 1) == f 5 = true.
Proof.
  (* Set Printing All. *)
  (* trakt Z Prop. *)
Abort.

Trakt Add Conversion preorderType.

Lemma Orderle_int_Zleb_equiv : forall (x y : int), x <= y = (Z_of_int x <=? Z_of_int y)%Z.
Proof.
  apply (@TBOpInj _ _ _ _ _ _ _ _ _ _ Op_int_le).
Qed.

Trakt Add Relation 2
  (@Order.le ring_display _)
  Z.leb
  Orderle_int_Zleb_equiv.

Goal forall (f : int -> int) (x : int), 1 <= x = true -> f x <= f x + x = true.
Proof.
  (* Set Printing All. *)
  trakt Z bool.
Abort.

(* ===== with logic ============================================================================= *)

Goal forall (f : int -> int) (x y : int) (b : bool),
  true = false || (b && false) || (x == x) && (f y == f y).
Proof.
  trakt Z Prop.
Abort.

(* ===== embeddings in source goal ============================================================== *)

Lemma Z_of_int_id_embed_eq : forall (x : int), Z_of_int x = Z_of_int x.
Proof. reflexivity. Qed.

Trakt Add Symbol Z_of_int (@id Z) Z_of_int_id_embed_eq.

Lemma Z_to_int_id_embed_eq : forall (x : Z), Z_of_int (Z_to_int x) = x.
Proof.
  intros. apply int_of_ZK.
Qed.

Trakt Add Symbol Z_to_int (@id Z) Z_to_int_id_embed_eq.

Goal forall (x y : int), Z_to_int (Z_of_int x + Z_of_int y)%Z = intZmod.addz y x.
Proof.
  trakt Z bool.
Abort.

(* ===== relation families ====================================================================== *)

From Stdlib Require Import Vectors.Vector.

Definition bitvector n := Vector.t bool n.

Module bitvector.
  Definition eqb (n : nat) (v v' : bitvector n) : bool :=
    @VectorEq.eqb bool Bool.eqb n n v v'.
    
  Definition eqb_eq : forall (n : nat) (v v' : bitvector n), eqb n v v' = true <-> v = v' :=
    @VectorEq.eqb_eq bool Bool.eqb
      (fun b b' => iff_sym (Bool.reflect_iff (b = b') (Bool.eqb b b') (Bool.eqb_spec b b'))).
End bitvector.

Trakt Add Relation 2
  (fun n => @eq (bitvector n))
  (fun n => bitvector.eqb n)
  (fun n v v' => iff_sym (bitvector.eqb_eq n v v')).

Trakt Add Relation 2
  (fun n => bitvector.eqb n)
  (fun n => @eq (bitvector n))
  bitvector.eqb_eq.

Goal forall s (v : bitvector s), v = v.
Proof.
  trakt bool.
  trakt Prop.
Abort.
