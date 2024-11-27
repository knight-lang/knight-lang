# Changes for Knight 3.0

## Breaking changes for 2.0.1 implementations (current implementations _won't_ be compliant)
- The `PROMPT` function now must only strip trailing `\r\n` or `\n`s. (**TODO**: how should an ending `\r` at EOF be handled? Stripped, kept, or undefined behaviour?)

## Relaxing requirements (current implementations will still be compliant)
- Implementations don't need to support `BLOCK` return values as the second arg to `&` and `|`
- `LENGTH` doesn't coerce its argument to arrays; it's now only valid on lists and arrays.
- Negative integers -> list coercion (`+ @ ~123`) is undefined behaviour.
- integer -> string coercion is much more restrictive: Implementations only need to support conversions of strings that _exactly_ match the regex `/^[-+]?\d+$/`. Anything beyond that is implementation-defined nehaviour.

## Making requirements clearer
- Specify the maximum amount of variables (65535) that need to be supported.
- Make explicit that `PROMPT` must be able to read lines of length `INT_MAX`.

# Fixes to the Repo and specs
- Add the EBNF from the README.md to the specs
- Ensure all the links work in the specs
- Cleanup knight examples.
- Add a brief overview in the README.md
- Relegate the timing and personal language sections in the README to somewhere else (either a "more details" section, or delete them)
- Cleanup links to some of the older knight impls

# Others
- Make the test harness user-friendly for people not acquainted with ruby. Better error messages, and better usage
