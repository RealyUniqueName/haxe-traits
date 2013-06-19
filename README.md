Traits for Haxe
===========

This small macro allows to reuse code in different classes, which can't extend each other.
Basic functionality right now.

Features:
----
* Static vars / methods inheritance
* Traits methods are copied to descendant class if class does not have fields with such names already

Restrictions:
* Can't follow imports yet. So you better use fully qualified class names in traits code