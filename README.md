DEPRECATED
===========
It is not recommended to use this project anymore.

Traits for Haxe
===========

This macro allows to reuse code in different classes, which can't extend each other.


Features:
----
* Static vars / methods inheritance (even inlined).
* Multiple inheritance
* "Lazy" interfaces: traits methods are copied to descendant class, so you don't need to write implementation in each class, which implements trait. But you still can skip implementation of some methods in trait to force each descendant implement these methods (It's a sort of "classic" abstracts from Java or PHP)
* Ability to "override" trait's methods


Hints:
----
* Access descendant class in trait's code via [`traits.Trait.self()`](https://github.com/RealyUniqueName/haxe-traits/blob/master/examples/all_in_one/people/jobs/TChef.hx#L20)
* In overriden methods call "super" methods via [`traits.Trat.parent(TTraitClass).someMethod()`](https://github.com/RealyUniqueName/haxe-traits/blob/master/examples/all_in_one/people/Jack.hx#L44) (like `super.someMethod()` for normal inheritance)
* In trait's code you can access fields, which are not declared in trait, but will be declared in descendant class [example](https://github.com/RealyUniqueName/haxe-traits/blob/master/examples/all_in_one/people/jobs/TPostman.hx#L24)


Installation:
----
`haxelib install traits`

Basic example:
----
```Haxe
interface TWorker extends traits.ITrait{
    public function work() : Void {
        trace("I'm working!");
    }
}
```
```Haxe
interface TReader extends traits.ITrait{
    public function read() : Void {
        trace("I'm reading!");
    }
}
```
```Haxe
class Test implements TWorker implements TReader {
    public function new() : Void {
        this.work(); //output: "I'm working!"
        this.read(); //output: "I'm reading!"
    }
}
```
