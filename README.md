Winterface
==========

Winterface language/obj-c-syntactic-sweetner. Simplify all that syntactic drivel and ramp up the power of ios apps

I've been coding for ages, this language is the one I've wanted to code in.

So far as the language implentation, so sorry, this code is nasty draft code having been tweaked as a scratch pad while designing the language.
I will rewrite as a clean winterface version. It runs slowly, but outputs correct obj-c++ code.


Basic process
-------------
Winterface takes .wi files

The WILibrary project is required (wi files for modules, apps are small), as is the BasicClassesCPP project (cpp files, obj-c is missing a lot of things)

The wi files are turned to obj-c++ files (h/pch/mm) and a html giving an overview of the code

Core principles
---------------
As far as possible wi files are unordered, so nothing much will break if you define something long after using it. There are small exceptions

It follows that all classes and methods are renentrant. The compiler won't complain if you have already defined such-and-such

Protocols can have method bodies and properties like the rest of us.

Links are a first class thing. Authors don't have posts since then one day you'll end up making posts have authors which will be a pain.
There are just links between authors and posts.

Syntax is minimal. So long as the input is unambiguous it's all good. WI won't expect you to type many keywords.

That said. WI mostly doesn't care about the bodies of methods. There is currently no obj-c parser, and there will never be a compiler in WI.

Safety doesn't come from restrictions, it comes from providing ways to do things safely.
Languages are missing key things that I want to use in my apps.

Clarity doesn't come from simple verbose code commented well. It comes from code never needing to implement things outside its scope. It comes from never hacking things simply because the clean way is restricted or hard.



Quick syntax
------------

### Classes/Protocols

Make a class:

`A`

Make a protocol:

`<A>`

Indenting is used, until you happen to be in a bracket.

### Properties
Make a property

(prefer)

```
A
  A a=A.new
```

or

```
A A a=A.new
```

or if you insist

```
A {
A a=A.new
}
```

Make a getter property

```
A
  A a
    {return(A.new);}
```

Make a getter/setter property

```
A
  A a
    {return([A theMD:self]);}
    -v{[A setTheMD:v for:self];}
```
    
Weak initialized ivar property with getter and setter
(the initializer is placed in an object starter method)

```
A 
  A a=[A new]
    {return(theivar);}
    -v{theivar=v;}  (ivar=theivar, weak)
```


### Methods
Make a method

(prefer)

```
A
  -(void)fn
    auto_md()
```

(also good)

```
A
  -(void)fn {
    auto_md()
  }
```

brackets may be required for multi-line selectors:

```
A
  -(void)fn:(id)a
    b:(id)b
    {
      make_md(a,b);
    }
```
        
