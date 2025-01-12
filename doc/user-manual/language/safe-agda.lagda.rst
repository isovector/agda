..
  ::
  module language.safe-agda where

.. _safe-agda:

*********
Safe Agda
*********

By using the option :option:`--safe` (as a pragma option, or on the
command-line), a user can specify that Agda should ensure that
features leading to possible inconsistencies should be disabled.

Here is a list of the features :option:`--safe` is incompatible with:

* ``postulate``; can be used to assume any axiom.

* :option:`--allow-unsolved-metas`; forces Agda to accept unfinished
  proofs.

* :option:`--allow-incomplete-matches`; forces Agda to accept
  unfinished proofs.

* :option:`--no-positivity-check`; makes it possible to write
  non-terminating programs by structural "induction" on non strictly
  positive datatypes.

* :option:`--no-termination-check`; gives loopy programs any type.

* :option:`--type-in-type` and :option:`--omega-in-omega`; allow the
  user to encode the Girard-Hurken paradox.

* :option:`--injective-type-constructors`; together with excluded
  middle leads to an inconsistency via Chung-Kil Hur's construction.

* :option:`--guardedness` together with :option:`--sized-types`;
  currently can be used to define a type which is both inductive and
  coinductive, which leads to an inconsistency. This might be fixed in
  the future.

* :option:`--experimental-irrelevance` and
  :option:`--irrelevant-projections`; enables potentially unsound
  irrelevance features (irrelevant levels, irrelevant data matching,
  and projection of irrelevant record fields, respectively).

* :option:`--rewriting`; turns any equation into one that holds
  definitionally.  It can at the very least break convergence.

* :option:`--cubical` together with :option:`--with-K`; the univalence
  axiom is provable using cubical constructions, which falsifies the K
  axiom.

* The ``primEraseEquality`` primitive together with
  :option:`--without-K`; using ``primEraseEquality``, one can derive
  the K axiom.

* :option:`--allow-exec`; allows system calls during type checking.

* :option:`--no-load-primitives`; allows the user to bind the sort
  and level primitives manually.

The option :option:`--safe` is coinfective (see
:ref:`consistency-checking-options`); if a module is declared safe,
then all its imported modules must also be declared safe.
