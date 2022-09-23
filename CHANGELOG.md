# Knight2.0 Changelog from Knight1.2

This is the complete list of the differences between Knight1.2 and Knight2.0. For exact semantics of the different functions, see the specs.

## TL;DR
- New features:
	- Added lists
	- Added `@` (empty list literal function)
	- Added `,` (boxing function)
	- Added `[` (head function)
	- Added `]` (tail function)
	- `DUMP`'s output has been standardized
	- Parenthesis Grouping
	- Extensions expanded
	- `ASCII` and `~` have been added (they were added in 1.2)

- Removed features:
	- Command Line arguments are now optional
	- `{` and `}` are no longer whitespace, and are undefined instead.
	- `EVAL` is now optional.
		- Variable names now have a required max length of 127, not 65535.
	- `$` (previously named `` ` ``) is now optional.
	- Sections in the specs aren't numbered anymore.

- Feature updates:
	- Unit tester has been reworked
	- `LENGTH` now converts its argument to a list
	- `+` now accepts lists and concatenates them
	- `*` now accepts lists and replicates them
	- `^` now accepts lists and joins them
	- `<`, `>`, and `?` now accept lists and behave like most other langs
	- `GET` Now accepts lists
	- `SET` (previously named `SUBSTITUTE`) Now accepts lists
	- `%` only requires supporting nonnegative arguments.
	- `^` only requires supporting nonnegative exponents.

# New Features
## Lists
It's what we've all been waiting for: Lists. Lists are immutable, heterogeneous data structures that can hold elements of arbitrary types.

### Conversions
- `null -> list`: Empty list
- `bool -> list`: Empty list for `FALSE`, a list of just `TRUE` for `TRUE`.
- `int -> list`: List of digits. If the int is negative, each digit is negative.
- `string -> list`: List of characters in the string

- `list -> bool`: Whether list is nonempty
- `list -> int`: Length of list
- `list -> string`: Elements of the list joined with a newline

### List Construction
To keep in line with the fixed arity approach of Knight, there are no "list literals". Instead, you create lists either via `@` (empty list), `,` (create a list of just length one) or "`+ @ ...`", coerce to a list:
```
@            # []
,123         # [123]
+ @ 1234     # [1, 2, 3, 4]
+ @ "ABC"    # ["A", "B", "C"]
+ ,"A" ,TRUE # ["A", true]
```

## `@()` Function
Just like `TRUE` is the nullary function that returns a true value, `@` is the nullary function that returns an empty list value.

## `,(unchanged)` Function
The box function takes its argument and returns a list with just that argument as the element. In python terms, this would be `def box(x): return [x]`.

## `[(unchanged)` Function
This function returns either the first element in a list, or the first character in a string (depending on its argument). It's undefined behaviour if the first argument is empty.

## `](unchanged)` Function
This function returns either a list of everything _but_ the first element, or a string of everything _but_ the first character. It's undefined behaviour if the first argument is empty.

## `DUMP`'s output has been standardized
Previously, `DUMP`'s output was pseudo-standardized: The specs left it up to the implementation, but the unit tester required it to be in a specific format. Now `DUMP`'s output is standardized:

- **integer**: Simply the integer itself
- **null**: Just `null`
- **boolean**: Either `true` or `false`
- **string**: A `"`, followed by the escaped contents of the string, followed by `"`. The escaped characters are escaped like they are in C (`\n`, `\r`, `\t`, `\\`, and `\"`.)
- **list**: A `[`, followed by each element separated by `, `, followed by a `]`.

## Parenthesis Grouping
In Knight2.0, the round parens (`()`) are now used to enclose an expression: It's undefined behaviour to encountered unmatched or non-enclosing parens in the source code. This addition exists just so more advanced implementations can do parenthesis matching if they want to: Normal implementations can continue to treat parens as whitespace. (Illegal parens are undefined behaviour, so implementations can choose to ignore them.)

## Extensions Expanded
The extensions section used to be a bit sad, only throwing out a few ideas. It's been completely reworked, going into a lot more detail on ideas for extensions. Like always, the extensions are entirely optional and aren't required for spec compliance.

## `ASCII` and `~`
These were present in 1.2, but not Knight1.0, so it's worth mentioning. `ASCII` converts a character to its integer representation or vice versa, and `~` is numeric negation.

# Removed Features
## Command line Arguments are optional
Previously, Knight implementations were required to support `-e <expr>` and `-f <file>`. However, this precluded implementations in languages which didn't have access to command-line arguments (such as browser-only javascript,  sed, etc.) As such, they're now optional.

However, the unit tester still expects an executable that responds to `-e <expr>`.

## `{`, `}`'s removal
Originally, all forms of parens (`[]{}()`) were included as whitespace to be a visual aid. The idea was one could, eg, use `{ ... }` to surround `BLOCK`/`IF`/`WHILE` bodies, and `()`/`[]` for grouping complex expressions.

However, after having spent over a year with Knight, and seen how other people write the language, I've come to the realization that nobody actually uses `[]` or `{}` in this way: Most of the time, they'll simply indent to indicate nested blocks, and will only use `()` in complex expressions. 

As such, they've now been repurposed: `()` still are used for grouping, but now must group valid expression (see [Parenthesis Grouping](#parenthesis-grouping) above); `[` and `]` are now functions (head and tail respectively); the curly braces (`{}`) are now undefined, freeing them up to be used for list/map literals if implementations want.

## `EVAL` is optional
`EVAL` has always been the trouble child of Knight: It made a lot of different implementation strategies clunky, if not impossible. With it's removal, implementations now no longer need to bundle the parser with the runtime or keep track of variable names.

As a part of this, variable names now no longer have a maximum required length of 65535; instead, implementations need only support names up to 127 characters long. Since `EVAL` and dynamic variable names was used previously to emulate lists, longer names were necessary. Now, the limit has been lowered to a more reasonable requirement.

## `` ` `` is optional (and renamed to `$`)
Like `EVAL`, `` ` `` has also been a trouble child of knight: It was very much _not_ cross-platform. It also had a _lot_ of undefined whether: does shell expansion happened, what executables existed, which shell (if any) was used, what happened to nonzero status codes or stderr, etc. It also means that language without access to the shell simply could not implement Knight. So, because of all the compatibility issues, `` ` `` is now marked as optional.

(It's been renamed to `$`, because `` ` `` is now a suggested extension for string interpolation.)

The vast majority of the time, `` ` `` was bundled with `EVAL` as a sort of pseudo-import: ``EVAL ` +"cat " filename``. Now, there's an optional extension (`USE`) which does this.

## Sections in the specs aren't numbered anymore
The numbering of sections was a bit of a pain: You'd have to always remember which section numbers corresponded to which parts, adding or removing sections was difficult, etc. (This is especially important since `EVAL` and `` ` `` were removed: Would we reuse their number, or keep it marked as blank?) So now sections are unnumbered, and are just identified by their name.

# Feature Updates

## Unit tester has been reworked
Previously, the unit tester would only test functions to see if their behaviour was correct. Now, the unit tester also for syntax parsing, type conversions, and variable usages.

Additionally, the command-line interface has been slightly updated: You no longer need to remember section numbers, and can simply do `--sections=+,*`.

## `LENGTH` converts to a list
Instead of implicitly converting its argument to a string and then finding the length, `LENGTH` will now coerce to a list. It'll function identically for strings and nonnegative integers (negative integers would include the `-` in the length), but `NULL` and `TRUE`/`FALSE`. `NULL` and `FALSE` will now be zero, with `TRUE` being one.

## `+` now concatenates lists
`+` now accepts lists, and behaves nearly identically to strings: If the first argument to `+` is a list, then the second is converted to a list, and a new list with the contents of both are returned.

## `*` now replicates lists
Just like `*` replicates strings by a nonnegative integer, `*` will replicate lists by nonnegative integers.

## `^` now joins lists
This is the `.join` function for lists, converting each element to a string and concatenating them together with the second argument interspersed.

## `<`, `>`, and `?`
The `<`, `>`, and `?` functions now all accept lists, and behave like most other languages: Comparing element-wise. For `<` and `>`, if all elements are equal, the smaller list is lesser than the larger.

## `GET` now accepts lists
`GET` for lists functions almost identically to that of strings: you return a sublist of the specific range. 

Example:
```
; = list + (,"foo") (,"bar") (,"baz")

GET list 0 1 # => ["foo"]
GET list 1 2 # => ["bar", "baz"]
GET list 1 0 # => []
```

## `SET` now accepts lists
`SET` for lists acts identically to strings: the second and third arguments are converted to integers (and are the start and length), and the fourth argument is coerced to a list. Notably, if the length is `0`, this functions as an "insert" command.

## `%` only requires supporting nonnegative arguments
There's always a debate over whether `%` should be modulo or remainder: Some languages return `-1` for `-5 % 2`, where others return `1`. Some (like C) even leave it implementation-defined! As such, it's quite difficult to get consistency between languages.

Since modulo/remainder with negative numbers is not a common operation, and introduces so much more headache than it's worth, it's now considered undefined behaviour: Implementations are free to either do modulo or remainder.

## `^` only requires supporting nonnegative exponents.
Supporting negative exponents significantly complicates some implementations (for example, where integer exponentiation is only by unsigned integers), and isn't even useful. As such, it's now undefined behaviour, and implementations can dow hat they want.

While you technically _could_ support negative exponents, there wouldn't be much point:

- `0 ^ -x` would be division by zero
- `1 ^ -x` would always be one
- `-1 ^ -x` would be identical to `-1 ^ x`
- all other numbers would return `0`.

Additionally, by precluding negative exponents, this leaves implementations free to return a float when negative exponents are used.
