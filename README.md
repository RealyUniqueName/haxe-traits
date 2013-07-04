Traits for Haxe
===========

This macro allows to reuse code in different classes, which can't extend each other.

Features:
----
* Static vars / methods inheritance (even inlined)
* Multiple inheritance
* "Lazy" interfaces: traits methods are copied to descendant class, so you don't need to write implementation in each class, which implements trait. But you still can skip implementation of some methods in trait to force each descendant implements these methods (It's a sort of "classic" abstracts from Java or PHP)
* Ability to "override" trait's methods


Tips:
----
* Access descendant class in trait's code via [`traits.Trait.self()`](https://github.com/RealyUniqueName/haxe-traits/blob/master/examples/all_in_one/people/jobs/TChef.hx#L20)
* In overriden methods call "super" methods via [`traits.Trat.parent(TTraitClass).someMethod()`](https://github.com/RealyUniqueName/haxe-traits/blob/master/examples/all_in_one/people/Jack.hx#L44) (like `super.someMethod()` for normal inheritance)

