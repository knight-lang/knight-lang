# Overview
Knight is meant to be easily implementable in virtually every language imaginable. As such, the language itself is not very complicated, and the specs may leave some things up to the implementation. This allows each language to implement it in the most idiomatic way possible.

## Notation
In this document, some notation is used to describe what is required of implementations:
- The words **required**/**must**/**shall** indicates directions implementations if they want to be valid.
- The word **undefined** is used to indicate that behaviour is undefined: Programs that contain undefined behaviour are invalid, and the interpreter does not have to provide any guarantees. (Implementations are encouraged to somehow exit, even if it be through an uncaught exception. However this is not required)

# Table of Contents

1. [Syntax](#1-syntax)  
	1.1 [Whitespace](#11-whitespace)  
	1.2 [Comment](#12-comment)  
	1.3 [Number](#13-number)  
	1.4 [String](#14-string)  
	1.5 [Variable](#15-variable)  
	1.6 [Function](#16-function)  
2. [Types](#2-types)  
	2.1 [Number](#21-number)  
	2.2 [String](#22-string)  
	2.3 [Boolean](#23-boolean)  
	2.4 [Null](#24-null)  
3. [Variable](#3-variable)  
4. [Function](#4-function)  
	4.1.1 [`TRUE`](#411-true)  
	4.1.2 [`FALSE`](#412-false)  
	4.1.3 [`NULL`](#413-null)  
	4.1.4 [`PROMPT`](#414-prompt)  
	4.1.5 [`RANDOM`](#415-random)  

	4.2.1 [`:`](#421-unchanged)  
	4.2.2 [`EVAL`](#422-evalstring)  
	4.2.3 [`BLOCK`](#423-blockunevaluated)  
	4.2.4 [`CALL`](#424-callspecial)  
	4.2.5 [`` ` ``](#425-string)  
	4.2.6 [`QUIT`](#426-quitnumber)  
	4.2.7 [`!`](#427-boolean)  
	4.2.8 [`LENGTH`](#428-lengthstring)  
	4.2.9 [`DUMP`](#429-dumpunchanged)  
	4.2.10 [`OUTPUT`](#4210-outputstring)  
	4.2.11 [`ASCII`](#4211-asciiunchanged)  

	4.3.1 [`+`](#431-unchanged-coerce)  
	4.3.2 [`-`](#432--unchanged-number)  
	4.3.3 [`*`](#433-unchanged-coerce)  
	4.3.4 [`/`](#434-unchanged-number)  
	4.3.5 [`%`](#435-unchanged-number)  
	4.3.6 [`^`](#436-unchanged-number)  
	4.3.7 [`<`](#437-unchanged-coerce)  
	4.3.8 [`>`](#438-unchanged-coerce)  
	4.3.9 [`?`](#439-unchanged-unchanged)  
	4.3.10 [`&`](#4311-unchanged-unevaluated)  
	4.3.11 [`|`](#4310-unchanged-unevaluated)  
	4.3.12 [`;`](#4312-unchanged-unchanged)  
	4.3.13 [`=`](#4313-unevaluated-unchanged)  
	4.3.14 [`WHILE`](#4314-whileunevaluated-unevaluated)  

	4.4.1 [`IF`](#441-ifboolean-unevaluated-unevaluated)  
	4.4.2 [`GET`](#442-getstring-number-number)  

	4.5.1 [`SUBSTITUTE`](#451-substitutestring-number-number-string)  
5. [Command Line Arguments](#5-command-line-arguments)  
6. [Optional Extensions](#6-extensions) 

# 1 Syntax
The language itself is inspired by Polish Notation (PN): Instead of `output(1 + 2 * 4)`, Knight has `OUTPUT + 1 * 2 4`.

Knight does not have a distinction between statements and expressions: Every function in Knight returns a value, which can be used by other functions. So, instead of `if(x < 3) { output("hi") } else { output("bye") }`, Knight does `OUTPUT IF (< x 3) "hi" "bye"`.

All characters other than those mentioned in this document are considered invalid within Knight, both within source code and strings. Notably, the NUL character (`\0`) is not permissible within Knight strings, and can be used as a deliminator within implementations.

Each Knight program consists of a single expression---such as `OUTPUT 3` or `; (= a 4) : OUTPUT(+ "a=" a)`. Any additional tokens after this first expression (ie anything other than [Whitespace](#11-whitespace) and [Comment](#12-comment)) is undefined behaviour.

## 1.1 Whitespace
Implementations are **required** to recognize the following characters as whitespace:
- Tab (`0x09`, ie `\t`)
- Newline (`0x0a`, ie `\n`)
- Carriage return (`0x0d`, ie `\r`)
- Space (`0x20`, ie a space---` `)
- All parentheses (`(`, `)`, `[`, `]`, `{`, `}`).
(Because all functions have a fixed arity (see [4. Function](#4-function)), all forms of parentheses in Knight are considered whitespace.) Implementations may define other characters as whitespace if they wish---notably, this means that you may use regex's `\s` to strip away whitespace.

## 1.2 Comment
Comments in Knight start with `#` and go until a newline character (`\n`) is encountered, or the end of the file; everything after the `#` is ignored.

There are no multiline or embedded comments in Knight.

## 1.3 Number
Number literals are simply a sequence of ASCII digits (ie `0` (`0x30`) through `9` (`0x39`)). Leading `0`s do not indicate octal numbers (eg, `011` is the number eleven, not nine). No other bases are supported, and only integral numbers are allowed.

Note that there are no negative number literals in Knight---they're constructed via the [`-`](#432--unchanged-number) function: `- 0 5`.

## 1.4 String
String literals in Knight begin with with either a single quote (`'`) or a double quote (`"`). All characters are taken literally until the opening close is encountered again. This means that there are no escape sequences within string literals; if you want a newline character, you will have to do:
```text
OUTPUT "this is a newline:
cool, right?"
```
Due to the lack of escape sequences, each string may only contain one of the two types of quotes (as the other quote will denote the end of the string.)

## 1.5 Variable
In Knight, all variables are lower case---upper case letters are reserved for functions. Variable names must start with an ASCII lower case letter (ie `a` (`0x61`) through `z` (`0x7a`)) or an underscore (`_` (`0x5f`)). After the initial letter, variable names may also include ASCII digits (ie `0` (`0x30`) through `9` (`0x39`)). The maximum length of variables should only be constrained by available memory.

## 1.6 Functions
In Knight, there are two different styles of functions: symbolic and word-based functions. In both cases, the function is uniquely identified by its first character. 

Word-based functions start with a single uppercase letter, such as `I` for `IF` or `R` for `RANDOM`, and may contain any amount of upper case letters and `_` afterwards. This means that `R`, `RAND`, `RANDOM`, `RAND_INT`, `RAND_OM_NUMBER`, etc. are all the same function---the `R` function.
_(Note: This is a change from a previous version of Knight where `_` was _ not _ a valid part of an identifier. some implementations may need to be updated)_

In contrast, Symbolic functions are functions that are composed of a single symbol, such as `;` or `%`. Unlike word-based functions, they should not consume additional characters following them, word-based or not. The characters `+++` should be interpreted identically to `+ + +`---three separate addition functions.

Each function has a predetermined arity---no variable argument functions are allowed. After parsing a function's name, an amount of expressions corresponding to that function's arity should be parsed: For example, after parsing a `+`, two expressions must be parsed, such as `+ 1 2`. Programs that contain functions with fewer than the required amount of arguments are considered undefined. While not necessary, it's recommended to provide some form of error message (if it's easy to implement), such as `missing argument 2 for ';`, or even `missing an argument for ';'`.

The list of required functions are as follows. Implementations may define additional symbolic or keyword-based functions as desired. (For details on what individual functions mean, see `# Semantics`.)

- Arity `0`: `TRUE`, `FALSE`, `NULL`, `PROMPT`, `RANDOM`
- Arity `1`: `:`, `EVAL`, `BLOCK`, `CALL`, `` ` ``,`QUIT`, `!`, `LENGTH`, `DUMP`, `OUTPUT`, `ASCII`
- Arity `2`: `+`, `-`, `*`, `/`, `%`, `^`, `<`, `>`, `?`, `&`, `|`, `;`, `=`, `WHILE`
- Arity `3`: `IF`, `GET`
- Arity `4`: `SUBSTITUTE`

Short note on `TRUE`/`FALSE`/`NULL`: As they are functions that take no arguments, and should simply return a true, false, or null value, they can be instead interpreted as literals. That is, there's no functional difference between parsing `TRUE` as a function, and then executing that function and parsing `TRUE` as a boolean literal.

### 1.5.1 Implementation-Defined Functions
Implementations may define their own functions, as long as they start with an upper-case letter or a symbol. Note that the `X` function name is explicitly reserved for extensions. See [6. Extensions](#6-extensions) for more details.

## Example
here's an example of a simple guessing game and how it should parse:
```text
; = secret random
; = guess + 0 prompt
OUTPUT if (? secret guess) "correct!" "wrong!"
```
```text
[;]
 ├──[=]
 │   ├──[secret]
 │   └──[random]
 └──[;]
     ├──[=]
     │   ├──[guess]
     │   └──[+]
     │       ├──[0]
     │       └──[prompt]
     └──[OUTPUT]
         └──[if]
             ├──[?]
             │   ├──[secret]
             │   └──[guess]
             ├──["correct!"]
             └──["wrong!"]
```

# 2 Types
Knight itself only has a handful of builtin types---Numbers, Strings, Booleans, and Null. Knight has a few different contexts (see [Functions](#Functions) for more details), of which `numeric`, `string`, and `boolean` coerce their types to the correct type. As such, all types define infallible conversions to each of these contexts.

Note that _all_ types within Knight are immutable. This means that it's a perfectly valid (and probably a good) idea to use reference counting in non-garbage-collected languages.

In addition to these types types, two additional types do exist: Identifier and Function. However, these types are only accessible via a `BLOCK`, and the only valid operation on them is to `CALL` them. As such, they do not have conversions defined on them (as doing so would be performing an operation other than `CALL`) and are not described here.

### 2.0.1 Evaluation
All builtin types in Knight (ie Number, String, Boolean, and Null) when evaluated, should return themselves. This is in contrast to identifiers and functions, which may return different values at different points during execution. 

## 2.1 Number
In Knight, only integral numbers exist---all functions which might return non-integral numbers are simply truncated (look at the the functions' respective definitions for details on what exactly truncation means in each case).

All implementations must be able to represent a minimum integral value of `-2147483648`, and a maximal integral value of `2147483647` (ie, the minimum and maximum values for a 2's complement 32-bit integer). Implementations are allowed to represent numbers outside this range---this is simply the bare minimum that's required.

### 2.1.1 Contexts
(See [here](#401-contexts) for more details on contexts.)

- **numeric**: In numeric contexts, the number itself is simply returned.
- **string**: In string contexts, numbers are converted to their base-10 representation. Negative numbers shall have a `-` prepended to the beginning of the string. (e.g. `0` -> `"0"`, `123` -> `"123"`, `- 0 12` => `"-12"`)
- **boolean**: In boolean contexts, nonzero numbers shall become `TRUE`, whereas zero shall become `FALSE`.

## 2.2 String
Strings in Knight are like strings in other languages, albeit a bit simpler: They're immutable (like all types within Knight), and can only represent a specific subset of the ASCII character set. 

Implementations are _only_ required to support the following characters within strings, although they may support additional characters if they want:
- Whitespace (see [Whitespace](#whitespace) for details)
- ASCII characters `0x21` (`!`) through `0x7e` (`~`)

That is, the following is the list of allowed characters:
```text
	[tab] [newline] [carriage return] [space] 
	  ! " # $ % & ' ( ) * + , - . /
	0 1 2 3 4 5 6 7 8 9 : ; < = > ?
	@ A B C D E F G H I J K L M N O
	P Q R S T U V W X Y Z [ \ ] ^ _
	` a b c d e f g h i j k l m n o
	p q r s t u v w x y z { | } ~
```

### 2.2.1 Contexts
(See [here](#401-contexts) for more details on contexts.)

- Tab (`0x09`, ie `\t`)
- Newline (`0x0a`, ie `\n`)
- Carriage return (`0x0d`, ie `\r`)
- Space (`0x20`, ie a space---` `)
- **numeric**: In numeric contexts, all leading whitespace (i.e. tabs (`0x09`), newlines (`0x0a`), carriage returns (`0x0d`), and spaces (`0x20`)) shall be stripped. An optional `-` may then appear to force the number to be negative. (A `+` may appear instead of a `-`, and it should simply be ignored.) Then, as many consecutive digits as possible are read, and then interpreted as if it were a number literal. In regex terms, It would be capture group of `^\s*([-+]?\d*)`. Note that if no valid digits are found after stripping whitespace and the optional `-`, the number `0` shall be used. Note that if the resulting number is too large for the implementation to handle, the conversion is undefined.
- **string**: In string contexts, the string itself is returned.
- **boolean**: In boolean contexts, nonempty strings shall become `TRUE`, whereas empty strings shall become `FALSE`.


## 2.3 Boolean
The Boolean type has two variants: `TRUE` and `FALSE`. These two values are used to indicate truthiness within Knight, and is the type that's should be converted to within boolean contexts.

### 2.3.1 Contexts
(See [here](#401-contexts) for more details on contexts.)

- **numeric**: In numeric contexts, `TRUE` becomes `1` and `FALSE` becomes `0`.
- **string**: In string contexts, `TRUE` becomes `"true"` and `FALSE` becomes `"false"`.
- **boolean**: In boolean contexts, the boolean itself is simply returned.


## 2.4 Null
The `NULL` type is used to indicate the absence of a value within Knight, and is the return value of some function (such as `OUTPUT` and `WHILE`). 

### 2.4.1 Contexts
(See [here](#401-contexts) for more details on contexts.)

- **numeric**: Null must become `0` in numeric contexts.
- **string**: Null must become `"null"` in string contexts.
- **boolean**: Null must become `FALSE` in boolean contexts.


# 3 Variable
Variables in Knight must be able to hold all the builtin types, including other variable names and functions (both of which are returned by the `BLOCK` function).

All variables in Knight are global and last for the duration of the program. (There are no function-local variables, and all `EVAL`s are done at the global scope too.). That is, once a value is assigned to a variable name, that variable name will then never be "deallocated"---value associated with it may change, but the variable will never become undefined. 

Implementations must be able to support variables between 1 and 65535 characters long, however arbitrary-length variable names are encouraged. As is described in the parsing section, variable names must start with a lower-case letter or `_`, and may be followed by any amount of digits, lower-case letters, or `_`.

## 3.1 Evaluation
When evaluated, the variable must return the value previously assigned to it, unevaluated. (That is, if you say had `= foo BLOCK { QUIT 1 }` beforehand and later on evaluated `foo`, it should return the block, and _not_ quit the program.) Note that it's possible for multiple variables to be associated with the same object within Knight (eg `= foo (= bar ...)`).

It's considered undefined behaviour to attempt to evaluate a variable when it hasn't been assigned a value yet. Implementations are encouraged to, at the minimum, abort with a message such as `uninitialized variable accessed`, however this is not a requirement.

## 3.2 Contexts
In all contexts, variables should be evaluated and the result of evaluating it shall be then coerced to the correct context. 

Expressions such as `+ (BLOCK foo) 34`, `/ 12 (BLOCK FOO)` and even `? (BLOCK foo) (BLOCK foo)` are all considered undefined. 

# 4 Functions
Every function in Knight has a predetermined arity---there are no varidict functions.

Unless otherwise noted, all functions will _evaluate_ their arguments beforehand. This means that `+ a b` should fetch the value of `a`, the value of `b`, and then add them together, and should _not_ attempt to add a literal identifier to another literal identifier (which is undefined behaviour.)

All arguments _must_ be evaluated in order (from the first argument to the last)---functions such as `;` rely on this.

Note that any operators which would return a number outside of the implementation-supported number range, the return value is undefined. (i.e. integer overflow is an undefined operation.)

### 4.0.1 Contexts
Some functions impose certain contexts on arguments passed to them. (See the `Context` section of the basic types for exact semantics.) The following are the contexts used within this document:

- `string`: The argument must be evaluated, and then converted to a [String](#String).
- `boolean`: The argument must be evaluated, and then converted to a [Boolean](#Boolean).
- `number`: The argument must be evaluated, and then converted to a [Number](#Number).
- `coerced`: The argument must be evaluated, and then converted to the type of the first argument. (This only appears in binary functions).
- `unchanged`: The argument must be evaluated, and is passed unchanged.
- `unevaluated`: The argument must not be evaluated at all.

## 4.1 Nullary (Arity 0)

### 4.1.1 `TRUE()`
As discussed in the [Boolean](#Boolean) section, `TRUE` may either be interpreted as a function of arity 0, or a literal value---they're equivalent. See the section for more details.

### 4.1.2 `FALSE()`
As discussed in the [Boolean](#Boolean) section, `FALSE` may either be interpreted as a function of arity 0, or a literal value---they're equivalent. See the section for more details.

### 4.1.3 `NULL()`
As discussed in the [Null](#Null) section, `NULL` may either be interpreted as a function of arity 0, or a literal value---they're equivalent. See the section for more details.

### 4.1.4 `PROMPT()`
This must read a line from stdin until the `\n` character is encountered, of an EOF occurs, whatever happens first. If the line ended with `\r\n` or `\n`, those character must be stripped out as well, regardless of the operating system. The resulting string (without trailing `\r\n`/`\n`) must be returned.

If stdin is closed, this function's behaviour is undefined.
If the line that's read contains any characters that are not allowed to be in Knight strings (see [String](#String)), this function's behaviour is undefined.

### 4.1.5 `RANDOM()`
This function must return a (pseudo) random number between 0 and, at a minimum, 32767 (`0x7fff`). Implementations are free to return a larger random number if they desire; however, all random numbers must be zero or positive.

Note that `RANDOM` _should_ return different numbers across subsequent calls and program executions (although this isn't strictly enforceable, by virtue of how random numbers work..). However, programs should use a somewhat unique seed for every program run (eg a simple `srand(time(NULL)))` is sufficient.)

## 4.2 Unary (Arity 1)

### 4.2.1 `:(unchanged)`
A no-op: Simply returns its value unchanged. 

Note that `:` is the "no-op" function, and can (usually) be considered whitespace. (Technically, a program that is _only_ `+ 4 :` would be undefined, as it doesn't have any arguments for `:`. however, it'd be the same as `+ 4` being undefined as well.)

### 4.2.2 `EVAL(string)`
This function takes a single string argument, which should be executed as if it where Knight source code. As such, the string should be valid Knight source code for your implementation. (ie a single expression, possibly with trailing tokens, depending on how the parser was impelmented.)

This function should act _as if_ its invocation were replaced by the contents of the string, eg:
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


### 4.2.3 `BLOCK(unevaluated)`
Unlike nearly every other function in Knight, the `BLOCK` function does _not_ execute its argument---instead, it returns the argument, unevaluated. This is the only way for knight programs to get unevaluated blocks of code, which can be used for delayed execution.

The `BLOCK` function is intended to be used to create user-defined functions (which can be run via `CALL`.) However, as it simply returns its argument, there's no way to provide an arity to user-defined functions: you must simply use global variables:
```
; = max BLOCK { IF (< a b) a b }
; = a 3
; = b 4
: OUTPUT + "max of a and b is: " (CALL max)
```

Regardless of the input, the only valid uses for the return value of this function are:
- as the right-hand-side argument to an `=` function,
- the sole argument to `:`,
- either argument of `;`,
- or or as the sole argument to `CALL`.
All other uses constitute undefined behaviour.

### 4.2.4 `CALL(<special>)`
The only valid parameter to give to `CALL` is the return value of a `BLOCK`---any other value is considered undefined behaviour. 

`CALL` will simply evaluate its argument, as if its argument were defined (without the `BLOCK`) at the invocation sight of `CALL`:
```
; = foo BLOCK bar
; = bar 3
; OUTPUT CALL foo # => 3
; = bar 4
: OUTPUT CALL foo # => 4
```

### 4.2.5 `` `(string) ``
Runs the string as a shell command, returning the stdout of the subshell.

If the subshell returns a nonzero status code, this function's behaviour is undefined.
If the subshell's stdout does not contain characters that can appear in a string (see [String](#String)), this function's behaviour is undefined.

Everything else is left up to the implementation---what to do about stderr and stdin, whether to abort execution on failure or continue, how environment variables are propagated, etc.

### 4.2.6 `QUIT(number)`
Aborts the entire knight interpreter with the given status code.

Implementations must accept exit codes between 0 to 127, although they can permit higher status codes if desired.

	It is undefined behaviour if the given status code is not supported by the implementation.

### 4.2.7 `!(boolean)`
Returns the logical negation of its argument---truthy values become `FALSE`, and falsey values beocme `TRUE`.

### 4.2.8 `LENGTH(string)`
Returns the length of the string, in bytes.

Note that since Knight strings are a strict subset of ASCII, this is both the length of the string in bytes _and_ the length in unicode points.

### 4.2.9 `DUMP(unchanged)`
Dumps a debugging representation of its argument to stdout, without a trailing newline.

Note that this is intended to be used for debugging (and unit testing) purposes, and as such it does not have a strict requirement for what a "debugging representation" means. However, if you wish to use the Knight unit tests, then the output must be in the following format:
- `Null()`
- `Number(<number>)` - `<number>` should be base-10, with a leading `-` if negative.
- `Boolean(<bool>)` - `<bool>` must be either `true` or `false`.
- `String(<string>)` - The literal contents of the string---no escaping whatsoever should be performed. (e.g. `DUMP "foo'b)ar\"` should write `String(foo'b)ar\)`).
- The return value of `BLOCK` doesn't need to dump anything out, as the tests won't check for it.

### 4.2.10 `OUTPUT(string)`
Writes the string to stdout, flushes stdout, and then returns `NULL`.

Normally, a newline should be written after `string` (which should also flush stdout on most systems.) However, if `string` ends with a backslash (`\`), the backslash is **not written to stdout**, and trailing newline is suppressed. 

For example:
```
# normal string
; OUTPUT "foo"
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

### 4.2.11 `ASCII(unchanged)`
If the first argument is a number, interprets it as an ASCII byte and returns a new string. If the first argument is a string, the first byte is converted to its ASCII numerical equivalent.

If the first argument is not a number or a string, the return value of this function is undefined.
If the first argument is a number, but doesn't represent a valid Knight byte (that is, if it's not `9`, `10`, `13`, or `32-126` (inclusive on both sides)), this function's return value is undefined.
note that implementations are free to accept numbers outside of this range, such as UTF-8 codepoints---however, this is not required.
If the first argument is a string, and it is empty, the return value of this function is undefined.

For example:

```
; OUTPUT ASCII 38 # => &
; OUTPUT ASCII 50 # => ;
; OUTPUT ASCII 10 # => <newline>

; OUTPUT ASCII "H" # => 72
; OUTPUT ASCII "HELLO" # => 72
; OUTPUT ASCII "
" # => 10)
```

## 4.3 Binary (Arity 2)
### 4.3.1 `+(unchanged, coerce)`
The return value of this function depends on its first argument's type:
- `Number`: The second argument is coerced to a number, and added to the first.
- `String`: The second argument is coerced to a string, and appended to the first.
- All other types: The return value is undefined.

For example, `+ "2a" 3` will return `"2a3"`, whereas `+ 3 "2a"` will return `5`.

### 4.3.2 `-(unchanged, number)`
If the first argument is a number, the second will be coerced to a number and subtracted from the first.

If the first argument is not a number, the return value of this function is undefined.

For example, `- 3 "2a"` will return `1`.

### 4.3.3 `*(unchanged, coerce)`
The return value of this function depends on its first argument's type:
- `Number`: The second argument is coerced to a number, and multiplied by the first.
- `String`: The second argument is coerced to a number, and then the first is repeated that many times. If the second argument is negative, the return value is undefined.
- All other types: The return value is undefined.

For example, `* "2a" 3` will return `"2a2a2a"`, whereas `* 3 "2a"` will return `6`.

### 4.3.4 `/(unchanged, number)`
If the first argument is a number, the second will be coerced to a number and divided from the first. The result, if it isn't a whole number, should be rounded towards zero.

If the first argument is not a number, the return value of this function is undefined.
If the second argument is zero, the return value is undefined.

For example, `/ 7 3` will return `2`, and `/ 5 "-3"` will return `-1`.

### 4.3.5 `%(unchanged, number)`
If the first argument is a number, the second will be coerced to a number and then the remainder of `<arg1> / <arg2>` is returned. Note that this means that, for all `a`, `a = (a/b)*b + a%b`.

If the first argument is not a number, the return value of this function is undefined.
If the second argument is not a positive number, the return value is undefined.

For example, `% 7 3` will return `1`, and `% (- 0 7) 5` will return `-2`.

### 4.3.6 `^(unchanged, number)`
If the first argument is a number, the second will be coerced to a number and the resulting exponentiation will be returned. Note that for an exponent of `0`, the return value should always be `1` for nonnegative numbers.

If the first argument is not a number, the return value of this function is undefined.
If the first argument is zero and the second argument is negative, the return value of this function is undefined.

### 4.3.7 `<(unchanged, coerce)`
The return value of this function depends on its first argument's type:
- `Number`: Whether or not the first argument is numerically smaller than the second, which is coerced to a number, is returned.
- `String`: Whether or not the first argument is lexicographically smaller than the second, which is coerced to a number, is returned. See below for more details.
- `Boolean`: Whether the first argument is false and the second argument is, when coerced to a boolean, is true is returned.
- All other types: The return value is undefined.

Lexicographical comparisons should find the first non-equivalent character in each string and compare them based on their ASCII value (eg in `abcd` and `abde`, `c` and `d` would be compared), returning `TRUE` if the first argument's character is smaller. If both strings have equivalent characters, then this function shall return `TRUE` only if the first string has a smaller size than the second.

The following is a list of valid string characters, where `[tab]` is smaller than everything (other than another tab), and `~` is larger than everything (other than another `~`).
```text
	[tab] [newline] [carriage return] [space] 
	  ! " # $ % & ' ( ) * + , - . /
	0 1 2 3 4 5 6 7 8 9 : ; < = > ?
	@ A B C D E F G H I J K L M N O
	P Q R S T U V W X Y Z [ \ ] ^ _
	` a b c d e f g h i j k l m n o
	p q r s t u v w x y z { | } ~
```

### 4.3.8 `>(unchanged, coerce)`
This is exactly the same as [4.3.7](#437-unchanged-coerce), except for the operands reversed, ie `> a b` should return the same mas `< b a` (barring the fact that `a` should be evaluated before `b`).

### 4.3.9 `?(unchanged, unchanged)`
Unlike nearly every other function in Knight, this one does not automatically coerce its arguments to any type---Instead, it checks to see if arguments are of the same type _and_ value. For example, `1` is not equivalent to `"1"`, nor is it equivalent to `TRUE`.

This function is valid for the types `Number`, `String`, `Boolean`, and `Null`. Notably, if either argument is a `BLOCK`'s return value, the return value is undefined.

### 4.3.10 `&(unchanged, unevaluated)`
If the first argument, after being coerced to a boolean, is `FALSE`, then the "uncoerced" first argument is returned. Otherwise, the second argument is evaluated and returned.

This function acts similarly to `&&` in most programming languages, where it only evaluates the second variable if the first is truthy.

For example, `& 0 (QUIT 1)` shall return the value `0`, whilst `& TRUE ""` shall return `""`.


### 4.3.11 `|(unchanged, unevaluated)`
If the first argument, after being coerced to a boolean, is `TRUE`, then the "uncoerced" first argument is returned. Otherwise, the second argument is evaluated and returned.

This function acts similarly to `||` in most programming languages, where it only evaluates the second variable if the first is falsey.

For example, `| "2" (QUIT 1)` shall return the value `"2"`, whilst `| FALSE 4` shall return `4`.

### 4.3.12 `;(unchanged, unchanged)`
This function simply returns its second argument. It's entire purpose is to act as a "sequence" function, where the first argument's value can be safely ignored.

### 4.3.13 `=(unevaluated, unchanged)`
Unless the first argument is a [Variable](#3-variable), this function is undefined.

This function assigns the variable identified by the first argument (which shall not be evaluated) to the second argument's value, after which it should return the second argument's value. That is, it performs the "assignment" operation for strings.

### 4.3.14 `WHILE(unevaluated, unevaluated)`
This function will evaluate its second argument as long as its first evaluates to a truthy value. The return value shall be `NULL`.

Note that, unlike most programming languages, Knight does not have a builtin way to "`continue`" or "`break`" from a loop.
(returns null)

## 4.4 Ternary (Arity 3)
### 4.4.1 `IF(boolean, unevaluated, unevaluated)`
This function will evaluate and return the second argument if the first argument is truthy. If the first argument is falsey, the third argument is evaluated and returned.

### 4.4.2 `GET(string, number, number)`
This function is used to get a substring of the first argument. The substring should start at the second argument and be the length of the third. Indexing starts at `0`---that is, `GET "abc" 0 1` should return the `"a"`.

If either the starting point or the length are negative numbers, this function is undefined.
If the starting index is larger than the length of the string, the behaviour is undefined.
If the ending index (ie `start+length`) is larger than the length of the string, the behaviour is undefined.
To put it more concretely, unless the range `[start, start+length)` is entirely contained within the string, this function's return value is undefined. 

For example, `GET "abcd" 1 2` would get the substring `"bc"`, and `GET "abcd" 2 0` would get `""`.

## 4.5 Quaternary (Arity 4)
### 4.5.1 `SUBSTITUTE(string, number, number, string)`
This function is used to substitute the range `[start, start+length)` (where `start` is the second argument and `length` is the third)  of the first argument with the last. Note that they do not have to be the same length---the string should grow or shrink accordingly. Indexing starts at `0`---that is, `SET "abc" 0 1 "2"` should return the `"2bc"`. Also note that this function should return a new string---the original one should not be modified.

If either the starting point or the length are negative numbers, this function is undefined.
If the starting index is larger than the length of the string, the behaviour is undefined.
If the ending index (ie `start+length`) is larger than the length of the string, the behaviour is undefined.

For example, `SET "abcd" 1 2 "3"` would return the string `"a3d"`.

# 5. Command Line Arguments
If at all possible, knight implementations are expected to parse command line arguments.

If no arguments are passed, the program should display a simple usage message (for example, `usage: knight (-e 'expr' | -f filename)`) and exit. Implementations may write this message to either stdout or stderr, and may exit with whatever status code they choose.

If the first argument passed is `-e`, and there are exactly two arguments, the second argument shall be interpreted as Knight code and executed directly.

If the first argument passed is `-f`, and there are exactly two arguments, the second argument shall be a filename. The file should be read, and then executed as Knight code. This option is equivalent to simply passing the entire file's contents to `-e`.

Implementations are free to define additional flags and behaviours outside of these requirements. (For example, printing a usage message when the first argument is not recognized.) However, these are not required: Programs which are not passed exactly one of the three previous options are considered ill-formed.

## Alternatives
Some programming languages (such as AWK) are not able to be invoked with a simple `./knight -e 'OUTPUT "hi"'`. While not ideal, implementations may define alternative ways to pass arguments, such as AWK's `./knight.awk -- -e 'OUTPUT "hi'`.

Some programming languages don't provide a way to access command line arguments at all, such as Knight itself. In this case, the program should read lines from stdin in place of command line arguments.

# 6 Extensions
This section describes possible extensions that Knight implementations could add. Because these are extensions, none of them are required to be compliant. They're simply ways to make Knight more ~~enjoyable~~ bearable to write in. 

### 6.0.1 The `X` Function.
Note that the function `X` is explicitly reserved for extensions: Knight will never use `X` for function names, and implementations are free to use it as they wish. Note that since this is reserved for extensions, they're free to "overload" it. That is, you can have different functions that all start with `X`, eg, `X_OPENFILE`, `X_READFILE`, `X_CLOSEFILE`.

## 6.1 `VALUE(string)`: Look up strings as variables
This function would convert its argument to a string, then look it up as if it were a variable name. That is, it could be a replacement for `EVAL string`, when `string` is just a variable name.

## 6.2 `~(number)`: Unary minus
The `~` function could be used to implement unary minus. That is, `~ expression` would be the same as `- 0 expression`.

## 6.3 Counting Parenthesis
Parenthesis in Knight are whitespace, and are used simply as a way to visually group things. However, as Knight programs are quite hard to debug, you could count parenthesis and ensure that parens match

## 6.4 Handle undefined behaviour
The Knight specs have a lot of undefined behaviour to leave a lot up to implementations. However, this means that writing Knight programs has a lot of potential pitfalls. As such, you may want to catch most forms of undefined behaviour and exit gracefully. (catching _all_ forms is a bit much, eg integer overflow.)

## 6.5 `USE(string)`: Import other knight files
Currently, to import files, you need to use the `` ` `` function: `` EVAL ` + "cat " filename ``. However, this is quite dangerous if `filename` has any shell characters in it. 

## 6.6 Extensibility 
### 6.6.1 Ability to register new, arbitrary native functions
### 6.6.2 Ability to register new, arbitrary native types
(eg arrays, floats)
### 6.6.3 Embedability (ie toggle "dangerous"/io commands.)
