# Official Knight Specifications (v2.0)
## Table of Contents
* [Overview](#overview)
	- [Undefined Behaviour](#undefined-behaviour)
* [Syntax](#syntax)
	- [Required Encoding](#required-encoding)
	- [Whitespace](#whitespace)
	- [Comments](#comments)
	- [Integer Literals](#integer-literals)
	- [String Literals](#string-literals)
	- [Variables](#parsing-variables)
	- [Functions](#parsing-functions)
	- [Parenthesis Groupings](#parenthesis-groupings)
	- [Parsing Example](#parsing-example)
* [Types](#types)
	- [Context Overview](#coercions-overview)
	- [Integer](#integer)
	- [String](#string)
	- [Boolean](#boolean)
	- [Null](#null)
	- [List](#list)
	- [Block](#block)
* [Variables](#variables)
	- [Variable Evaluation](#variable-evaluation)
* [Functions](#functions)
	- [Evaluation Contexts](#evaluation-contexts)
	- [Nullary (Arity 0)](#nullary-fns)
	- [Unary (Arity 1)](#unary-fns)
	- [Binary (Arity 2)](#binary-fns)
	- [Ternary (Arity 3)](#ternary-fns)
	- [Quaternary (Arity 4)](#quaternary-fns)
* [Extensions](#extensions)
	- [Command Line Arguments](#ext-command-line-arguments)
	- [Handling Undefined Behaviour](#ext-handling-undefined-behaviour)
	- [Functions](#ext-functions)
	- [Syntactic Sugar](#ext-syntactic-sugar)
	- [Additional Types](#ext-additional-types)
	- [Changing Functionality](#ext-changing-functionality)
	- [Extensibility](#ext-extensibility)



# Overview
Knight is a simple programing language, designed with the goal of being easily implementable in nearly any language. Since each language has a slightly different way of doing things, the Knight specs may leave some things up to the implementation. This allows each language to implement Knight in the most idiomatic way possible.

## Undefined Behaviour
Yes, Knight has undefined behaviour, which is almost universally considered a bad idea (tm) — it makes a programmers life harder and compiler implementation easier. However, since Knight's primary focus _is_ to make writing compilers easy (being somewhat usable is secondary), undefined behaviour is crucial in making Knight implementable in everything, whether it be sed, Python, Prolog or APL.

Throughout this document, there will be places where something is described as **undefined behaviour**. If undefined behaviour is ever encountered during the parsing or execution of a Knight program, then the entire program is invalid; implementations may do whatever they want (including ignoring the error, segfaulting, custom extension behaviour, etc.).

Some forms of undefined behaviour may be easier to check than others, depending on the language being implemented. For example, most implementations should be able to detect a division-by-zero error (e.g. by an exception being thrown). However, it may be more impossible to detect standard out being closed (such as in brainf\*ck). Implementations are encouraged, but not required, to handle easily-checked undefined behaviour.

To reiterate, **if undefined behaviour is encountered at any point during the parsing or execution of a Knight program, the entire program is ill-formed, unless an implementation says otherwise.**

# Syntax
Knight is a Polish-Notation (PN) language: Instead of the traditional "infix notation" (e.g. `output(1 + 2 * 4)`), functions come _before_ their arguments (e.g. `OUTPUT + 1 * 2 4`).

Knight also does not have a distinction between statements and expressions. Every function in Knight returns a value, which is then usable in other functions. So, instead of the c-style syntax of
```c
if (x < 3) {
	output("hi");
} else {
	output("bye");
}
```
Knight allows you to utilize the return value of `IF`:
```knight
OUTPUT IF < x 3 "hi" "bye"
```

Each Knight program is a single expression expression — such as `OUTPUT 3`, `; (= a 4) (OUTPUT (+ "a=" a))`, etc. Any additional tokens after this first expression (i.e. anything other than [whitespace](#whitespace) and [comments](#comments)) is **undefined behaviour**. 

## Required Encoding
To make Knight implementable in most languages, only the following subset of ASCII characters is required to be supported. Implementations may support a superset of this (for example, all of ASCII or Unicode), but this is not required.
```text
	[tab] [newline] [carriage return] [space] 
	  ! " # $ % & ' ( ) * + , - . /
	0 1 2 3 4 5 6 7 8 9 : ; < = > ?
	@ A B C D E F G H I J K L M N O
	P Q R S T U V W X Y Z [ \ ] ^ _
	` a b c d e f g h i j k l m n o
	p q r s t u v w x y z { | } ~
```
It is **undefined behaviour** to use any character not on this list anywhere within Knight source code (including within [comments](#comments)) and [string](#string)s (including those returned from [`PROMPT`](#fn-prompt)).

## Whitespace
Due to the nature of Knight's syntax, whitespace isn't always necessary. For example, `OUTPUT1` should be parsed as two tokens, `OUTPUT` and `1`. However, there are some times that whitespace is needed in order to distinguish different tokens (such as between two identifiers).

Implementations are required to recognize the following characters as whitespace:

- Tab (`0x09`, i.e. `\t`)
- Newline (`0x0a`, i.e. `\n`)
- Carriage return (`0x0d`, i.e. `\r`)
- Space (`0x20`, i.e. a space—` `)

### Interpreting `(`, `)`, and `:` as whitespace {#other-whitespace}
While not defined as whitespace, implementations are free to ignore `(`, `)`, and `:` in source files. This is because for valid Knight programs, `(` and `)` do nothing (see [Parenthesis Groupings](#parenthesis-groupings)), whereas [`:`](#fn-noop) is a function that simply returns its argument, and can therefore always be omitted.

## Comments
Comments in Knight start with pound sign (`0x23`, i.e. `#`) and go until either a newline character is encountered (`0x0a`, i.e. `\n`) or the end of file is reached. Everything after the `#` should be ignored by the parser. There are no multiline or embedded comments in Knight.

As mentioned in the [the required encoding section](#required-encoding), it is **undefined behaviour** for comments to contain non-default characters. However, implementations are free to define their own behaviour when such a character is encountered.

For those familiar with regex, comments are `/#[^\n]*(\n|$)/`.

## Integer Literals
[Integer](#integer) literals are simply a sequence of ASCII digits (i.e. `0` (`0x30`) through `9` (`0x39`)). Leading `0`s do not indicate octal integers (e.g. `011` is the number eleven, not nine). Numeral systems other than decimal are not supported, and only integral numbers are allowed. Note that integers are allowed to be followed by any non-digit character. For example, `+1a` should be parsed as `+` then `1` then `a`.

Knight does not have negative integer literals. Instead, the [`~`](#fn-negate) (numerical negation) function must be used: `~5`. However, implementations are free to parse this as the integer `-5`, as it has the same effect.

It is **undefined behaviour** for an integer literals to be larger than the [maximum required size](#integer-bounds).

For those familiar with regex, integers are `/[0-9]+/`.

## String Literals
[String](#string) literals in Knight begin with with either a single quote (`0x27`, i.e. `'`) or a double quote (`0x22`, i.e. `"`). All characters are taken literally until the opening quote is encountered again. This means that there are no escape sequences within string literals; instead of directly including a newline character, you will have to write:
```knight
OUTPUT "this is a newline:
cool, right?"
```
Due to the lack of escape sequences, each string may only contain one of the two types of quotes (including the same quote again denotes the end of a string). There is no difference between single quoted or double quoted strings, other than the allowed quotation marks.

It is **undefined behaviour** for string literals to not have a closing quote. While highly unlikely to be encountered in an actual program, it is also **undefined behaviour** for the length of a string literal to exceed the [maximum integer size](#integer-bounds).

For those familiar with regex, strings are `/'[^']*'|"[^"]*"/`.

## Variables {#parsing-variables}
In Knight, all [variable](#variables)s are lowercase (uppercase letters are reserved for builtin functions). Variable names must start with an ASCII lowercase letter (i.e. `a` (`0x61`) through `z` (`0x7a`)) or an underscore (`_` (`0x5f`)). After the initial letter, variable names may optionally include lowercase letters, underscores, or ASCII digits (i.e. `0` (`0x30`) through `9` (`0x39`)). Since uppercase letters are not allowed in user-defined variables, they are allowed to immediately follow variables. `+aRANDOM` should be parsed as `+`, `a`, and `RANDOM`.

Implementations are required to support variable names of at most 127 characters, although they are allowed to support variable names longer than this. It is **undefined behaviour** for programs to have variable names longer than 127 characters.

For those familiar with regex, variables are `/[a-z_][a-z_0-9]*/`.

## Functions {#parsing-functions}
There are two different styles of functions in Knight: symbolic and word-based.

Word-based functions start with a single uppercase letter (ie `A` (`0x41`) through `Z` (`0x5a`)), such as `I` for `IF` or `R` for `RANDOM`, and may contain any amount of upper case letters and `_` (`0x5f`) afterwards. This means that `R`, `RAND`, `RANDOM`, `RAND_INT`, `RAND_OM_NUMBER` `R___` are all considered the same function — the `R` function.

Symbolic functions are functions that consist of a single symbol, such as `;` or `%`. Unlike word-based functions, they do not consume characters following them. The character stream `+++` must be parsed as `+ + +` — three separate addition functions.

Functions have a specified arity: There are no variadic functions. After parsing a function's name, an amount of expressions corresponding to that function's arity should be parsed: For example, after parsing a `+`, two expressions must be parsed, an example being `+ 1 2`. It is **undefined behaviour** for a program to contain fewer expressions than are required for the function. While not necessary, it is recommended to provide the user some form of error message, such as `line 10: missing argument 2 for '+'`, or `missing an argument for '+'`.

The list of required functions are as follows:

- Arity `0`: [`TRUE`](#fn-true), [`FALSE`](#fn-false), [`NULL`](#fn-null), [`@`](#fn-empty-list),
             [`PROMPT`](#fn-prompt), [`RANDOM`](#fn-random)
- Arity `1`: [`:`](#fn-noop), [`BLOCK`](#fn-block), [`CALL`](#fn-call), [`QUIT`](#fn-quit),
             [`DUMP`](#fn-dump), [`OUTPUT`](#fn-output), [`LENGTH`](#fn-length), [`!`](#fn-not),
             [`~`](#fn-negate), [`ASCII`](#fn-ascii), [`,`](#fn-box), [`[`](#fn-head), [`]`](#fn-tail)
- Arity `2`: [`+`](#fn-add), [`-`](#fn-subtract), [`*`](#fn-multiply), [`/`](#fn-divide),
             [`%`](#fn-remainder), [`^`](#fn-power), [`<`](#fn-less-than), [`>`](#fn-greater-than),
             [`?`](#fn-equals), [`&`](#fn-and), [`|`](#fn-or), [`;`](#fn-then), [`=`](#fn-assign),
             [`WHILE`](#fn-while)
- Arity `3`: [`IF`](#fn-if), [`GET`](#fn-get)
- Arity `4`: [`SET`](#fn-set)

Implementations may define additional symbolic or keyword-based functions if desired.

### Literal Functions {#literal-functions}
As the `TRUE`/`FALSE`/`NULL`/`@` functions take no arguments, and simply return a value (true, false, null, and an empty list, respectively), they can be instead as literals. That is, there is no functional difference between parsing `TRUE` as a function that returns `true` when executed, and directly parsing `TRUE` as the true value.

### Implementation-Defined Functions
Implementations may define their own functions, as long as they start with an upper-case letter or a symbol. Note that the `X` function name is reserved for extensions. See [Extensions](#extensions) for more details.

## Parenthesis Groupings
Due to Knight being a polish-notation language with fixed-arity functions (see [Functions](#functions)), grouping is not *required* to produce valid programs. But since writing large Knight programs can get a bit difficult, the left and right round parenthesis (`0x28` and `0x29`, i.e. `(` and `)`) can be used to enclose expressions. It is **undefined behaviour** for parentheses to not enclose a single expression.

Since parentheses do not change the parsing of valid Knight programs, implementations are free to ignore them when parsing. These implementations will still run valid Knight programs correctly.

This requirement simply exists so that implementations that wish to do parenthesis checking won't accidentally reject valid programs. Here's some examples of programs:
```knight
OUTPUT * a 2         # legal, no parens
(OUTPUT * a 2)       # legal, parens are valid
(OUTPUT (* (a) (2))) # legal, parens are valid
OUTPUT * ((((a)))) 2 # legal, parens can nest.
= (a) 4              # legal, identifiers here are no different

OUTPUT (* a 2  # illegal, mismatched parens
OUTPUT (*) a 2 # illegal, not enclosing a single expression
OUTPUT ((*) a 2) # illegal, the `(*)` isn't a single expression
```

## Parsing Example
Here's an example of a simple guessing game, and how it should be parsed:
```text
# Simple guessing game
; = secret RANDOM
; = guess + 0 PROMPT
  OUTPUT IF (? secret guess) "correct!" "wrong!"
```
```text
[;]
 ├──[=]
 │   ├──[secret]
 │   └──[RANDOM]
 └──[;]
     ├──[=]
     │   ├──[guess]
     │   └──[+]
     │       ├──[0]
     │       └──[PROMPT]
     └──[OUTPUT]
         └──[IF]
             ├──[?]
             │   ├──[secret]
             │   └──[guess]
             ├──["correct!"]
             └──["wrong!"]
```

# Types
Knight only defines a handful of types — [Integer](#integer)s, [String](#string)s, [Boolean](#boolean)s, [Null](#null), [List](#list)s, and [Block](#block)s. Knight functions frequently perform coercion, converting their arguments from one type to another. As such, every type but **block**s have the **integer**, **string**, **boolean**, and **list** coercions defined.

All types in Knight are **immutable**, including strings and lists.

## Context Overview
Many functions in Knight have defined contexts: They will automatically coerce their arguments from one type to another. For example, [`OUTPUT`](#fn-output) always coerces its argument into a string.

The following is an overview of the conversions. See each type's "Coercion" section for more details. Note that the `Block` has no defined conversions, and using it in any conversion context is **undefined behaviour**.

| Conversion From \ To | [Integer](#integer) | [String](#string) | [Boolean](#boolean) | [List](#list) |
|----------------------|---------------------|-------------------|---------------------|---------------|
| [Null](#null)        | `0`                 | `""`      | `false`             | empty list    |
| [Integer](#integer)  | _itself_      | what you expect   | nonzero?       | digits (negate digits if negative) |
| [String](#string)    | &lt;like C's `atoi`&gt;     | _itself_    | nonempty? | individual chars |
| [Boolean](#boolean) (false/true)  | `0`/`1` | `"false"`/`"true"` | _itself_ | empty list/boxed `TRUE` |
| [List](#list)        | Length of list      | list [joined](#fn-power) by newline | nonempty? | _itself_ |

## Evaluation of Types
All builtin types in Knight (i.e. Integer, String, Boolean, Null, and List) should return themselves when evaluated. This is in contrast to variables and functions, which may return different values each time they are evaluated.

## Integer
In Knight, only decimal integral numbers exist — all functions which might return non-integral numbers are truncated (look at each functions' respective definitions for details on what exactly truncation means in each case).

### Minimum Required Bounds {#integer-bounds}
All implementations must be able to represent all integers within the range `-2147483648 .. 2147483647`, inclusive on both sides. (These are the bounds for 32-bit signed integers using 2's complement.) Implementations are free to support larger and smaller integers (for example, a 64 bit integer).

Note that all mathematical operations in Knight that would cause over/underflow for integers are considered **undefined behaviour**. This allows for implementations to freely use larger integer sizes, and not have to worry about wraparounds.

### Contexts {#integer-contexts}
(See [here](#evaluation-contexts) for more details on contexts.)

- **integer**: In integer contexts, the integer itself is simply returned.
- **string**: In string contexts, integers are converted to their base-10 representation. Negative integers should have a `-` prepended to the beginning of the string (positive integers shouldn't get `+`). For example, `0 -> "0"`, `123 -> "123"`, and `~12 -> "-12"`.
- **boolean**: In boolean contexts, zero becomes `false`, and all other integers (ie nonzero) become `true`.
- **list**: In list contexts, the digits of the integer should be returned in ascending order. If the integer is negative, each digit should become negated as well. For example, `+@123` would return a list of `1`, then `2`, then `3`, whereas `+@~123` would return a list of `-1`, `-2`, and `-3`.

## String
Strings in Knight are immutable (like all types within Knight), and are _only_ required to be able to represent a [specific subset of ASCII](#required-encoding). Implementations are free to support more characters (e.g. all of ASCII, or Unicode).

It is **undefined behaviour** for Knight programs to attempt to create strings with a length larger than [the maximum value for integers](#integer-bounds), as `LENGTH string` should always have a well-defined result.

### Contexts {#string-contexts}
(See [here](#evaluation-contexts) for more details on contexts.)

- **integer**: (This is roughly equivalent to C's `atoi`). To convert a string to an integer, the following is done: (1) strip all leading [whitespace](#whitespace), (2) an optional `+` or `-` may occur (3) take as many ascii digits as possible, stopping at the first non-digit or end of string. Interpret those digits as a string literal, negating it if `-` occurred. If no digits are found, return zero. In regex terms, this is `/^\s*([-+?\d*)/`. Note that if the resulting integer is out of bounds for what the integer type can handle, it is **undefined behaviour**.
- **string**: In string contexts, the string itself is returned.
- **boolean**: In boolean contexts, only empty strings are `false`. All other strings (ie nonempty) are `true`, including things like `"0"`.
- **list**: In list contexts, the characters of the string should be returned, with each element of the list being a string containing just that character. (For example, `+@"abc"` would return a list of `"a"` followed by `"b"` followed by `"c"`).

## Boolean
The boolean type in Knight has two possible values: `true` and `false`. These two values are used to indicate truthiness within Knight, and is the type that is converted to within boolean contexts.

### Contexts {#boolean-contexts}
(See [here](#evaluation-contexts) for more details on contexts.)

- **integer**: In integer contexts, `false` becomes `0` and `true` becomes `1`.
- **string**: In string contexts, `false` becomes `"false"` and `true` becomes `"true"`.
- **boolean**: In boolean contexts, the boolean itself is simply returned.
- **list**: In list contexts, `false` becomes an empty list and `true` becomes a list just containing `TRUE`. (i.e. `+@FALSE` is equivalent to `@`, whereas `+@TRUE` is equivalent to `,TRUE`).


## Null
The `null` type is used to indicate the absence of a value within Knight, and is the return value of some functions (such as `OUTPUT` and `WHILE`). While conversions from `null` are defined for all contexts, no conversions to `null` exist.

### Contexts {#null-contexts}
(See [here](#evaluation-contexts) for more details on contexts.)

- **integer**: In integer contexts, null becomes `0`.
- **string**: In string contexts, null becomes an **empty string** (notably, not `"null"`, as some languages do).
- **boolean**: In boolean contexts, null becomes `false`.
- **list**: In list contexts, null becomes an empty list.

## List
Lists are the only container type defined in Knight. Like most runtime languages, lists in Knight are heterogeneous — that is, the same list must be able to hold multiple values (e.g. both an integer and a string). They are also immutable: Operations that would normally modify a list in other languages instead return a new list. Lists are also ordered (e.g. `[list` should always return same element for nonempty lists).

It is **undefined behaviour** for Knight programs to attempt to create lists with a length larger than [the maximum value for integers](#integer-bounds).

### Contexts {#list-contexts}
(See [here](#evaluation-contexts) for more details on contexts.)

- **integer**: In integer contexts, lists return their length.
- **string**: In string contexts, lists should have their elements converted to a string, with a newline inserted between each element. (This is the same as calling the [`^` operator](#fn-power) with a newline as the second argument). Because of this, an empty list becomes an empty string, and a list of just one element becomes just that element's string value.
- **boolean**: In boolean contexts, empty lists return `false`, and all other (i.e. nonempty) lists return true.
- **list**: In list contexts, the list itself is returned.

### List Literals
Due to Knight's fixed-arity syntax, it's impossible to have list literals (although they could be supported as an extension). In general, there are three ways to create lists in Knight:
```knight
# Method 1, automatic coercion by adding something to `@`
+@123   # => a list of `1`, `2`, and `3`.
+@"abc" # => a list of `"a"`, `"b"`, and `"c"`.

# Method 2, adding "boxed" elements together:
+ (+ ,1 ,2) ,3 # => also a list of `1`, `2`, and `3`.
+ ,TRUE ,FALSE # => a list of `true` and `false`

# Method 3 (a variant of 2), through iteration:
; = list @
; WHILE > 100 list # until the list is 100 elements long
	: = list + list ,LENGTH list # add the length of the list to it.
```

## Block
The black sheep of Knight's types, the Block type is created in exactly one way: The return value of the `BLOCK` function. Blocks are used to used to delay execution of a piece of code until later. The only way to execute a block's body is through the `CALL` function, which accepts only a single argument: the block to execute. Blocks do not take arguments, as all arguments are global variables.

### Contexts {#block-contexts}
The Block type does not have any contexts defined. Attempting to coerce a Block in any way results in **undefined behaviour**.

### Valid functions for Blocks
Because blocks are not allowed to be used in any context, there are only a handful of contexts where they may be used. Attempting to use them in any other context is considered **undefined behaviour**

- The sole argument to [`:`](#fn-noop), [`BLOCK`](#fn-block) itself (ie `BLOCK BLOCK ...`), [`CALL`](#fn-call), [`DUMP`](#fn-dump), and [`,`](#fn-box).
- The second argument to [`=`](#fn-while), [`&`](#fn-and), or [`|`](#fn-or)
- Either argument of [`;`](#fn-then)
- The second or third argument of [`IF`](#fn-if)

Functions like [`?`](#fn-equals) and [`DUMP`](#fn-dump) do not require block handling at all.

# Variables
All variables in Knight are global and exist for the duration of the program; there are no function-local variables. This means that once a variable is assigned a value, the variable should be accessible at any point. Furthermore, variables are not typed — you can assign a string to a variable that previously held a block.

Implementations are only required to support variables between 1 and 127 characters long, though longer variables can be supported. As is described in the [variable parsing](#parsing-variables) section, names must conform to the regex `/[a-z_][a-z0-9_]*/`.

### Possible optimizations for Variables
By default, Knight supports no form of introspection or reflection (without optional extensions such as `EVAL` or `VALUE`). There is no way to dynamically assign/lookup a variable at runtime. If you can prove that a variable is unused at a certain point, or is only assigned a specific type, you should feel free to perform optimizations.

## Variable Evaluation
When evaluated, the variable must return the value previously assigned to it, unevaluated. That is, if you had `= foo BLOCK (QUIT 1)` and later on evaluated `foo`, it should return the block, and _not_ quit the program. Note that it's possible for multiple variables to be associated with (alias) the same object within Knight (e.g. `= foo (= bar ...)`).

It is **undefined behaviour** to attempt to evaluate an unassigned variable. 

# Functions
Every function in Knight has a predetermined arity — there are no variadic functions.

Unless specified, all functions will evaluate their arguments beforehand. This means that `+ a b` should fetch the value of `a`, the value of `b`, and then add them together, and should _not_ attempt to add a literal identifier to another literal identifier (which doesn't even make sense).

All arguments _must_ be evaluated in order (from the first argument to the last) — functions such as `;` rely on this.

For any operator which returns an integer outside of the implementation-supported integer range, the return value is undefined.

## Evaluation Contexts
Functions can impose contexts on their arguments, coercing other types to the required type. (See each type's coercion contexts for their exact semantics.) The following are the contexts used within this document:

- `string`: The argument must be evaluated, and then converted to a [String](#string).
- `boolean`: The argument must be evaluated, and then converted to a [Boolean](#boolean).
- `integer`: The argument must be evaluated, and then converted to an [Integer](#integer).
- `list`: The argument must be evaluated, and then converted to a [List](#list).
- `coerced`: The argument must be evaluated, and will then be coerced within the function itself.
- `unchanged`: The argument must be evaluated, and is passed unchanged.
- `unevaluated`: The argument must not be evaluated at all before being passed.

## Nullary (Arity 0) {#nullary-fns}

### `TRUE()` {#fn-true}
The function `TRUE` returns the true boolean value.

`TRUE` may either be interpreted as a function of arity 0, or a literal value. See the [Literals Functions](#literal-functions) for more details.

### `FALSE()` {#fn-false}
The function `FALSE` returns the false boolean value.

`FALSE` may either be interpreted as a function of arity 0, or a literal value. See the [Literals Functions](#literal-functions) for more details.

### `NULL()` {#fn-null}
The function `NULL` returns the null value.

`NULL` may either be interpreted as a function of arity 0, or a literal value. See the [Literals Functions](#literal-functions) for more details.

### `@()` {#fn-empty-list}
The function `@` returns the an empty list. This function exists because there's no easy way to get an empty list (other than `GET ,1 0 0`, which is terrible.)

`@` may either be interpreted as a function of arity 0, or a literal value. See the [Literals Functions](#literal-functions) for more details.

### `PROMPT()` {#fn-prompt}
The prompt function reads a line from standard in (terminated either by a newline or by reaching the end of a file, whichever is first). Before returning the line, if either a trailing `\r\n` or `\n` is present, strip it (regardless of the operating system). If there is nothing in standard in (i.e. end of file was reached before reading), `null` should be returned instead.

If there is a problem reading from standard in (e.g, it's closed, permission issues, etc., but _not_ if EOF was reached—see previous line), it is considered **undefined behaviour**.

If the line tcontains any characters that [are not supported in Knight](#required-encoding), it is considered **undefined behaviour**.

### `RANDOM()` {#fn-random}
This function must return a (pseudo-) random integer between 0 and at least 32767 (`0x7fff`). Implementations are free to return a larger random integer if they desire; however, all random integers must be zero or positive.

Note that `RANDOM` _should_ return different integers between subsequent calls and program executions, although this is not verifiable by virtue of how random numbers are generated. Regardless, programs should use a somewhat unique seed for every program run (e.g. a simple `srand(time(NULL)))` is sufficient).

## Unary (Arity 1) {#unary-fns}

### `:(unchanged)` {#fn-noop}
A no-op: Simply returns its value unchanged (after executing it of course).

As discussed in the [Other Whitespace](#other-whitespace) section, `:` may either be interpreted as a function of arity 1 or whitespace. 

### `BLOCK(unevaluated)` {#fn-block}
Unlike nearly every other function in Knight, the `BLOCK` function does _not_ execute its argument — instead, it returns the argument, unevaluated. This is the only way for Knight programs to get unevaluated blocks of code, which can be used for delayed execution.

The `BLOCK` function is intended to be used to create user-defined "functions", which can be run via [`CALL`](#fn-call). However, as it simply returns its argument, there's no way to provide arguments to user-defined functions: you must simply use global variables:
```knight
; = max BLOCK
   : IF (< a b) a b
; = a 3
; = b 4
: OUTPUT + "maximum of a and b is: " (CALL max)
```
See the [Block type](#block) for exact semantics of how to use `BLOCK`'s return value.

### `CALL(<special>)` {#fn-call}
Just as [`BLOCK`](#fn-block) delays the execution of its argument, `CALL` should "resume execution" of the argument, evaluating as if the `BLOCK` was defined at the call site.

Example:
```knight
; = foo BLOCK bar
; = bar 3
; OUTPUT CALL foo # => 3
; = bar 4
: OUTPUT CALL foo # => 4
```

Calling this function with anything other than [`BLOCK`](#fn-block)'s return value is considered **undefined behaviour**.

### `QUIT(integer)` {#fn-quit}
Stops the entire Knight program with the given status code.

It is **undefined behaviour** if the given status code is not within 0 and 127, inclusive. (However, since it is undefined behaviour, implementations are free to accept status codes outside this range.)

Examples:
```knight
QUIT 12    # => exit with status 12
QUIT 0     # => exit with status 0
QUIT "127" # => exit with status 127
QUIT ~1    # undefined behaviour
QUIT 128   # undefined behaviour
```

### `OUTPUT(string)` {#fn-output}
Writes its argument (converted to a string) to standard out, flushes standard out, and then returns `null`.

Normally, a newline should be written after `string` (which should also flush stdout on most systems). However, if the string ends with a backslash (`\`), the backslash is _not_ written to standard out, and trailing newline is suppressed. 

It is considered **undefined behaviour** if any problems arise when writing to or flushing standard out (e.g. it's closed, permission issues, etc.).

Examples:
```knight
# normal string
; OUTPUT "foo"
; OUTPUT "" # empty string also writes newline
; OUTPUT "bar"
foo

bar
# no trailing newline
; OUTPUT "foo\"
; OUTPUT "bar"
foobar
# With a string ending in `\n`
; OUTPUT "foo
"
; OUTPUT "bar"
foo

bar
```

### `DUMP(unchanged)` {#fn-dump}
Dumps a debugging representation of its argument to standard out, and then returns it.

This function is really meant to be used for debugging purposes (and unit testing), not in finished Knight programs. As such, there is no strict requirement for the debugging representation. Additionally, unlike most functions, `Block`s can be passed as the only argument to `DUMP`.

However, if you want to use the Knight unit tests, then the output of this must conform to the following regexes, or the tester will get confused. _(**TODO**: update these when the unit tester is updated.)_

- `Null()`,
- `Integer(<integer>)` - `<integer>` should be base-10, with a leading `-` if negative.
- `Boolean(<bool>)` - `<bool>` must be either `true` or `false`.
- `String(<string>)` - The literal contents of the string—no escaping whatsoever should be performed. (e.g. `DUMP "foo'b)ar\"` should write `String(foo'b)ar\)`).
- `List(<element1>, <element2>, ..., <element n>)`, no newlines. or `[...]`
- _While `block`s are valid arguments to `DUMP`, the unit tester will never check for them, so implementations are free to do what they want for their dumping_

Like [`OUTPUT`](#fn-output), it is **undefined behaviour** if there are any issues writing to stdout.

### `LENGTH(list)` {#fn-length}
Returns the length of the argument when converted to a list.

Note: The length of strings are the same as the length of their list coercion, as the list coercion returns a list of the chars in the list.

Examples:
```knight
LENGTH TRUE      # => 1
LENGTH FALSE     # => 0
LENGTH NULL      # => 0
LENGTH 1234      # => 4
LENGTH ~1234     # => 4
LENGTH "hello!"  # => 6
LENGTH @         # => 0
LENGTH (*,0 100) # => 100
```

### `!(boolean)` {#fn-not}
Returns the logical negation of its argument: truthy values become `false`, and falsy values become `true`.

Examples:
```knight
!TRUE # => false
!1234 # => false
!""   # => true
!,0   # => true
```

### `~(integer)` {#fn-negate}
Converts the argument to an integer, then negates it. Note that this is numeric negation (i.e. like unary `-` in other languages) and _not_ bitwise negation.

Examples:
```knight
~38         # => -38
~0          # => 0
~(- 1 2)    # => 1
~~5         # => 5
~TRUE       # => -1
~,123       # => -1
~2147483648 #=> undefined (max integer is 2147483647)
```

### `ASCII(unchanged)` {#fn-ascii}
The return value of this function depends on its first argument's type:

- **`Integer`**: Interprets it as an ASCII codepoint, and returns a string containing just that character. It is **undefined behaviour** if the codepoint is not [in the encoding](#required-encoding).
- **`String`**: Converts and returns the first character's ASCII numerical equivalent. It is **undefined behaviour** for the string to be empty.
- **All other types**: **undefined behaviour**

Implementations may feel free to extend `ASCII` to go beyond ASCII and even support Unicode. However, this is not required.

Examples:
```knight
ASCII 38 # => &
ASCII 50 # => ;
ASCII 10 # => <newline>
ASCII 19 # undefined (19 isnt valid)

ASCII "H"     # => 72
ASCII "HELLO" # => 72
ASCII "
" # => 10
ASCII "" # undefined (empty isnt valid)
```

### `,(unchanged)` {#fn-box}
This function returns a list containing just its argument. In Python terms, `lambda x: [x]`.

Examples:
```knight
,1   # => a list of just 1
,,"" # => a list of just a list of ""
,,@  # => a list of just an empty list
```

### `[(unchanged)` {#fn-head}
The return value of this function depends on its first argument's type:

- **`String`**: Returns a string of just first character. It is **undefined behaviour** for the string to be empty.
- **`List`**: Returns the first element of the list. It is **undefined behaviour** for the list to be empty.
- **All other types**: **undefined behaviour**

Examples:
```knight
["h"      # => "h"
["hello"  # => "h"
[""       # => undefined, empty string

[,1       # => 1
[(+@1234) # => 1
[@        # => undefined, empty list.
```

### `](unchanged)` {#fn-tail}
The return value of this function depends on its first argument's type:

- **`String`**: Returns the a string with everything _but_ the first character. It is **undefined behaviour** for the string to be empty.
- **`List`**: Returns a list with everything _but_ the first element. It is **undefined behaviour** for the list to be empty.
- **All other types**: **undefined behaviour**

Examples:
```knight
]"h"      # => ""
]"hello"  # => "ello"
]"aaaaa"  # => "aaaa"
]""       # => undefined, empty string

],1       # => empty list
](+@1234) # => a list of 2, 3, and 4
](+@1111) # => a list of 1, 1, and 1
]@        # => undefined, empty list.
```

## Binary (Arity 2) {#binary-fns}
### `+(unchanged, coerced)` {#fn-add}
The return value of this function depends on its first argument's type:

- **`Integer`**: The second argument is coerced to an integer, and added to the first.
- **`String`**: The second argument is coerced to a string, and concatenated with the first.
- **`List`**: The second argument is coerced to a list, and concatenated with the first.
- **All other types**: **undefined behaviour**.

Examples:
```knight
+ "2a" 3         # => "2a3"
+ 3 "2a"         # => 5
+ @ "abc"        # => a list of "a", "b", and "c"
+ (+@12)  (+@34) # => a list of 1, 2, 3, and 4
+ (+@12) ,(+@34) # => a list of 1, 2, and a list of 3 and 4
```

### `-(unchanged, coerced)` {#fn-subtract}
The return value of this function depends on its first argument's type:

- **`Integer`**: The second argument is coerced to an integer, and then subtracted from the first.
- **All other types**: **undefined behaviour**

Examples:
```knight
- 3 "2a" #=> 1
- ~1 4   #=> -5
```

### `*(unchanged, coerced)` {#fn-multiply}
The return value of this function depends on its first argument's type:

- **`Integer`**: The second argument is coerced to an integer, and multiplied with the first.
- **`String`**: The second argument is coerced to an integer, and then the first is repeated that many times. It is **undefined behaviour** if the second argument is negative.
- **`List`**: The second argument is coerced to an integer, and then the first is repeated that many times. It is **undefined behaviour** if the second argument is negative.
- **All other types**: **undefined behaviour**

Examples:
```knight
* 3 "2a"  # => 6
* 3 FALSE # => 0
* "2a" 3  # => "2a2a2a"
* (,1) 5  # => a list of 5 1s
* (,1) 0  # => empty list
* "2a" ~3 # undefined, negative length
* (,1) ~1 # undefined, negative length
```

###  `/(unchanged, coerced)` {#fn-divide}
The return value of this function depends on its first argument's type:

- **`Integer`**: The second argument is coerced to an integer, and then divided from the first. Non-whole results must be rounded towards zero. It is **undefined behaviour** for the second argument to be zero.
- **All other types**: **undefined behaviour**

Examples:
```
/ 7 3    # => 2
/ ~5 2   # => -2
/ 5 "-3" # => -1
/ 1 0    # undefined
```

### `%(unchanged, coerced)` {#fn-remainder}
The return value of this function depends on its first argument's type:

- **`Integer`**: The second argument is coerced to an integer, and then the remainder of `<arg1> / <arg2>` (rounding towards zero) is returned. Note that this means that, for all `a`, `a = (a/b)*b + a%b`. It is **undefined behaviour** for the second argument to not be a positive integer.
- **All other types**: **undefined behaviour**

```
% 7 3    # => 1
% ~5 2   # => -1
% ~7 5   # => -2
% 7 0    # undefined, 0 is not positive
% 7 ~2   # undefined, -2 is not positive
```

### `^(unchanged, coerce)` {#fn-power}
The return value of this function depends on its first argument's type:

- **`Integer`**: The second argument is coerced to an integer, and then the first integer is raised to the power of the second integer. Note that `^ 0 1` should return `1`. It is **undefined behaviour** for the second argument to be negative.
- **`List`**: The second argument is coerced to a string. Then, each element of the list is converted to a string and concatenated together, with the second argument being inserted between adjacent elements. This is known as the "join" operator in other languages.

Examples:
```knight
^ 0 0   # 0
^ 0 1   # 1
^ 2 0   # 1
^ ~5 9  # -1953125
^ 10 10 # undefined, too large
^ 10 ~1 # undefined, negative exponent

^ @ "!"       # "", joining empty list yields nothing
^ ,12 "!"     # "12", no elements to separate
^ (+@123) "!" # "1!2!3"
```

### `<(unchanged, coerced)` {#fn-less-than}
The return value of this function depends on its first argument's type:

- **`Integer`**: Coerces the second argument to an integer, then returns whether the first is smaller than the second.
- **`String`**: Coerces the second argument to a string, and then returns whether the first is lexicographically smaller than the second. See below for details on Lexicographical comparisons.
- **`Boolean`**: Coerces the second argument to a boolean, and returns whether the first is false and the second is true.
- **`List`**: Coerces the second argument to a list, and then compares each element of the two, returning the whether the non-equal comparison is less than. If each element is equal, return whether the first list is smaller. (This is how most languages which define comparisons on lists/arrays do it.)
- **All other types**: **undefined behaviour**.

Lexicographical comparisons should find the first non-equivalent character in each string and compare them based on their ASCII value (e.g. in `abcd` and `abde`, `c` and `d` would be compared), returning `true` if the first argument's character is smaller. If both strings have equivalent characters, then this function should whether the first string has a smaller size than the second.

Examples:
```knight
< 1 0      # => true
< 1 "4"    # => false
< "A" "a"  # => true, ascii `"a"` is larger.
< "a" "a0" # => true, `"a"` has smaller length.
< "A" "a0" # => true, `"A" < "a"` 
< FALSE 0  # => false
< FALSE 2  # => true
< TRUE x   # => always false regardless of `x`
< @ x      # => always true for non-empty x
< ,1 ,2    # => true, 1 < 2
< +@13 ,2  # => false, 1 < 2
```

### `>(unchanged, coerced)` {#fn-greater-than}
This is exactly the same as [`<`](#fn-less-than), except for operands reversed, i.e. `> a b` should return the same value as `< b a` (barring the fact that `a` should be evaluated before `b`).

Examples:
See [`<`](#fn-less-than).

### `?(unchanged, unchanged)` {#fn-equals}
Unlike nearly every other function in Knight, this one does not automatically coerce its arguments—instead, it checks to see if arguments are the same type _and_ value. For example, `1` is equivalent to neither `"1"` nor `TRUE`.

This function is only valid for the "basic types" (`Integer`, `String`, `Boolean`, `Null`, and `List`). It is **undefined behaviour** for either argument to be a `Block`.

Examples:
```knight
? 1 2        # => false
? ~0 0       # => true
? "1" "1 "   # => false
? FALSE NULl # => false
? NULL NULL  # => true
? ,@ ,,@     # => false
```

### `&(unchanged, unevaluated)` {#fn-and}
This function acts similar to `&&` in some loosely-typed languages: If the first argument (after being evaluated) is falsey, it is returned directly. However, if it is truthy, the second argument is evaluated and returned.

Unlike most functions, `Block`s can be passed as the second argument to `&`.

Examples:
```knight
& 0 (QUIT 1)   # => 0
& "hi" "there" # => "there"
& TRUE ""      # => ""
& @ 4          # => @
```

### `|(unchanged, unevaluated)` {#fn-or}
This function acts similar to `||` in some loosely-typed languages: If the first argument (after being evaluated) is truthy, it is returned directly. However, if it is falsey, the second argument is evaluated and returned.

Unlike most functions, `Block`s can be passed as the second argument to `|`.

Examples:
```knight
| 2 (QUIT 1)   # => 2
| "hi" "there" # => "hi"
| TRUE ""      # => TRUE
| @ 4          # => 4
```

This is one of the few functions that `Block`s can be used, albeit in `|` only as the second argument.

### `;(unchanged, unchanged)` {#fn-then}
This function simply returns its second argument (after evaluating them both because of the `unchanged` context). Its entire purpose is to act as a "sequencing" function, where the first argument's value can be discarded.

Unlike most functions, `Block`s can be passed as either argument to `;`.

_Note that using `:` as the last function in a chain of `;`s can look visually appealing. See the example below_

Examples:
```knight
; = x 3 OUTPUT x # prints 3
OUTPUT ; = x 3 x # also prints 3

# simple factorial
; = i 10
; = prod 1
; WHILE i
	; = prod (* prod i)
	: = i (- i 1)
: OUTPUT prod #=> prints out 3628800
```

### `=(<special>, unchanged)` {#fn-assign}
If the first argument is not a [variable](#variables), it is considered **undefined behaviour**. (However, see the entirely optional [assign to strings](#ext-assign-to-strings) extension.)

This function evaluates the second argument, and then both assigns it to the variable in the first argument and returns it. This is the only way to update variables within Knight.

Unlike most functions, `Block`s can be passed as the second argument to `=`.

Examples:
```knight
= a 3       # => 3 (a is 3)
* (= a 4) a # => 16 (a is 4)
= a = b 3   # => 3 (a and b are both three; assignments can be chained)
= "a" 4     # undefined, `"a"` isnt a variable
```

### `WHILE(unevaluated, unevaluated)` {#fn-while}
This function should evaluate the second argument as long as the first argument evaluates to a truthy value. After the first argument becomes falsey, `null` should be returned.

Note that, unlike most programming languages, Knight does not have a builtin way to "`continue`" or "`break`" from a loop. The only way a `WHILE` stops is once its condition becomes false. (However, see the highly optional [Control flow](ext-control-flow) extension if you want to attempt adding them in.)

Examples:
```knight
# simple factorial
; = i 10
; = prod 1
; WHILE i
	; = prod (* prod i)
	: = i (- i 1)
: OUTPUT prod #=> prints out 3628800

# look through a string for the first digit
; = string "hello, th3re, world!"
; = index 0
; = found FALSE
; WHILE & !found (< index LENGTH string)
	; = chr GET string index 1
	: IF & (< '/' chr) (< chr ':')
		: = found true      # if true, "break"
		: = index + index 1 # if false
: OUTPUT IF found
	(+ "the first digit occurs at index" index)
	"no digit was found"
```

## Ternary (Arity 3) {#ternary-fns}
### `IF(boolean, unevaluated, unevaluated)` {#fn-if}
If the first argument is truthy, this function will evaluate and return the second argument. However, if it's falsey, it will evaluate and return the third argument.

Unlike most functions, `Block`s can be passed as either the second or third argument to `IF`.

Examples:
```knight
IF @ "nonempty" "empty"    # => "empty"
IF 1 2 3                   # => 2
IF FALSE QUIT 1 "!"        # => "!"; it wont quit.
IF "0" TRUE QUIT 1         # => true
```

### `GET(unchanged, integer, integer)` {#fn-get}
The return value of this function depends on its first argument's type:

- **`String`**: Returns a substring starting at the second argument with a length of the third argument. Indexing starts at `0`. It is **undefined behaviour** for either the second or third arguments to be negative, or their sum to be larger than the length of the string.
- **`List`**: Returns a sublist starting at the second argument with a length of the third argument. Indexing starts at `0`. It is **undefined behaviour** for either the second or third arguments to be negative, or their sum to be larger than the length of the list.
- **All other types**: **undefined behaviour**.

To put it in plainer terms, `GET` is used to get the substring/sublist at the range `[start, start+length)`, with it being **undefined behaviour** for any part of the range to not be fully contained within the original list.

Examples:
```knight
GET "" 0 0       # => ""
GET "abcde" 2 2  # => "cd"
GET "abcde" 2 0  # => ""
GET "abcde" 5 1  # => undefined, `5+1 > length("abcde")`
GET "abcde" 5 0  # => "" (`5 <= length("abcde")`)
GET "abcde" 4 1  # => "e"
GET "abcde" ~1 1 # => undefined, negative start
GET "abcde" 1 ~1 # => undefined, negative length

GET @ 0 0          # => empty list
GET (+@12345) 2 2  # => list of 3 then 4
GET (+@12345) 2 0  # => empty list
GET (+@12345) 5 1  # => undefined, `5+1 > length(+@12345)`
GET (+@12345) 5 0  # => empty list (`5 <= length(+@12345)`)
GET (+@12345) 4 1  # => list of just 5
GET (+@12345) ~1 1 # => undefined, negative start
GET (+@12345) 1 ~1 # => undefined, negative length
```

## Quaternary (Arity 4) {#quaternary-fns}
### `SET(unchanged, integer, integer, coerce)` {#fn-set}
The return value of this function depends on its first argument's type:

- **`String`**: Returns a new string where the substring of the first argument, starting at the second argument with length of the third argument, is replaced by the fourth argument coerced to a string. It is **undefined behaviour** for either the second or third arguments to be negative, or their sum to be larger than the length of the string.
- **`List`**: Returns a new list where the sublist of the first argument, starting at the second argument with length of the third argument, is replaced by the fourth argument coerced to a list. It is **undefined behaviour** for either the second or third arguments to be negative, or their sum to be larger than the length of the list.
- **All other types**: **undefined behaviour**.

`SET` is used to replace the substring/sublist at the range `[start, start+length)` with the fourth argument. It is **undefined behaviour** for any part of the range to not be fully contained within the original list.

Examples:
```
SET "" 0 0 "Hello"  # => "Hello"
SET "abcd" 2 1 "!"  # => "ab!d" (replaces)
SET "abcd" 2 0 "!"  # => "ab!cd" (inserts before index `2`)
SET "abcd" 1 2 TRUE # => "atrued" (replaces range)
SET "abcd" 0 2 @    # => "cd" (deletes range; @ to string is empty)

SET @ 0 0 "Hello"        # => list of "H", "e", "l", "l", and "o"
SET (+@1234) 2 1 ,9      # => list of 1, 2, 9, and 4 (replaces)
SET (+@1234) 2 0 "!"     # => list of 1, 2, "!", 3, and 4 (inserts before index `2`)
SET (+@1234) 1 2 (+@789) # => list of 1, 7, 8, 9, and 4 (replaces range)
SET (+@1234) 0 2 @       # => list of 3 and 4 (deletes range; "" to list is empty)
```

# Extensions
This section describes some _entirely optional_ extensions that Knight implementations could add. These are not required to be implemented, and are just some ideas for things implementations could add to make writing Knight more ~~enjoyable~~ bearable to write in.

Again, **absolutely nothing described in this section is required by the Knight specifications**. Knight programs that want to be maximally portable should not assume any of these are supported.

Note that, aside from the `X` function, Knight reserves the right to use any upper case letter or symbol as a function name in future revisions of the specifications.

## Command Line Arguments {#ext-command-line-arguments}
While not strictly required, (because not every implementation language can access command-line arguments — such as Knight itself), there is a standardized set of command-line options that most Knight implementations follow:

- If two arguments are given, and the first is `-e`, interpret the second as a Knight program and execute it.
- If two arguments are given, and the first is `-f`, interpret the second as a path to a Knight program. Read the contents of that file, and then execute those. 
- If no arguments are given, then print out a usage message (eg. `usage: knight (-e 'expr' | -f <path>)`)

Note that the Knight unit tester expects `-e 'expr'` to be defined, and you won't be able to use it without this.

### Alternatives
Some programming languages (such as AWK) are not able to be invoked with a simple `./knight -e 'OUTPUT "hi"'`, and require extra flags (eg AWK's `./knight.awk -- -e 'OUTPUT "hi'`). If desired, you could simply make a wrapper shell file that executes your program, such as:
```shell
#/bin/sh
./knight.awk -- "$@"
```

If a language does not support command-line arguments, you may want to try reading a single line from stdin as all the command line arguments. A wrapper script might look like:
```shell
#/bin/sh
cat <(echo "$*") /dev/stdin | ./knight
```

## Handling Undefined Behaviour {#ext-handling-undefined-behaviour}
The Knight specs have a lot of undefined behaviour, leaving a lot up to implementations. This means that writing Knight programs has a lot of potential pitfalls. As such, you may want to catch some forms of undefined behaviour, and exit gracefully.

Some forms of UB may be easier than others: Division by zero is usually pretty easy to detect, but it may be inefficient or cumbersome to ensure that every string is not longer than the maximum integer size. Implementations can pick and choose which ones they handle and which ones they don't.

## Functions {#ext-functions}
These extensions are additional functions implementations can define, or slightly modify how existing ones work.

### The `X` Function. {#ext-x-function}
The function `X` is explicitly reserved for functions: Knight will never use `X` for function names, and implementations are free to use it how they want.

Since its semantics are entirely implementation defined, it's possible to "overload" it. That is, unlike how `R`, `RAND`, `RAND_INT`, etc. are all the same function, implementations may choose to have different functions starting with `X`, e.g., `X_OPENFILE`, `X_READFILE`, `X_CLOSEFILE`.

### `VALUE(string)`: Dynamically look up variables {#ext-value}
This function could perform reflection by converting its argument to a string, and then interpreting it as a variable name, looking up that value.

Examples:
```knight
; = ab 3
: OUTPUT VALUE + "a" "b" # prints out 3
```

### Assign to strings within `=`	{#ext-assign-to-strings}
In base Knight, the only valid first argument of `=` is a variable: Everything else is undefined behaviour. However, implementations could overload `=` so that if, after evaluating the first argument, it is a string, it is interpreted as a variable name.

If you want to get really fancy, you could also do destructuring assignment — if the first argument is a list, you convert the second argument to a list, and sequentially assign values.

Examples:
```knight
# Normal assign to strings
; = (+ "a" "b") 3
: OUTPUT ab         #=> prints out 3

# assign to lists
; = (+@"ab") (+@12)
; OUTPUT a          # => prints out 1
: OUTPUT b          # => prints out 2
```

### `HANDLE(unevaluated, unevaluated)`: Try-catch {#ext-handle}
If your implementation doesn't immediately abort for errors, you may want a "try-catch" function: The first argument should be evaluated, and its value returned as normal. However, if any errors occurred during this time, the second argument should be evaluated, and its value returned instead. You may also want to set the message of the exception to the variable `_` for fun.

To implement this, you will have to handle some forms of undefined behaviour (otherwise, there'd be no way to detect errors). Which ones you handle are up to you.

Examples:
```knight
HANDLE (+1 2) 9 # => 3, because no errors occurred
HANDLE (/1 0) 9 # => 9, because division by zero occurred

# if you do the super-optional `_` part
OUTPUT HANDLE (/ 1 0) _ # => prints out the division by zero error message
```

### `YEET(string)`: Throw an exception {#ext-yeet}
Instead of implementing the normal method of aborting with an error (`; OUTPUT "errmsg" QUIT 1`), implementations could opt for `YEET`ing an error. If implementations abort immediately, this could be similar to the normal method. However, if they have exceptions, this could be used in conjunction with [`HANDLE`](#ext-handle) to create a custom error framework.

Examples:
```knight
YEET "oops" # => crash with the error message "oops"

; = double_even BLOCK
	: IF (% number 2)
		: YEET "not even"
	: * number 2

; = number +0 PROMPT
: HANDLE
	: OUTPUT +++"double " number " is " CALL double_even
	: OUTPUT +++"unable to double " number ":" _
```

### `USE(string)`: Import other Knight files {#ext-use}
In Knight, there is no way to import files. This means that every single Knight program will be a single file, which can get unwieldy for larger programs. Implementations may want to implement a `USE` function for importing files.

A few other ideas:

- Import path is relative from the `USE`ing file
- The `.kn` extension can be omitted (and would be inferred)
- Duplicate imports could be skipped 
- Only accept static strings at the top of a file

Examples:
```
# /code/knight/greet.kn
: = greet BLOCK
	: OUTPUT ++ greeting ", " place

# /code/knight/main.kn
; USE "/code/knight/greeting.kn" # if no relative files
; USE "greeting.kn"              # if relative files
; USE "greeting"                 # if omit extension
# (Only import the file once if skipping duplicates)

; = greeting "Hello"
; = place "world"
: CALL greet
```

### `$(string, unchanged)`: Run a shell command and return its stdout {#ext-system}
_This function was previously a required function named `` ` ``; it is now an optional extension_

This extension would convert the first argument to a string, running it as a shell command and returning the stdout as a string. The second argument would be the stdin to the function; if it was `NULL`, the subprocess would inherit the stdin of the parent process.

Some other ideas:

- If the exit status is nonzero, return the integer exit status instead
- Set a variable called `stderr` to the standard error of the subshell

### `EVAL(string)`: Evaluate a string as Knight code {#ext-eval}
_This function was previously a required function; it is now an optional extension_

This function would convert its argument to a string, and then execute it as a Knight string. (Of course, the string should be valid Knight; if it isn't, it wouldd be undefined behaviour.)

This function would act as if its invocation were replaced by the contents of the string.

Example:
```
; = a 3
; = bar "* a 4"
: OUTPUT + "a*4=" (EVAL bar)
```
should be equivalent to
```
; = a 3
; = bar "* a 4"
: OUTPUT + "a*4=" (* a 4)
```

## Syntactic Sugar {#ext-syntactic-sugar}
These extensions provide syntactic sugar for some common idioms in Knight

### `` ` ``-string literals {#ext-grave-strings}
Working with strings in Knight is a bit of a pain: There are no escape sequences, and the only way to generate a larger string is through concatenation.
```knight
OUTPUT ++++greeting ", " name ", aged " age "!
How are you?"
```
Implementations could opt to allow for `` ` `` strings, which both include escape sequences _and_ perform string interpolation.

Example:
```knight
OUTPUT `{greeting}, {name}, aged {age}!\nHow are you?`
```

### `{ ... }`: List Literal {#ext-list-literal}
Knight doesn't have list literals: Instead you must use `,` to build up lists or `+@` only with strings and small integers.

Since Knight doesn't use `{` and `}`, implementations could use them as the delimiters for a list literal. However, since these symbols would be parsed differently to anything in vanilla Knight, this extension may not be possible for some host languages.

Example:
```
? ,1      {1}     # => true
? +@123   {1 2 3} # => true
? +,1,"a" {1 "a"} # => true
```

## Additional Types {#ext-additional-types}
These extensions are additional types implementations could define.

### Floats {#ext-floats}
Knight's only native number type is the [integer](#integer). Additionally, Knight does not use the `.` symbol at all. Implementations could introduce a float data type, using the `.` for float literals (eg `1.0`).

They could follow similar conversion rules as integers (such as adding something to a float converts the second argument to a float). One thing to be careful of is to not have `^` or `/` return floats if the first argument is an integer, as that would make the program no longer spec compliant. Instead, you could overload `^` and `/` so that if the first argument is a float, the return value is a float.

Example:
```
OUTPUT 1.2           # prints 1.2
OUTPUT +0.1 123      # prints 123.1
OUTPUT / (+0.0 10) 4 # prints 2.5

# You could also use `XNAN` and `XINF` for constants
OUTPUT XINF # prints "Infinity"
OUTPUT XNAN # prints "NaN"
```

### Maps {#ext-map}
Knight doesn't have a builtin concept of map. While you can emulate them with lists of length-two lists, it's a bit kludgy to do. Implementations could define their own map type which could be more easily used

Implementations could use, for example, the `{ key : value ... }` syntax for map literals. (You could disambiguate this from list literals because the `value`s of a map would all begin with the `:` operator.)

Example:
```
{}                 # => empty map
{1 : 2}            # => a map of just 1 to 2
{"hello" : "world" # => a map of "hello" to "world" and
 123 : 456}        #    123 to 456.
```

### Objects {#ext-objects}
Implementations could define an object type. You could go as complicated or simple as you like.

Some considerations:

- Add methods to objects
- Add static methods to the type
- Add inheritance
- Add multiple inheritance

## Changing Functionality {#ext-changing-functionality}
Unlike most other extensions, these may require significant modifications to a base vanilla implementation.

### Local Variables {#ext-local-variables}
In vanilla Knight, all variables are global: This means that if any `BLOCK` modifies a variable, it will affect any other block relying upon that. Implementations could provide support for local variables, which would allow for easier recursive functions.

See also the next extension, [Methods](#ext-methods).

### Methods {#ext-methods}
In Knight, all `BLOCK`s operate exclusively upon global variables, making it unwieldy to both pass arguments and write recursive functions.

Implementations could choose to implement a "method" type, which would be passed parameters as local variables: These variables would then not overwrite global variables with the same name, and wouldn't be visible to blocks/methods the method calls.

Example:
```
# Since `{` is not a part of the Knight spec, let's use it to
# define arguments if it's after `BLOCK`
; = greet BLOCK{greeting where}
	: ++ greeting ", " where

: OUTPUT CALL greet{"Hello" "world"}
```

### Control Flow {ext-control-flow}
Vanilla Knight has absolutely no way to "exit early" from `WHILE` loops. As an extension, you could implement `XBREAK` and `XCONTINUE` functions, which would break/continue from the innermost loop.

Additionally, you may want to implement a `XRETURN` function to return early and even `XGOTO`/`XLABEL`.

Heck, you could even implement an `XFOR` or `XFOREACH` if you wanted.

## Extensibility {#ext-extensibility}
These extensions are more aimed towards implementations that intend to be libraries.

### Embedability {#ext-embedability}
_Most_ of Knight is self-contained, needing no interaction with the outside world, with a few exceptions: `OUTPUT`, `DUMP`, `PROMPT`, and `QUIT`. If writing a library, it may be prudent to make the behaviour of these commands customizable.

For example, instead of always routing `OUTPUT` to stdout, you could collect it in a string, which you'd return to the caller of your library later on.

`QUIT` is of special importance, as it is normally implemented with some form of `process.exit` function, which would _also_ exit the calling library. Instead, you could throw a `QuitError` with the status code.

### Register arbitrary native functions {#ext-native-functions}
Instead of only supporting the vanilla Knight functions (and any extensions you may have implemented), libraries may want to give the ability for users to register custom functions.

Some considerations:

- Do you only want to allow `X` functions (which would probably be the simplest, parsing-wise), or also "normal" functions?
- Are extension functions restricted to only undefined symbols, or can they override native functions too?

### Register arbitrary native types {#ext-native-types}
Instead of only supporting the vanilla Knight types (and any extensions you may have implemented), libraries may want to give the ability for users to use custom types.

For some implementations (such as those that use inheritance), this should be pretty simple: Just ensure the custom types inherit from some `Value` parent class. However for those that don't use inheritance, it may be a bit more involved.
