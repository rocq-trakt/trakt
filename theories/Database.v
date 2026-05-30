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

From elpi Require Import elpi.

From Stdlib Require Import Bool.

Lemma and_impl_morphism : forall {A B A' B' : Prop},
  (A' -> A) -> (B' -> B) -> (A' /\ B' -> A /\ B).
Proof.
  intros A B A' B' HA HB [ProofA' ProofB'].
  apply (conj (HA ProofA') (HB ProofB')).
Qed.

Lemma andb_and_impl : forall (x y : bool), x && y = true -> x = true /\ y = true.
Proof.
  intros [] []; cbv [andb].
  1: split; reflexivity.
  all: discriminate.
Qed.

Lemma and_andb_impl : forall (x y : bool), x = true /\ y = true -> x && y = true.
Proof.
  intros [] []; cbv [andb]; try (intros [_ H]; exact H).
  intros [H _]; exact H.
Qed.

Lemma or_impl_morphism : forall {A B A' B' : Prop},
  (A' -> A) -> (B' -> B) -> (A' \/ B' -> A \/ B).
Proof.
  intros A B A' B' HA HB [ProofA' | ProofB'].
  - left. apply (HA ProofA').
  - right. apply (HB ProofB').
Qed.

Lemma orb_or_impl : forall (x y : bool), x || y = true -> x = true \/ y = true.
Proof.
  intros [] []; cbv [orb]; try (intro H; left; exact H).
  intro H; right; exact H.
Qed.

Lemma or_orb_impl : forall (x y : bool), x = true \/ y = true -> x || y = true.
Proof.
  intros [] []; cbv [orb]; try reflexivity.
  intros [H | H]; exact H.
Qed.

Lemma not_impl_morphism : forall {A A' : Prop},
  (A -> A') -> (~ A' -> ~ A).
Proof.
  intros A A' HA ProofNotA' ProofA.
  apply (ProofNotA' (HA ProofA)).
Qed.

Lemma negb_not_impl : forall (x : bool), negb x = true -> ~ x = true.
Proof.
  intros []; cbv [negb].
  intro H; discriminate H.
  intros _ H; discriminate H.
Qed.

Lemma not_negb_impl : forall (x : bool), ~ x = true -> negb x = true.
Proof.
  intros []; cbv [negb]; auto.
Qed.


Elpi Db logic.db lp:{{
  func copy term -> term.
}}.

From Trakt.Elpi Extra Dependency "types.elpi" as types.
Elpi Accumulate logic.db File types.

Elpi Accumulate logic.db lp:{{
  logical-connector
    {{ and }} {{ andb }} [covariant, covariant]
    {{ and_impl_morphism }} {{ andb_and_impl }} {{ and_andb_impl }}.

  logical-connector
    {{ or }} {{ orb }} [covariant, covariant]
    {{ or_impl_morphism }} {{ orb_or_impl }} {{ or_orb_impl }}.

  logical-connector
    {{ not }} {{ negb }} [contravariant]
    {{ not_impl_morphism }} {{ negb_not_impl }} {{ not_negb_impl }}.
}}.

Lemma iff_impl_ind : forall {A B A' B' : Prop},
  (A' -> A) -> (A -> A') -> (B' -> B) -> (B -> B') -> (A' <-> B') -> (A <-> B).
Proof.
  intros A B A' B' HA1 HA HB1 HB [HAB' HBA'].
  split.
  - intro a; exact (HB1 (HAB' (HA a))).
  - intro b; exact (HA1 (HBA' (HB b))).
Qed.

Lemma iff_Booleqb_impl : forall (x y : bool), x = true <-> y = true -> Bool.eqb x y = true.
Proof.
  intros [] []; cbn [eqb]; intros [H1 H2]; auto.
Qed.

Lemma Booleqb_iff_impl : forall (x y : bool), Bool.eqb x y = true -> x = true <-> y = true.
Proof.
  intros [] []; cbn [eqb]; intro H; split; auto.
Qed.

Elpi Db embeddings.db lp:{{

pred embedding
  o:term, % source type
  o:term, % target type
  o:term, % E: forward embedding function
  o:term, % RE: backward embedding function
  o:term, % proof that λx.RE (E x) is an identity
  o:term, % proof that λx.E (RE x) is an identity if the condition is true for x
  o:(option term), % the logic used to express the condition (bool or Prop)
  o:(option term), % the embedding condition (e.g. positivity for nat)
  o:(option term). % a proof that this condition is always true for any embedded term

 }}.
Elpi Db symbols.db lp:{{

  pred symbol_
  o:term,        % S: source symbol
  o:option term, % target embedding type when translating the symbol
  o:term,        % S': target symbol
  o:term.        % proof that embedding S gives S'

 }}.
Elpi Db relations.db lp:{{
  pred relation
  o:term,        % F: head term of the source relation
  o:option term, % target embedding type when translating the relation
  o:term,        % output logic of R (bool or Prop)
  o:term,        % R: full source relation
  o:int,         % number of non-type arguments in R
  o:term,        % R': target relation
  o:term,        % output logic of R'
  o:int,         % number of prefix type arguments not involved in the proof
  o:term.        % proof that embedding R is equivalent to R'

 }}.
Elpi Db conversion.db lp:{{
  pred conversion-allowed o:term.
}}.
