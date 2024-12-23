# Knight3.0.0 Changelog from Knight2.0.1

# Breaking Changes for Current Implementations
For currently-conforming implementations, the only breaking changes are:
- The awkward requirement for `PROMPT` to strip a trailing `\n`, `\r\n`, `\r\r\n`, `\r\r\r\n`, ... has been removed: It now only strips `\n` or `\r\n`.
- The `` ` `` extension (string interpolation) is now `X"`.
- The `$` extension is now renamed back-to `` ` ``.

# Tl;DR
- Breaking Changes (for implementations)
	- `PROMPT` now only strips trailing `\n`/`\r\n` (not `\n`/`\r\n`/`\r\r\n`/`\r\r\r\n`/...)
	- `PROMPT` now explicitly says it has to handle lines of `i32::MAX`
	- Make explicit that `WHILE`'s second argument can be a Block.
- Relaxing Requirements (for implementations)
	- Negative integer -> list conversion is UB
	- Boolean -> list conversion is UB
	- Only 65535 unique variables need to be supported
- Extensions
	- `$` extension (run shell command) has been renamed back to `` ` ``
	- Old `` ` `` extension (string interpolation/escaping) is now `X"`

# Breaking Changes
## Changing how `PROMPT` strips newlines (Reverting Knight 2.0.1)
This is the "big" breaking change for current implementations: `PROMPT` now must only strip a trailing `\r\n` or `\n`, if they're present.

This requirement has always been the bane of my implementations---**every single one** has had to special case this in, which is an indication that there's a problem with it. Originally, the requirement was made because some languages strip _either_ `\r\n` _or_ `\n`, depending on what system they're running on, and don't tell you. To solve this, I just waved my hands and said "strip _all_ trailing `\r`s and that'll solve it!"

However... that just doesn't really work all that nicely. Knight's meant to be easy to implement in most languages, having its primitives somewhat-closely match the implementation primitives, but `PROMPT` just didn't. So, this change now makes a few implementations have to do some more work to figure out what system they're on, to make all other implementations significantly simpler.

## Extensions changed
The `` ` `` extension is now (once again) used for running shell commands and getting their stdout, and string interpolation is now `X"..."`.

I originally changed shell commands from `` ` `` to `$` to allow for `` ` `` to be used string interpolations/escaping in extensions (eg ``OUTPUT `hello\tworld!` ``). But it's always irked me, because `` ` `` has traditionally been used for shell functions in many other languages (eg php, sh, ruby, perl, to name a few).


After three years, I haven't seen many implementations supporting interpolation or escaping, so the change to support it was somewhat pointless. And, since `X"..."` is nearly as short (and has precedence in many other langs like python's `f"..."`, C#'s `$"..."`, etc), I thought it time to swap them back.

# Making the Specs More Explicit
There were a couple of places in the specs which need to be fixed slightly. No known implementations will be broken by making these explicit:
- `WHILE`'s body can now return a block, just like the right-side of `&`/`|`/`;`/`=`. (This was accidentally omitted.)
- `PROMPT` now must be able to accept lines 2147483647 long, including the trailing `\r\n`/`\n` that'll be stripped.

# Relaxing Requirements
These changes aren't breaking for implementations, but _are_ breaking for Knight programs themselves.

## At Most 65535 Variables Need to be Supported
Implementations are now only required to support a maximum of 65535 unique variables within a program, but can support more if they want. (This is relaxing a previous requirement on implementations: Previously they were required to support an arbitrary amount.)

In Knight 1.0, "lists" were represented via `EVAL`ing variables (eg `EVAL + (+ "_list_" idx) "=val"`), which meant that limiting to 65535 variables would not make Knight able to do some list-heavy tasks. Now that lists are fully supported in Knight, and `EVAL` is marked as an optional extension, this constraint's no longer relevant.

The number 65535 was chosen because it's small enough that implementations could statically memory ahead-of-time (`struct { string, value } name; value val } variables[65535];`), but larger than any Knight program might really use. (That being said, if implementations support `EVAL` it might be useful to also support a larger amount of variables.)

## Boolean/Negative Integer to List is now Undefined Conversions
In Knight 3.0, boolean->list (eg `+ @ T`) and integer->list (eg `+@ ~123`) conversions are now **undefined behaviour**, and implementations can do what they want when this happens (including the old behaviour).

Previously, I wanted there to be 100% infallible conversions between all the different types: This, in theory, makes some implementation strategies easier. As such, every builtin type (but `BLOCK`'s return value) had conversions defined, even if they're weird. However, after implementing Knight 2 in a few languages, it's become clear that:
1. There _are_ fallible conversions already: (a) list -> string if the list has `BLOCK` return values (b) string -> int if the string contains too large a number
2. The benefits of making these conversions doesn't outweigh the implementation oddities that come up.

As such, these two conversions are now marked as **undefined behaviour**.

(As a side note, I don't think I've ever seen someone use the bool -> list conversion before. It was intended to let you "accumulate", eg `; = a @ ; WHILE cond (= a + a boolean) : OUTPUT LENGTH a` to see how many times `cond` succeeded. However, if you just use integers, then it works the same way, and is more efficient even.)
