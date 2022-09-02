# Knight2.0-beta Changelog
**NOTE**: This _is not_ the official knight2.0 changelog. Most of the changes mentioned in here will be the same to knight2.0, but some may be tweaked.

## TL;DR
- New features:
	- Added lists
	- Added `@` (empty list literal function)
	- Added `,` (boxing function)

- Removed features:
	- `{`, `}`, `[`, and `]` are no longer whitespace, and are undefined instead.
	- `EVAL` is now optional
	- `` ` `` is now optional
	- variable names now have a required max length of 255, not 65535

- Feature updates:
	- `LENGTH` now converts its argument to a list
	- `+` now accepts lists and concatenates them
	- `*` now accepts lists and replicates them
	- `^` now accepts lists and joins them
	- `<`, `>`, and `?` now accept lists and behave like most other langs
	- `GET` Now accepts lists (length of 0 gets _that_ element)
	- `SUBSTITUTE` renamed to `SET`
	- `SET` Now accepts lists 

# New Features
## Lists
It's what we've all been waiting for: Lists. Lists are immutable, heterogeneous data structures that can hold elements of arbitrary types.

### Conversions
- `null -> list`: Empty list
- `bool -> list`: Empty list for `FALSE`, a list of just `TRUE` for `TRUE`.
- `int -> list`: List of digits; undefined if integer is negative. (maybe? you could just make abs?)
- `string -> list`: List of chars

- `list -> bool`: Whether list is nonempty
- `list -> int`: Length of list
- `list -> string`: Elements of the list joined with a newline

### List Construction
To keep in line with the fixed arity approach of Knight, there are no "list literals". Instead, there's a few ways to create lists:
```
@            # empty list
,123         # list of length one, just `123`
+ @ 1234     # a list of `1`, `2`, `3`, and `4`
+ @ "ABC"    # a list of `"A"`, `"B"`, and `"C"`
+ ,"A" ,TRUE # a list of `"A"` and `TRUE`
```

## `@()` Function
Just like `TRUE` is the nullary function that returns a true value, `@` is the nullary function that returns an empty list vlaue.

## `,(unchanged)` Function
The box function takes its argument and returns a list with just that argument as the element. In python terms, this'd be `def box(x): return [x]`.

# Removed Features
## `{`, `}`, `[`, and `]`'s removal
Originally, I made all forms of parens as whitespace to be a visual aid. The idea was you could, eg, use `{ ... }` to surround `BLOCK`/`IF`/`WHILE` bodies, and `()`/`[]` for grouping complex expressions.

After having spent over a year with Knight, and seen how other people write the language, I've come to the realization that nobody actually uses `[]` or `{}` in this way: Most of the time, they'll simply indent to indicate nested blocks, and will only use `()` in complex expressions. 

As such, they're now removed from the language spec, which frees them up to be used for list/dictionary literals if people want.,

## `EVAL` is optional
`EVAL` has always been the trouble child of Knight: It made a lot of different implementation strategies clunky, if not impossible. With it's removal, you now no longer need to bundle the parser with the runtime or keep track of variable names.

As a part of this, variable names now no longer have a maximum required length of 65535; instead, implementations need only support names up to 255 characters long. Since `EVAL` and dynamic variable names was used previously to emulate lists, longer names were necessary. Now, the limit has been lowered to a more reasonable requirement.

## `` ` `` is optional
Like `EVAL`, `` ` `` has also been a trouble child of knight: It was very much _not_ cross-platform. It was undefined whether shell expansion happened, what commands existed, which shell (if any) was used, what happened to nonzero status codes or stderr, etc. It also means some languages simply could not implement knight (such as sed or browser js). So, because of all the compatibility issues, `` ` `` is now marked as optional.

# Feature Updates

## `LENGTH` converts to a list
Instead of implicitly converting its argument to a string and then finding the length, `LENGTH` will now coerce to a list. It'll function identically for strings and nonnegative integers, but `NULL`, `TRUE`/`FALSE`, and negative integers will now have different conversions. `NULL` and `FALSE` will now be zero, with `TRUE` being one (and negative integers undefined).

## `+` now concatenates lists
`+` now accepts lists, and behaves nearly identically to strings: If the first argument to `+` is a list, then the second is converted to a list, and a new list with the contents of both are returned.

## `*` now replicates lists
Just like `*` replicates strings by a nonnegative integer, `*` will replicate lists by nonnegative integers.

## `^` now joins lists
This is the `.join` function for lists, converting each element to a string and concatenating them together with the second argument interspersed.

## `<`, `>`, and `?`
The `<`, `>`, and `?` functions now all accept lists, and behave like most other languages: Comparing element-wise. For `<` and `>`, if all elements are equal, the smaller list is lesser than the larger.

## `GET` now accepts lists
`GET` for lists functions almost identically to that of strings: you return a sublist of the specific range. However, if the length parameter is zero, instead of returning an empty list, only the element at that specific index is returned.

Example:
```
; = list + (,"foo") (,"bar") (,"baz")
; GET list 0 1 #=> a list just containing `"foo"`
; GET list 1 2 #=> a list containing `"bar"` and `"baz"`
: GET list 1 0 #=> the string `"bar"`
```

## `SET` now accepts lists
`SET` for lists acts identically to strings: the second and third arguments are converted to integers (and are the start and length), and the fourth argument is coerced to a list. Notably, if the length is `0`, this functions as an "insert" command, and not how `GET` handles a length of zero.
