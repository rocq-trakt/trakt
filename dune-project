(lang dune 3.21)

(using rocq 0.11)

(name rocq-trakt)

(generate_opam_files)

(source
 (github rocq-trakt/trakt))

(license LGPL-3.0-or-later)

(authors "Enzo Crance <enzo.crance@inria.fr>")

(maintainers
 "Chantal Keller <ckeller@lmf.cnrs.fr>"
 "Vincent Lafeychine <vincent.lafeychine@proton.me>")

(package
 (name rocq-trakt)
 (synopsis
  "A generic goal preprocessing tool for proof automation tactics in Rocq")
 (description
  "Trakt is a Coq plugin that provides a new Coq tactic, trakt, for preprocessing goals before handing them to a proof automation tactic, as well as Coq commands to fill a knowledge database before calling the tactic. Drawing inspiration from the zify tactic in the Coq standard library, it acts like a type-level funnel by casting all the possible values in the goal into a given target type. It can also express logic in Prop or bool according to the user's choice. The translation is implemented in Coq-Elpi. It is certifying (it leaves no proof obligation), generic (the translation does not focus on a precise theory, it is determined by the parameters and user knowledge), and efficient (it tries to make sparse use of Coq conversion).")
 (tags
  ("category:Computer Science/Decision Procedures and Certified Algorithms/Decision procedures"
   "category:Miscellaneous/Coq Extensions"
   "keyword:automation"
   "keyword:elpi"
   "date:2022-05-16"
   "logpath:Trakt"))
 (depends
  (rocq-elpi
   (>= 2.5.2))
  (rocq-core
   (>= 9.0.0))))
