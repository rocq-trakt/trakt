(*******************************************************************************)
(*                           *                     Trakt                       *)
(*  _______        _    _    *            Copyright (C) 2022 MERCE             *)
(* |__   __|      | |  | |   *     (Mitsubishi Electric R&D Centre Europe)     *)
(*    | |_ __ __ _| | _| |_  *        Enzo Crance <enzo.crance@inria.fr>       *)
(*    | | '__/ _` | |/ / __| ***************************************************)
(*    | | | | (_| |   <| |_  * This file is distributed under the terms of the *)
(*    |_|_|  \__,_|_|\_\\__| *   GNU Lesser General Public License Version 3   *)
(*                           *  (see LICENSE file for the text of the license) *)
(*******************************************************************************)

From Stdlib Require Import Bool.

Lemma is_true_symmetry : forall (b : bool), b = true -> true = b.
Proof.
  intros b H. rewrite H. reflexivity.
Qed.

Lemma is_true_symmetry_contra : forall (b : bool), true = b -> b = true.
Proof.
  intros b H. rewrite H. reflexivity.
Qed.

Lemma false_negb_symmetry : forall (b : bool), negb b = true -> false = b.
Proof.
  intros []; cbv [negb].
  - intro H; apply H.
  - reflexivity.
Qed.

Lemma false_negb_symmetry_contra : forall (b : bool), false = b -> negb b = true.
Proof.
  intros []; cbv [negb].
  - intro H; apply H.
  - reflexivity.
Qed.

Lemma false_negb : forall (b : bool), negb b = true -> b = false.
Proof.
  intros []; cbn [negb]; auto.
Qed.

Lemma false_negb_contra : forall (b : bool), b = false -> negb b = true.
Proof.
  intros []; cbn [negb]; auto.
Qed.

Lemma refl_true_impl : forall {T : Type} {a : T}, a = a -> True.
Proof. reflexivity. Qed.

Lemma refl_true_impl_contra : forall {T : Type} {a : T}, True -> a = a.
Proof. reflexivity. Qed.

Lemma false_bool_impl : false = true -> False.
Proof.
  intro H; discriminate H.
Qed.

Lemma false_bool_impl_contra : False -> false = true.
Proof.
  contradiction.
Qed.

Lemma lift_eq_to_impl : forall {T : Type} {x y : T} (Context : T -> Prop),
  x = y -> (Context y -> Context x).
Proof.
  intros T x y Context.
  intro H; rewrite <- H. intro HCx. apply HCx.
Qed.

Lemma lift_eq_to_impl_contra : forall {T : Type} {x y : T} (Context : T -> Prop),
  x = y -> (Context x -> Context y).
Proof.
  intros T x y Context.
  intro H; rewrite -> H. intro HCy. apply HCy.
Qed.

Lemma impl_morph_impl : forall {A B A' B' : Prop},
  (A -> A') -> (B' -> B) -> ((A' -> B') -> (A -> B)).
Proof.
  intros A B A' B' HAc HB H' ProofA.
  apply (HB (H' (HAc ProofA))).
Qed.

Lemma implb_impl_impl : forall (x y : bool), implb x y = true -> (x = true -> y = true).
Proof.
  intros [] []; simpl; auto.
Qed.

Lemma impl_implb_impl : forall (x y : bool), (x = true -> y = true) -> implb x y = true.
Proof.
  intros [] []; simpl; auto.
Qed.

Lemma iffRL : forall {P Q : Prop}, P <-> Q -> (Q -> P).
Proof.
  intros P Q [_ H]; exact H.
Qed.

Lemma iffLR : forall {P Q : Prop}, P <-> Q -> (P -> Q).
Proof.
  intros P Q [H _]; exact H.
Qed.
