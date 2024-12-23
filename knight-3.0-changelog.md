# Knight2.0.1 Changelog from Knight2.0

# Tl;DR
# Breaking Changes
- `PROMPT` now only strips trailing `\n`/`\r\n` (not `\n`/`\r\n`/`\r\r\n`/`\r\r\r\n`/...)
- `PROMPT` now explicitly says it has to handle lines of `i32::MAX`
- Make explicit that `WHILE`'s second argument can be a `BLOCK`.

# Relaxing Requirements
- Negative integer -> list conversion is UB
- Boolean -> list conversion is UB
- Only 65535 unique variables have to be supported

# Extensions
- `$` extension (run shell command) has been renamed back to `` ` ``
- Old `` ` `` extension (string interpolation/escaping) is now `X"`


# Breaking Changes
## `PROMPT` function cleaned up
<!-- The `PROMPT` function now requires implementations -->
<!-- - The `PROMPT` function now must only strip trailing `\r\n` or `\n`s. (**TODO**: how should an ending `\r` at EOF be handled? Stripped, kept, or undefined behaviour?) -->

## `$` renamed back to `` ` `` (extensions can use `X`, eg `X"` for interpolation)
## More functions required to support `BLOCK`
- Implementations need to support `BLOCK`s as the second argument to `WHILE` (eg `WHILE cond ; (do_something) (= f BLOCK ...) `, or even `WHILE cond BLOCK ...`)


# Removed Features

# Feature Updates
## Explicitly Mention `PROMPT`'s maximum length
Previously, the specs didn't make it clear the maximum required length that `PROMPT` should be able to read. The specs have now been updated to reflect the fact that they must be able to read in at least `TODO`: `2147483647` bytes (which includes the trailing `\n`/`\r\n` if present.)

# Relaxing Implementation Requirements
## Specifying a Maximum Required Variable Amount
Implementations are now only required to support a maximum of 65535 unique variables within a program, but can support more if they want. (This is relaxing a previous requirement on implementations: Previously they were required to support an arbitrary amount.)

In Knight 1.0, "lists" were represented via `EVAL`ing variables (eg `EVAL + (+ "_list_" idx) "=val"`), which meant that limiting to 65535 variables would not make Knight able to do some list-heavy tasks. Now that lists are fully supported in Knight, and `EVAL` is marked as an optional extension, this constraint's no longer relevant.

The number 65535 was chosen because it's small enough that implementations could statically memory ahead-of-time (`struct { string, value } name; value val } variables[65535];`), but larger than any Knight program might really use. (That being said, if implementations support `EVAL` it might be useful to also support a larger amount of variables.)

## Negative Integers -> List Coercion is now Undefined Behaviour
Coercion negative numbers to a list (e.g. `+ @ ~123`) is now undefined behaviour, and implementations can choose to do what they want.

Previously, I wanted there to be 100% infallible conversions between all the different types: This, in theory, makes some implementation strategies easier (eg using `From` in Rust instead of `TryFrom`). As such, every builtin type (but `BLOCK`'s return value) had conversions defined, even if they're weird. However, after implementing Knight 2.0 in a few languages, it's become clear that:
1. There _are_ fallible conversions already: (a) list -> string if the list has `BLOCK` return values (b) string -> int if the string contains too large a number
2. The benefits of making these conversions doesn't outweigh the implementation oddities that come up.

other forms of weird coersions are still defined bc useful

## (?) Boolean -> List coercoin is now UB
- Negative integers -> list coercion (`+ @ ~123`) is undefined behaviour.