Methods and classes are reentrant throughout the codebase, use @integer for ordering (this will likely change I guess, 'til then for int literals use @(1))

```
A
    -(void)fn {second();}
    -(void)fn {@-1 first();}
A
    -(void)fn {@1 third();}
```
    
Protocols will pass their methods on to conforming classes

```
<A>
    -(void)fn {second();}
    -(void)fn {@-1 first();}
A<A>
    -(void)fn {@1 third();}
```

### Links
Links are easy, they can be:
* one-to-one ( -- )
* one-to-set ( -s< or -< )
* one-to-array ( -a< )
* one-to-dictionary ( -d< )
* set-to-set ( >s< )

The singular form is always used when specifying the name of the property. For the moment, for predictability's sake, the plural form is just that with an 's' afterwards, so if possible use a property name that won't mangle (mental note TODO).

You specify your own name, the relationship, then the property.
Super minimally to make each A link to a B, so that each A has a property 'b' and each B has a property 'a'

`A a -- B b`

Or more typically in a class defn

```
A
    a -- B b
```

Links have enforced consistancy, so that if you set mya.b=someb, then someb.a==mya and the old someb.a is set to nil

or in

`A a -d< B b`

Setting `mya.bs[@"md"]=someb` will make `someb.a==mya`
If olda is the old `someb.a`, then also `olda[@"md"]==nil`
At all times `someb.keyInA` is its key in the dictionary (i.e. `@"md"`)
This key is writable, so `someb.keyInA=@"md is done"` will do what you'd expect 
(i.e. `mya.bs[@"md"]==nil` and `mya.bs[@"md is done"]==someb`)

Similarly for arrays with integers as keys, though arrays will need to jostle indexes after insertions/removals, where dictionaries don't have to so much
In the case of an array, keyInA becomes indexInA

All but -< can be reversed

`B bs >d- A a`

The owner is the one with the ~

`A owner ~- B child`

will cause the B to have only a weak refernce to the a, where the A holds on strongly to the B

Similarly for arrays, dictionaries, sets

`A owner ~< B children`

For obvious reasons I haven't put in a doubly strong ownership, but doubly weak is all good

Also the children can own the parent (which is fantastically useful)

`A parent -a~< B toddlers`


Protocols can also have links, because they should, and it can be very useful:

```
<A> a -- B b

<Node> parent -< <Node> child
```

Properties also add convenience/strong-typing methods to the class to make the code readable and safe since id isn't used in the signature:

```
A
    toddler ~a< A cake
    -(void)bake {[toddler addCake:Cake.new];}
    -(void)cleanKitchen {[toddler removeAllCakes];}
```

See the PropXX.wi files in Winterface/Wis/ for implementations.

Indented lines after the link are considered part of the linked class, allowing the top of a file to declare (and implement) most of the data model that the file/app will be dealing with:

```
User 
    user ~< Sock sock
    user ~< Shirt shirt
        shirt ~- Collar collar
    author ~d< Book book
        titleFor ~- NSString title
        chapterIn ~a< BookChapter chapter
```


### Atomic models
A property or link may be backed by an atomic model. The syntax is more taxing but the goodies are many

```
A
    A fluid >> atomic
        = nil
```

(the =nil/=0/=NULL initializer will not produce any code but is required to avoid a wi warning, variables should be initialized by people, wi doesn't assume things should all just start as 0)

Say we had variable somea, we may tweak and read `somea.fluid` as we see fit, and results will immediately reflect in its state.
It is backed by somea.atomic, which will efficiently notice that it needs an update when somea.fluid changes, and will alter it's own state along with all other such atomic property backers at 'commit' time when the ios run loop has a break.

In practice this means that we may attach delegates to somea.atomic, yet not have them be constantly updated.
It means that a single property may determine the rows in a table, with the fluid value indicating what will be (say for adding a cell), and the atomic version indicating what actually is (say for looking at the contents of a clicked cell).
Importantly, since the atomic property value is immutable, synchronization isn't needed. This is a chief concern with tables, say if a notification adds a row while the table is reloading

For properties:

```
<TableModel>
    _table>>table   ~a<   <SectionModel> _section>>section
        _section>>section   ~a<   <CellModel> _cell>>cell
```

makes for a fully consistent model which provides a fluid interface (go on, change _table/_sections/_cells as you like) but which if hooked up to a table library (see wiLibrary for a good one) will update the table at a convenent time and always reflect the actual state of the table in table/sections/cells properties.

i.e. [[mytable sectionAtIndex:1] cellAtIndex:2] will be the actual cell at path 1,2

Writing to an atomic backer will transparently write to the fluid version.
So [mytable removeSectionAtIndex:0] won't affect mytable.sections until the table is actually updated, but mytable._sections will read the change immediately.


### System classes
Adding things to System classes adds them to the WI's category of the class,

```
NSObject
    -(NSString*)myDescription
        return([@"my " stringByAppendingString:self.description]);
```

For the moment you can't add ivars, I'll fix this soon.


### Code insertion
Often you may want to add code to the output obj-c++ files.
to do this use

```
AnyClass__I_use_Globals
    -
        #define SEVENTEEN_W_TIMEBOMB 17.00001
```

There are a few variations depending on where you want the code:

```
Globals
    -iface
        //included everywhere
        extern void g_fn();
        extern void *g_vp;
    -impl 
        //compiled once
        void g_fn() {}
        void *g_vp=(void*)0xbadc0de;
```

The each version is a special case to be used sparingly, but has the potential to really help in the right situation:

```
    -each
        // compiled into the class with class name/type placeholders substituted
        __Class__ *singleton__ClassName__=nil;
```

At present the each version inserts obj-c++ code, rather than wi, I'd like to be able to insert wi customized per class some time in the future
Of course a protocol can declare these too:

```
<Model>
    -each
        #define __ClassName__ModelKey @"__ClassName__"
User<Model>
Post<Model>
```


tbc



    
