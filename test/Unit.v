From Trakt Require Import Trakt.

Section IssuePanic.

  From Stdlib Require Import Vector ZArith.

  Lemma nat_Z_FBInverseProof :
    forall (n : nat), n = Z.to_nat (Z.of_nat n).
  Proof. Admitted.

  Lemma nat_Z_BFPartialInverseProof_bool :
    forall (z : Z), (0 <=? z)%Z = true -> Z.of_nat (Z.to_nat z) = z.
  Proof. Admitted.

  Lemma nat_Z_ConditionProof_bool :
    forall (n : nat), (0 <=? Z.of_nat n)%Z = true.
  Proof. Admitted.

  Trakt Add Embedding
      (nat) (Z) (Z.of_nat) (Z.to_nat)
      (nat_Z_FBInverseProof) (nat_Z_BFPartialInverseProof_bool) (nat_Z_ConditionProof_bool).

  Goal forall (a b c: Vector.t nat 2%nat), (c = a) -> (b = c).
  Proof.
    Fail trakt Z bool.
    try (trakt Z bool).
  Abort.

End IssuePanic.

Section Issue11.

  Variable P : nat -> Prop.
  Variable P' : nat -> bool.
  Hypothesis P_P' : forall x, P x <-> P' x = true.
  Trakt Add Relation 1 P P' P_P'.

  (* In this example, it is incorrect to replace P with P' *)
  Goal forall f : nat -> Prop, (forall r : nat, f r = P r) -> True.
  Proof.
    trakt bool.
  Abort.

  (* When the context around P is an equivalence, it is correct *)
  Goal forall f : nat -> Prop, (forall r : nat, f r <-> P r) -> True.
  Proof.
    trakt bool.
  Abort.

End Issue11.
