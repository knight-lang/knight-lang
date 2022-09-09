# Table of Contents

* [Syntax](#1-syntax)  
	1.0 [Encoding](#10-encoding)  
	1.1 [Whitespace](#11-whitespace)  
	1.2 [Comment](#12-comment)  
	1.3 [Integer](#13-integer)  
	1.4 [String](#14-string)  
	1.5 [Variable](#15-variable)  
	1.6 [Function](#16-function)  
* [Types](#2-types)  
	2.1 [Integer](#21-integer)  
	2.2 [String](#22-string)  
	2.3 [Boolean](#23-boolean)  
	2.4 [Null](#24-null)  
	2.5 [List](#25-null)  
* [Variables](#3-variables)  
* [Functions](#4-function)  
	4.1.1 [`TRUE`](#411-true)  
	4.1.2 [`FALSE`](#412-false)  
	4.1.3 [`NULL`](#413-null)  
	4.1.4 [`PROMPT`](#414-prompt)  
	4.1.5 [`RANDOM`](#415-random)  
	4.1.6 [`@`](#416-)  

	4.2.1 [`:`](#421-unchanged)  
	4.2.2 [`,`](#422-unchanged)  
	4.2.3 [`BLOCK`](#423-blockunevaluated)  
	4.2.4 [`CALL`](#424-callspecial)  
	4.2.5 [`` ` ``](#4235-string)  
	4.2.6 [`QUIT`](#426-quitnumber)  
	4.2.7 [`!`](#427-boolean)  
	4.2.8 [`LENGTH`](#428-lengthstring)  
	4.2.9 [`DUMP`](#429-dumpunchanged)  
	4.2.10 [`OUTPUT`](#4210-outputstring)  
	4.2.11 [`ASCII`](#4211-asciiunchanged)  
	4.2.12 [`~`](#4212-integer)  

	4.3.1 [`+`](#431-unchanged-coerce)  
	4.3.2 [`-`](#432--unchanged-integer)  
	4.3.3 [`*`](#433-unchanged-coerce)  
	4.3.4 [`/`](#434-unchanged-integer)  
	4.3.5 [`%`](#435-unchanged-integer)  
	4.3.6 [`^`](#436-unchanged-integer)  
	4.3.7 [`<`](#437-unchanged-coerce)  
	4.3.8 [`>`](#438-unchanged-coerce)  
	4.3.9 [`?`](#439-unchanged-unchanged)  
	4.3.10 [`&`](#4311-unchanged-unevaluated)  
	4.3.11 [`|`](#4310-unchanged-unevaluated)  
	4.3.12 [`;`](#4312-unchanged-unchanged)  
	4.3.13 [`=`](#4313-unevaluated-unchanged)  
	4.3.14 [`WHILE`](#4314-whileunevaluated-unevaluated)  
	4.3.15 [`.`](#4314-rangeunchanged-coerce)  

	4.4.1 [`IF`](#441-ifboolean-unevaluated-unevaluated)  
	4.4.2 [`GET`](#442-getstring-number-number)  

	4.5.1 [`SET`](#451-substitutestring-number-number-string)  
5. [Optional Extensions](#6-extensions) 

0. [Command Line Arguments](#0-command-line-arguments)  

# Knight (v2.0)
Knight is a simple programing language, designed with the goal of being easily implementable in nearly any language. Since each language has a slightly different way of doing things, the Knight specs may leave some things up to the implementation. This allows each language to implement Knight in the most idiomatic way possible.

## Undefined Behaviour
Throughout this document, there will be places where something is described as **undefined behaviour**. If undefined behaviour is ever encountered during the parsing or execution of a Knight program, then the entire program is invalid; implementations may do whatever they want (including ignoring the error, segfaulting, custom extension behaviour, etc.).

Some forms of undefined behaviour may be easier to check than others depending on the implementation language. For example, most implementations should be able to detect a division-by-zero error (e.g. by an exception being thrown). However, it may be more impossible to detect standard out being closed (such as in brainf\*ck). Implementations are encouraged, but not required, to handle easily-checked undefined behaviour.

To reiterate, **if undefined behaviour is encountered at any point during the parsing or execution of a Knight program, the entire program is ill-defined, and implementations may do whatever they want.**

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

Each Knight program is a single expression expression—such as `OUTPUT 3`, `; (= a 4) (OUTPUT (+ "a=" a))`, etc. Any additional tokens after this first expression (i.e. anything other than [whitespace](#whitespace) and [comments](#comments)) is **undefined behaviour**. 

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
It is **undefined behaviour** for any character not in this list to appear anywhere within Knight source code (including within [comments](#comments)) and [string](#string)s (including those returned from [`PROMPT`](#fn-prompt)). Again, implementations are free to support more than this, but this is the bare minimum.

## Whitespace
Due to the nature of Knight's syntax, whitespace isn't always necessary. For example, `OUTPUT1` should be parsed as two tokens, `OUTPUT` and `1`. However, there are some times that whitespace is needed in order to distinguish different tokens (such as between two identifiers).

Implementations are required to recognize a minimum of the following characters as whitespace:

- Tab (`0x09`, i.e. `\t`)
- Newline (`0x0a`, i.e. `\n`)
- Carriage return (`0x0d`, i.e. `\r`)
- Space (`0x20`, i.e. a space—` `)

### Interpreting `(`, `)`, and `:` as whitespace
While not defined as whitespace, implementations are free to ignore `(`, `)`, and `:` in source files. This is because for valid knight programs, `(` and `)` do nothing (see [Parenthesis Groupings](#parenthesis-groupings)), whereas [`:`](#fn-noop) is a function that simply returns its argument, and so could always be omitted.

## Comments
Comments in Knight start with pound sign (`0x23`, i.e. `#`) and go until either a newline character (`0x0a`, i.e. `\n`) or end of file is encountered. Everything after the `#` should be ignored by the parser. There are no multiline or embedded comments in Knight.

As mentioned in the [the required encoding section](#required-encoding), it's **undefined behaviour** for comments to contain illegal characters. However, like all other undefined behaviour in Knight, implementations are free to define their own behaviour when it is encountered (and thus may allow non-knight-encoding characters in comments).

For those familiar with regex, comments are `/#[^\n]*(\n|$)/`.

## Integer Literals
[Integer](#integer) literals are simply a sequence of ASCII digits (i.e. `0` (`0x30`) through `9` (`0x39`)). Leading `0`s do not indicate octal integers (e.g. `011` is the number eleven, not nine). No other bases are supported, and only integral numbers are allowed. Note that, unlike most other languages, integers are allowed to be followed by any non-digit character. As such, `+1a` should be parsed as `+` then `1` then `a`.

Like some languages, Knight doesn't have negative integer literals. Instead, the [`~`](#fn-negation) (numerical negation) function must be used: `~5`. However, implementations are free to parse this as the number `-5`, as it has the same effect.

It is **undefined behaviour** for an integer literals to be larger than the [maximum required size](#integer).

For those familiar with regex, integers are `/[0-9]+/`.

## String Literals
[String](#string) literals in Knight begin with with either a single quote (`0x27`, i.e. `'`) or a double quote (`0x22`, i.e. `"`). All characters are taken literally until the opening quote is encountered again. This means that there are no escape sequences within string literals; if you want a newline character, you will have to do:
```knight
OUTPUT "this is a newline:
cool, right?"
```
Due to the lack of escape sequences, each string may only contain one of the two types of quotes (as the same quote again denotes the end of a string). There is no difference between single quoted or double quoted strings (asides from the fact that double quotes can appear in single-quoted strings and vice versa).

It is **undefined behaviour** for string literals to not have a closing quote. While highly unlikely to be encountered in an actual program, it is also **undefined behaviour** for a string literal's length to exceed the [maximum integer size](#integer-bounds).

For those familiar with regex, strings are `/'[^']*'|"[^"]*"/`.

## Variables {#parsing-variables}
In Knight, all [variable](#variable)s are lower case (upper case letters are reserved for builtin functions). Variable names must start with an ASCII lower case letter (i.e. `a` (`0x61`) through `z` (`0x7a`)) or an underscore (`_` (`0x5f`)). After the initial letter, variable names may optionally include lower case letters, underscores, or ASCII digits (i.e. `0` (`0x30`) through `9` (`0x39`)). Note that since upper case letters are not a part of variable names, they're allowed to immediately follow variables. `+aRANDOM` should be parsed as `+`, `a`, and `RANDOM`.

Implementations are required to support variable names of at most 127 characters, although they may choose to allow longer variable names.

For those familiar with regex, variables are `/[a-z_][a-z_0-9]*/`.

## Functions {#parsing-functions}
In Knight, there are two different styles of functions: symbolic and word-based functions. In both cases, the function is uniquely identified by its first character; the distinction merely determines how the function name is parsed.

Word-based functions start with a single uppercase letter, such as `I` for `IF` or `R` for `RANDOM`, and may contain any amount of upper case letters and `_` afterwards. This means that `R`, `RAND`, `RANDOM`, `RAND_INT`, `RAND_OM_NUMBER` `R___`, etc. are all the same function—the `R` function.

In contrast, symbolic functions are functions that are a single symbol, such as `;` or `%`. Unlike word-based functions, they should not consume additional characters following them. The character stream `+++` should be parsed identically to `+ + +`—three separate addition functions.

Every function has a predetermined arity: There are no variadic functions. After parsing a function's name, an amount of expressions corresponding to that function's arity should be parsed: For example, after parsing a `+`, two expressions must be parsed, such as `+ 1 2`. It is **undefined behaviour** for a program to contain fewer expressions than are required for the function. While not necessary, it's recommended to provide some form of error message (if it's easy to implement), such as `missing argument 2 for '+'`, or even `missing an argument`.

The list of required functions are as follows. Implementations may define additional symbolic or keyword-based functions as desired. (For details on what individual functions mean, see [`Semantics`](functions).)

- Arity `0`: `TRUE`, `FALSE`, `NULL`, `@`, `PROMPT`, `RANDOM`
- Arity `1`: `:`, `BLOCK`, `CALL`, `QUIT`, `DUMP`, `OUTPUT`, `ASCII`, `LENGTH`, `!`, `~`, `,`, `[`, `]`
- Arity `2`: `+`, `-`, `*`, `/`, `%`, `^`, `<`, `>`, `?`, `&`, `|`, `;`, `=`, `WHILE`
- Arity `3`: `IF`, `GET`
- Arity `4`: `SET`

### Boolean/Null/Empty list Literals
Short note on `TRUE`/`FALSE`/`NULL`/`@`: As they are functions that take no arguments, simply return a value (true, false, null, and an empty list, respectively), they can be instead interpreted as literals. That is, there's no functional difference between parsing `TRUE` as a function, and then executing that function and parsing `TRUE` as a boolean literal.

### Implementation-Defined Functions
Implementations may define their own functions, as long as they start with an upper-case letter or a symbol. Note that the `X` function name is explicitly reserved for extensions. See [Extensions](#extensions) for more details.

## Parenthesis Groupings
Because all Knight is a polish-notation language with only fixed-arity functions (see [Functions](#functions)), grouping is not at all required to make valid programs. But writing large Knight programs can get a bit difficult, as a single mistake can lead to the parser misinterpreting everything. So, as an aid, the left and right round parenthesis (`0x28` and `0x29`, i.e. `(` and `)`) can be used to enclose expressions. It is **undefined behaviour** for these parenthesis to not enclose a single expression.

Since these parenthesis do not change the parsing of valid Knight programs, and don't affect the runtime in any way whatsoever, implementations _are free to treat them as whitespace_. These implementations will still run valid Knight programs correctly.

This requirement for valid Knight programs simply exists so that implementations that wish to do parenthesis checking won't accidentally reject valid programs. Here's some examples of programs:
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
Knight itself only has a handful of types—[`Integer`s](#todo), [`String`s](#todo), [`Boolean`s](#todo), [`Null`](#todo), [`List`s](#todo), and [`Block`s](#todo). Knight functions frequently perform coercion, converting their arguments from one type to another. As such, every type but `Block` have `integer`, `string`, `boolean`, and `list` coercions defined.

All types in Knight are **immutable**, including strings and lists.

## Coercions Overview
Many functions in Knight have contexts defined on them: They will automatically coerce their arguments from one type to another. For example, [`OUTPUT`](#operator-output) always coerces its argument into a string.

The following is a rough overview of all the different conversions. See each type's Coercion section for more details. Note that the `Block` has no conversions defined whatsoever, and using it in any conversion contexts is **undefined behaviour**.

| Conversion From \ To | [Integer](#integer) | [String](#string) | [Boolean](#boolean) | [List](#list) |
|----------------------|---------------------|-------------------|---------------------|---------------|
| [Null](#null)        | `0`                 | empty string      | `false`             | empty list    |
| [Integer](#integer)  | &lt;itself&gt;      | what you expect   | nonzero?       | digits (negate if negative) |
| [String](#string)    | like C's `atoi`     | &lt;itself&gt;    | nonempty? | individual chars |
| [Boolean](#boolean)  | `1` for true, `0` for false | `"true"` or `"false"`| &lt;itself&gt; | empty list for false, <br> boxed `TRUE` for true |
| [List](#list)        | Length of list      | list [joined](#operator-join) by newline | nonempty? | &lt;itself&gt; |

### Evaluation of Types
All builtin types in Knight (i.e. Integer, String, Boolean, Null, and List) when evaluated, should return themselves. This is in contrast to variables and functions, which may return different values each time they're evaluated.

## Integer
In Knight, only integral numbers exist—all functions which might return non-integral numbers are simply truncated (look at the the functions' respective definitions for details on what exactly truncation means in each case).

### Bounds {#integer-bounds}
All implementations must be able to represent all integers within the range `-2147483648 .. 2147483647`, inclusive on both sides. (These are the bounds for 32-bit signed integers using 2's complement.) Implementations are free to support larger, and smaller integers (for example, by using a 64 bit integer), however this is the bare minimum.

Note that all mathematical operations in Knight that would cause over/underflow for integers is considered **undefined behaviour**. This allows for implementations to freely use larger integer sizes and not have to worry about wraparounds.


### Contexts {#integer-contexts}
(See [here](#contexts) for more details on contexts.)

- **integer**: In integer contexts, the integer itself is simply returned.
- **string**: In string contexts, integers are converted to their base-10 representation. Negative integers should have a `-` prepended to the beginning of the string (and positive integers shouldn't get `+`). For example, `0 -> "0"`, `123 -> "123"`, and `~12 -> "-12"`.
- **boolean**: In boolean contexts, zero becomes `false`, and all other integers (ie nonzero) become `true`.
- **list**: In list contexts, the digits of the integer should be returned in ascending order. If the integer is negative, each digit shall become negated as well. For example, `+@123` would return a list of `1`, then `2`, then `3`, whereas `+@~123` would return a list of `-1`, `-2`, and `-3`.

## String
Strings in Knight are like strings in most other languages, albeit a bit simpler: They're immutable (like all types within Knight), and are _only_ required to be able to represent a [specific subset of ASCII](#required-encoding). Implementations are free to support more characters (e.g. all of ASCII, or Unicode), but this is not required.

Note that, while fairly uncommon in practice, it still is **undefined behaviour** for Knight programs to attempt to create strings with a length larger than [the maximum value for integers](#integer-bounds). (Thus, `LENGTH string` will always have a well-defined result.)

### Contexts {#string-contexts}
(See [here](#contexts) for more details on contexts.)

- **integer**: (This is roughly equivalent to C's `atoi`). To convert a string to an integer, the following is done: (1) strip all leading "normal" [whitespace](#whitespace-characters), (2) an optional `+` or `-` may occur (3) take as many ascii digits as possible, stopping at the first non-digit or end of string. Interpret those digits as a string literal, negating it if `-` occurred. If no digits are found, return zero. In regex terms, this is `/^\s*([-+?\d*)/`. Note that if the resulting number is out of bounds for what the integer type can handle, it is **undefined behaviour**.
- **string**: In string contexts, the string itself is returned.
- **boolean**: In boolean contexts, only empty strings are `false`. All other strings (ie nonempty) are `true`, including things like `"0"`.
- **list**: In list contexts, the characters of the string shall be returned, with each element of the list being a string containing just that character. (For example, `+@"abc"` would return a list of `"a"` followed by `"b"` followed by `"c"`).


## Boolean
The boolean type in Knight has two variants: `false` and `true`. These two values are used to indicate truthiness within Knight, and is the type that's should be converted to within boolean contexts.

### Contexts {#boolean-contexts}
(See [here](#contexts) for more details on contexts.)

- **integer**: In integer contexts, `false` becomes `0` and `true` becomes `1`.
- **string**: In string contexts, `false` becomes `"false"` and `true` becomes `"true"`.
- **boolean**: In boolean contexts, the boolean itself is simply returned.
- **list**: In list contexts, `false` becomes an empty list and `true` becomes a list just containing `TRUE`. (i.e. `+@FALSE` is equivalent to `@`, whereas `+@TRUE` is equivalent to `,TRUE`).


## Null
The `null` type is used to indicate the absence of a value within Knight, and is the return value of some function (such as `OUTPUT` and `WHILE`). While it does have conversions defined for all contexts, no conversions _into_ `null` exist.

### Contexts {#null-contexts}
(See [here](#contexts) for more details on contexts.)

- **integer**: In integer contexts, null becomes `0`.
- **string**: In string contexts, null becomes an **empty string** (notably, not `"null"`, as some languages do).
- **boolean**: In boolean contexts, null becomes `false`.
- **list**: In list contexts, null becomes an empty list.


## List
Lists are the only container type defined in Knight. Like most runtime languages, lists in Knight are heterogeneous—that is, the same list must be able to hold multiple values (e.g. both an integer and a string). Additionally, like strings, lists and entirely immutable: All operations that would normally modify a list in other languages simply returns a new list in Knight. Lastly, lists are ordered.

Note that, while fairly uncommon in practice, it still is **undefined behaviour** for Knight programs to attempt to create lists with a length larger than [the maximum value for integers](#integer-bounds). (Thus, `LENGTH list` will always have a well-defined result.)

### Contexts {#list-contexts}
(See [here](#contexts) for more details on contexts.)

- **integer**: In integer contexts, lists return their length.
- **string**: In string contexts, lists should have their elements converted to a string, with a newline inserted between each element. (This is the same as calling the [`^` operator](#power-operator) with a newline as the second argument). Because of this, an empty list becomes an empty string, and a list of just one element becomes just that element's string value.
- **boolean**: In boolean contexts, empty lists return `false`, and all other (i.e. nonempty) lists return true.
- **list**: In list contexts, the list itself is simply returned.

### List Literals
Due to Knight's fixed-arity syntax, it's impossible to have list literals (although you could definitely add them as an extension if you wanted). There's generally three ways to create lists in Knight:
```knight
# Way 1, automatic coercion by adding something to `@`
+@123   # => a list of `1`, `2`, and `3`.
+@"abc" # => a list of `"a"`, `"b"`, and `"c"`.

# Way 2, adding "boxed" elements together:
+ (+ ,1 ,2) ,3 # => also a list of `1`, `2`, and `3`.
+ ,TRUE ,FALSE # => a list of `true` and `false`

# Way 3, doing some form of iteration:
; = list @
; WHILE > 100 list # until the list is 100 elements long
	: = list + list ,LENGTH list # add the length of the list to it.
```

## Block
The black sheep of Knight's types, the Block type is created in exactly one way: The return value of the `BLOCK` function. Blocks are used to used to delay execution of a piece of code until later, which acts as sort of a poor-man's function. The only way to execute a block's body is through the `CALL` function, which accepts only a single argument: the block to execute. Blocks do not take arguments, as all arguments are global variables.

### Contexts {#block-contexts}
The Block type does not have any contexts defined. Attempting to coerce a Block into anything results in **undefined behaviour**.

### Valid functions for Blocks
Because blocks aren't allowed to be used in any contexts, there's only a handful of places they may be used. Attempting to use them anywhere else is considered **undefined behaviour**

- The sole argument to `:`, `BLOCK` itself (ie `BLOCK BLOCK ...`), `CALL`, and `,`.
- The second argument to `=`, `&`, or `|`
- Either argument of `;`
- Either the second or third argument of `IF`

Notably, functions like `?` and `DUMP` do not require you to handle blocks at all.

# Variables
All variables in Knight are global and last for the duration of the program; there are no function-local variables. This means that once a variable is assigned a value, the variable should be accessible at any point for the duration of the program. Also, like most runtime languages, variables are not typed—you can assign a string to a variable that previously held a block.

Implementations are only required to support variables between 1 and 127 characters long, however they may choose to support longer. As is described in the [variable parsing](#variable-parsing) section, names must conform to the regex `/[a-z_][a-z0-9_]/`.

## Possible optimizations for Variables
Note that while technically you're required to have every variable accessible at all times, and able to be assigned every type, Knight supports no form of introspection or evaluation (without optional extensions such as `EVAL` or `VALUE`). That is, there's no way at runtime to dynamically assign a variable name. So, if you can prove that a variable is unused after a certain point, or is only assigned a specific type, you should feel free to perform optimizations.

## Variable Evaluation
When evaluated, the variable must return the value previously assigned to it, unevaluated. That is, if you say had `= foo BLOCK (QUIT 1)` beforehand and later on evaluated `foo`, it should return the block, and _not_ quit the program. Note that it's possible for multiple variables to be associated with the same object within Knight (e.g. `= foo (= bar ...)`).

It's considered **undefined behaviour** to attempt to evaluate a variable when it hasn't been assigned a value yet. 

<!-- ## Contexts
In all contexts, variables should be evaluated and the result of evaluating it shall be then coerced to the correct context. For example, `+ 2 a` should first lookup `a`'s value, then coerce that value to an integer, than add it to `2`. -->

# Functions
Every function in Knight has a predetermined arity—there are no variadic functions.

Unless otherwise noted, all functions will _evaluate_ their arguments beforehand. This means that `+ a b` should fetch the value of `a`, the value of `b`, and then add them together, and should _not_ attempt to add a literal identifier to another literal identifier (which doesn't even make sense).

All arguments _must_ be evaluated in order (from the first argument to the last)—functions such as `;` rely on this.

As mentioned before, any operators which would return a number outside of the implementation-supported number range, the return value is undefined. (i.e. integer overflow is an undefined operation.)

### Evaluation Contexts
Certain functions impose certain contexts on their arguments, coercing other types to the required type. (See the [`Context`](#contexts) section for exact semantics.) The following are the contexts used within this document:

- `string`: The argument must be evaluated, and then converted to a [String](#string).
- `boolean`: The argument must be evaluated, and then converted to a [Boolean](#boolean).
- `integer`: The argument must be evaluated, and then converted to an [Integer](#integer).
- `list`: The argument must be evaluated, and then converted to a [List](#list).
- `coerced`: The argument must be evaluated, and will then be coerced based on the first argument.
- `unchanged`: The argument must be evaluated, and is passed unchanged.
- `unevaluated`: The argument must not be evaluated at all.

## Nullary (Arity 0)

### `TRUE()` {#fn-true}
The function `TRUE` simply returns the true boolean value.

As discussed in the [Function Literals](#function-literals) section, `TRUE` may either be interpreted as a function of arity 0, or a literal value—they're equivalent. See the section for more details.

### `FALSE()` {#fn-false}
The function `FALSE` simply returns the false boolean value.

As discussed in the [Function Literals](#function-literals) section, `FALSE` may either be interpreted as a function of arity 0, or a literal value—they're equivalent. See the section for more details.

### `NULL()` {#fn-null}
The function `NULL` simply returns the null value.

As discussed in the [Function Literals](#function-literals) section, `NULL` may either be interpreted as a function of arity 0, or a literal value—they're equivalent. See the section for more details.

### `@()` {#fn-empty-list}
The function `@` simply returns the an empty list. This function exists because there's no easy way to get an empty list (other than `GET ,1 0 0`, which is terrible.)

As discussed in the [Function Literals](#function-literals) section, `@` may either be interpreted as a function of arity 0, or a literal value—they're equivalent. See the section for more details.

### `PROMPT()` {#fn-prompt}
The prompt function must read a line from stdin until the `\n` character is encountered, or an EOF occurs, whatever happens first. If the line ended with `\r\n` or `\n`, those character must be stripped out as well, regardless of the operating system. The resulting string (without trailing `\r\n`/`\n`) must be returned.

If EOF is reached before anything is read, `NULL` must be returned. This is to distinguish between end-of-file and a blank line (which would be just `\n` or `\r\n` before stripping).

It is **undefined behaviour** if an implementation is not able to read from stdin (e.g. it's closed, permissions issue, etc., but _not_ EOF was reached, see previous line).

If the line that's read contains any characters that are not allowed to be in Knight strings (see [String](#string-type)), this function's behaviour is undefined.

### `RANDOM()` {#fn-random}
This function must return x (pseudo) random number between 0 and, at a minimum, 32767 (`0x7fff`). Implementations are free to return a larger random number if they desire; however, all random integers must be zero or positive.

Note that `RANDOM` _should_ return different integers across subsequent calls and program executions (although this isn't strictly enforceable, by virtue of how random integers work). However, programs should use a somewhat unique seed for every program run (e.g. a simple `srand(time(NULL)))` is sufficient).

## Unary (Arity 1)

### `:(unchanged)` {#fn-noop}
A no-op: Simply returns its value unchanged (after executing it of course).

Note that `:` is the "no-op" function, and can be safely considered whitespace.

### `BLOCK(unevaluated)` {#fn-block}
Unlike nearly every other function in Knight, the `BLOCK` function does _not_ execute its argument—instead, it returns the argument, unevaluated. This is the only way for knight programs to get unevaluated blocks of code, which can be used for delayed execution.

The `BLOCK` function is intended to be used to create user-defined functions (which can be run via [`CALL`](#fn-call).) However, as it simply returns its argument, there's no way to provide an arity to user-defined functions: you must simply use global variables:
```knight
; = max BLOCK
   : IF (< a b) a b
; = a 3
; = b 4
: OUTPUT + "maximum of a and b is: " (CALL max)
```
See the [Block type](#ty-block) for exact semantics of how to use `BLOCK`'s return value.

### `CALL(<special>)` {#fn-call}
Just as [`BLOCK`](#fn-block) delays the execution of its argument, `CALL` should "resume execution" of the argument, evaluating as if the `BLOCK` as defined at the call site.

Examples:
```knight
; = foo BLOCK bar
; = bar 3
; OUTPUT CALL foo # => 3
; = bar 4
: OUTPUT CALL foo # => 4
```

Calling this function with anything other than [`BLOCK`](#fn-block)'s return value is considered **undefined behaviour**.

### `QUIT(number)` {#fn-quit}
Stops the entire Knight program with the given status code.

It is **undefined behaviour** if the given status code is not within 0 to 127. (However, since it is undefined behaviour, implementations are free to accept status codes outside this range.)

Examples:
```knight
QUIT 12    # => exit with status 12
QUIT 0     # => exit with status 0
QUIT "126" # => exit with status 126
QUIT ~1    # undefined behaviour
```

### `OUTPUT(string)` {#fn-output}
Writes the string to stdout, flushes stdout, and then returns `null`.

Normally, a newline should be written after `string` (which should also flush stdout on most systems.) However, if `string` ends with a backslash (`\`), the backslash is _not written to stdout_, and trailing newline is suppressed. 

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

It's **undefined behaviour** if an implementation is not able to write to stdout for some reason (e.g. it's closed, permission issues, etc.).

### `DUMP(unchanged)` {#fn-dump}
Dumps a debugging representation of its argument to stdout, and then returns it.

This function is meant to be used for debugging purposes (and unit testing), and not in finished Knight programs. As such, there is no strict requirement for the debugging representation.

However, if you want to use the Knight unit tests, then the output of this must conform to the following regexes, or the tester will get confused. (**TODO**: update these when the unit tester becomes updated.)

- `Null()`,
- `Integer(<number>)` - `<number>` should be base-10, with a leading `-` if negative.
- `Boolean(<bool>)` - `<bool>` must be either `true` or `false`.
- `String(<string>)` - The literal contents of the string—no escaping whatsoever should be performed. (e.g. `DUMP "foo'b)ar\"` should write `String(foo'b)ar\)`).
- `List(...)` 

Note that it is **undefined behaviour** to pass a `Block` to this function, and the unit tester won't test for those. Thus, implementations may print out blocks if they want.

Like [`OUTPUT`](#fn-output), it's **undefined behaviour** if there's any issues writing to stdout.

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
Returns the logical negation of its argument—truthy values become `false`, and falsey values become `true`.

Examples:
```knight
!TRUE # => false
!1234 # => false
!""   # => true
!,0   # => true
```


### `~(number)` {#fn-negate}
Converts the argument to a number, then negates it. Note that this is numeric negation (i.e. like unary `-` in other languages) and _not_ bitwise negation.

Examples:
```knight
~38      # => -38
~0       # => 0
~(- 1 2) # => 1
~~5      # => 5
~TRUE    # => -1
~,123    # => -1
```

### `ASCII(unchanged)` {#fn-ascii}
The return value of this function depends on its first argument's type:

- **`Integer`**: Interprets it as an ASCII codepoint, and returns a string containing just that character. It is **undefined behaviour** if the codepoint is not [in the encoding](#required-encoding).
- **`String`**: Converts and returns the first character's ASCII numerical equivalent. It is **undefined behaviour** for the string to be empty.
- **All other types**: **undefined behaviour**

Implementations may feel free to extend `ASCII` to go beyond ascii, and to use support unicode. However, this is not required.

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
This function returns a list containing just its argument. In python terms, `lambda x: [x]`.

Examples:
```knight
,1   # => a list of just 1
,,"" # => a list of just a list of ""
,,@  # => a list of just an empty list
```

### `[(unchanged)` {#fn-head}
The return value of this function depends on its first argument's type:

- **`String`**: Returns the a string of just first character. It is **undefined behaviour** for the string to be empty.
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

## Binary (Arity 2)
### `+(unchanged, coerced)` {#fn-add}
The return value of this function depends on its first argument's type:

- **`Integer`**: The second argument is coerced to an integer, and added to the first.
- **`String`**: The second argument is coerced to a string, and appended to the first.
- **`List`**: The second argument is coerced to a list, and then added to the first.
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

- **`Integer`**: The second argument is coerced to a number, and then subtracted from the first.
- **All other types**: **undefined behaviour**

Examples:
```knight
- 3 "2a" #=> 1
- ~1 4   #=> -5
```

### `*(unchanged, coerced)` {#fn-multiply}
The return value of this function depends on its first argument's type:

- **`Integer`**: The second argument is coerced to a number, and multiplied with the first
- **`String`**: The second argument is coerced to an integer, and then the first is repeated that many times. It is **undefined behaviour** if the second argument is negative.
- **`List`**: The second argument is coerced to an integer, and then the first is repeated that many times. It is **undefined behaviour** if the second argument is negative.
- **All other types**: **undefined behaviour**

Examples:
```knight
* 3 "2a"  # => 6
* 3 FALSE # => 0
* "2a" 3  # => "2a2a2a"
* (,1) 5  # => a list of 5 1s
* "2a" ~3 # undefined, negative length
* (,1) ~1 # undefined, negative length
```

###  `/(unchanged, coerced)` {#fn-divide}
The return value of this function depends on its first argument's type:

- **`Integer`**: The second argument is coerced to a number, and then divided from the first. Non-whole results must be rounded towards zero. It is **undefined behaviour** for the second argument to be zero.
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

- **`Integer`**: The second argument is coerced to am integer, and then the remainder of `<arg1> / <arg2>` is returned. You should round towards zero. Note that this means that, for all `a`, `a = (a/b)*b + a%b`. It is **undefined behaviour** for the second argument not to be a strictly positive integer.
- **All other types**: **undefined behaviour**

```
% 7 3    # => 1
% ~5 2   # => -1
% ~7 5   # => -2
% 7 0    # undefined
% 7 ~2   # undefined
```

### `^(unchanged, coerce)` {#fn-power}
The return value of this function depends on its first argument's type:

- **`Integer`**: The second argument is coerced to an integer, and then the first integer is raised to the power of the second integer. Note that `^ 0 1` should return `1`. It is **undefined behaviour** for the second argument to be negative. (Note that, like all integer functions, it is **undefined behaviour** for this function to overflow.)
- **`List`**: The second argument is coerced to a string. Then, each element of the list is converted to a string and concatenated together, with the second argument being inserted between adjacent elements. This is known as the **join** operator.

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

### `<(unchanged, coerced)` {#op-less-than}
The return value of this function depends on its first argument's type:

- **`Integer`**: Coerces the second argument to an integer, then returns whether the first is smaller than the second.
- **`String`**: Coerces the second argument to a string, and then returns whether the first is lexicographically smaller than the second. See below for details on Lexicographical comparisons.
- **`Boolean`**: Coerces the second argument to a boolean, and returns whether the first is false and the second is true.
- **`List`**: Coerces the second argument to a list, and then compares each element of the two, returning the whether the non-equal comparison is less than. If each element is equal, return whether the first list is smaller. (This is how most languages which define comparisons on lists/arrays do it.)
- **All other types**: **undefined behaviour**.

Lexicographical comparisons should find the first non-equivalent character in each string and compare them based on their ASCII value (e.g. in `abcd` and `abde`, `c` and `d` would be compared), returning `tRUE` if the first argument's character is smaller. If both strings have equivalent characters, then this function shall return `true` only if the first string has a smaller size than the second. 

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

### `>(unchanged, coerced)` {#op-greater-than}
This is exactly the same as [`<`](#op-less-than), except for operands reversed, i.e. `> a b` should return the same value as `< b a` (barring the fact that `a` should be evaluated before `b`).

Examples:
See [`<`](#op-less-than).

### `?(unchanged, unchanged)` {#op-equals}
Unlike nearly every other function in Knight, this one does not automatically coerced its arguments—instead, it checks to see if arguments are the same type _and_ value. For example, `1` is equivalent to neither `"1"` nor `TRUE`.

This function is only valid for the "basic types" (`Integer`, `String`, `Boolean`, `Null`, and `List`). Notably, it is **undefined behaviour** for either argument to be a `Block`.

Examples:
```knight
? 1 2        # => false
? ~0 0       # => true
? "1" "1 "   # => false
? FALSE NULl # => false
? NULL NULL  # => true
? ,@ ,,@     # => false
```

### `&(unchanged, unevaluated)` {#op-and}
This function acts similar to `&&` in some loosely-typed languages: If the first argument (after being evaluated) is falsey, it's returned directly. However, if it's truthy, the second argument is evaluated and returned.

Unlike most functions, `Block`s can be passed as the second argument to `&`.

Examples:
```knight
& 0 (QUIT 1)   # => 0
& "hi" "there" # => "there"
& TRUE ""      # => ""
& @ 4          # => @
```

### `|(unchanged, unevaluated)` {#op-or}
Like [`&`](#op-and) and `&&`, this function acts similar to `||` in some loosely-typed languages: If the first argument (after being evaluated) is truthy, it's returned directly. However, if it's falsey, the second argument is evaluated and returned.

Unlike most functions, `Block`s can be passed as the second argument to `|`.

Examples:
```knight
| 2 (QUIT 1)   # => 2
| "hi" "there" # => "hi"
| TRUE ""      # => TRUE
| @ 4          # => 4
```

This is one of the few functions that `Block`s can be used, albeit in `|` only as the second argument.

### `;(unchanged, unchanged)` {#op-then}
This function simply returns its second argument (after evaluating them both, as per the `unchanged` context). Its entire purpose is to act as a "sequencing" function, where the first argument's value can be discarded.

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

### `=(unevaluated, unchanged)` {#op-assign}
It is **undefined behaviour** for the first argument not to be a [Variable](#variable). (However, see the entirely optional [assign to anything](#ext-assign-to-anything) extension.)

This function evaluates the second argument, and then both assigns it to the variable in the first argument and returns it. This is the only way to update variables within Knight.

Examples:
```knight
= a 3       # => 3 (a is 3)
* (= a 4) a # => 16 (a is 4)
= a = b 3   # => 3 (a and b are also three, assignments can be chained.)
= "a" 4     # undefined, `"a"` isnt a variable
```

### `WHILE(unevaluated, unevaluated)` {#op-while}
This function should continuously evaluate the second argument as long as the first argument evaluates to a truthy value. The return value of `WHILE` is always `NULL`. 

Note that, unlike most programming languages, Knight does not have a builtin way to "`continue`" or "`break`" from a loop; instead, you must change the condition to false. See the second example.

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

## Ternary (Arity 3)
### `IF(boolean, unevaluated, unevaluated)` {#op-if}
If the first argument is `true`, this function will evaluate and return the second argument. If the first argument is `false`, it will evaluate and return the third argument.

Unlike most functions, `Block`s can be passed as either the second or third argument to `IF`.

Examples:
```knight
IF @ "nonempty" "empty"    # => "empty"
IF 1 2 3                   # => 2
IF FALSE QUIT 1 "!"        # => "!"; it wont quit.
IF "0" TRUE QUIT 1         # => true
```

### `GET(unchanged, integer, integer)` {#op-get}
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

## Quaternary (Arity 4)
### `SET(unchanged, integer, integer, coerce)` {#op-set}
The return value of this function depends on its first argument's type:

- **`String`**: Returns a new string where the substring of the first argument, starting at the second argument with length of the third argument, is replaced by the fourth argument coerced to a string.. It is **undefined behaviour** for either the second or third arguments to be negative, or their sum to be larger than the length of the string.
- **`List`**: Returns a new list where the sublist of the first argument, starting at the second argument with length of the third argument, is replaced by the fourth argument coerced to a list.. It is **undefined behaviour** for either the second or third arguments to be negative, or their sum to be larger than the length of the list.
- **All other types**: **undefined behaviour**.

To put it in plainer terms, `SET` is used to replace the substring/sublist at the range `[start, start+length)` with the fourth argument, with it being **undefined behaviour** for any part of the range to not be fully contained within the original list.

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

# 6 Extensions
This section describes possible extensions that Knight implementations could add. Because these are extensions, none of them are required to be compliant. They're simply ways to make Knight more ~~enjoyable~~ bearable to write in. 

### 6.0.1 The `X` Function.
Note that the function `X` is explicitly reserved for extensions: Knight will never use `X` for function names, and implementations are free to use it as they wish. Note that since this is reserved for extensions, they're free to "overload" it. That is, you can have different functions that all start with `X`, e.g., `X_OPENFILE`, `X_READFILE`, `X_CLOSEFILE`.

## 6.1 `VALUE(string)`: Look up strings as variables
This function would convert its argument to a string, then look it up as if it were a variable name. That is, it could be a replacement for `EVAL string`, when `string` is just a variable name.

## 6.2 `~(integer)`: Unary minus
This has been incorporated into base knight as of v1.2, so this extension's no longer relevant. 

## 6.3 Counting Parenthesis
Parenthesis in Knight are whitespace, and are used simply as a way to visually group things. However, as Knight programs are quite hard to debug, you could count parenthesis and ensure that parens match

## 6.4 Handle undefined behaviour
The Knight specs have a lot of undefined behaviour to leave a lot up to implementations. However, this means that writing Knight programs has a lot of potential pitfalls. As such, you may want to catch most forms of undefined behaviour and exit gracefully. (catching _all_ forms is a bit much, e.g. integer overflow.)

## 6.5 `USE(string)`: Import other knight files
Currently, to import files, you need to use the `` ` `` function: `` EVAL ` + "cat " filename ``. However, this is quite dangerous if `filename` has any shell characters in it. 

## 6.6 Extensibility 
### 6.6.1 Ability to register new, arbitrary native functions
### 6.6.2 Ability to register new, arbitrary native types
(e.g. arrays, floats)
### 6.6.3 Embedability (i.e. toggle "dangerous"/io commands.)


	4.2.2 [`EVAL`](#422-evalstring)  

# 0. Command Line Arguments
If possible, Knight implementations are expected to parse command-line arguments. Program names, such as `argv[0]` in C, aren't considered part of the command line arguments.

If the first argument is `-e`, then the second argument must be interpreted as a Knight program and be executed directly.

If the first argument is `-f`, then the second argument must be interpreted as a filename. The file's contents should then be interpreted as Knight program. If any errors occur when accessing the file (such as: it doesn't exist, no read access, etc.), then the program's behaviour is undefined.

Implementations are free to define additional flags and behaviours outside of these requirements. (For example, printing a usage message when the first argument is not recognized.) However, these are not required: Programs which are not passed exactly one of the two previous options are considered ill-formed

## Alternatives
Some programming languages (such as AWK) are not able to be invoked with a simple `./knight -e 'OUTPUT "hi"'`. While not ideal, implementations may define alternative ways to pass arguments, such as AWK's `./knight.awk -- -e 'OUTPUT "hi'`.

Some programming languages don't provide a way to access command line arguments at all, such as Knight itself. In this case, the program should read lines from stdin in place of command line arguments.

### 4.2.2 `EVAL(string)`
This function takes a single string argument, which should be executed as if it where Knight source code. As such, the string should be valid Knight source code for your implementation. (i.e. a single expression, possibly with trailing tokens, depending on how the parser was impelmented.)

This function should act _as if_ its invocation were replaced by the contents of the string, e.g.:
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

### 4.2.5 `` `(string) ``
Runs the string as a shell command, returning the stdout of the subshell.

If the subshell returns a nonzero status code, this function's behaviour is undefined.
If the subshell's stdout does not contain characters that can appear in a string (see [String](#String)), this function's behaviour is undefined.

Everything else is left up to the implementation—what to do about stderr and stdin, whether to abort execution on failure or continue, how environment variables are propagated, etc.

