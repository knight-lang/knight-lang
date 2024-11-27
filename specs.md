<!-- markdownlint-disable MD033 -->

# Official Knight Specifications (v2.0.1)

## Table of Contents

* [Overview](#overview)
  * [Undefined behaviour](#undefined-behaviour)
* [Syntax](#syntax)
  * [Required encoding](#required-encoding)
  * [Whitespace](#whitespace)
  * [Comments](#comments)
  * [Integer literals](#integer-literals)
  * [String literals](#string-literals)
  * [Variables](#parsing-variables)
  * [Functions](#parsing-functions)
  * [Parentheses groupings](#parentheses-groupings)
  * [Parsing example](#parsing-example)
* [Types](#types)
  * [Coercion overview](#coercions-overview)
  * [Evaluation of types](#evaluation-of-types)
  * [Integer](#integer)
  * [String](#string)
  * [Boolean](#boolean)
  * [Null](#null)
  * [List](#list)
  * [Block](#block)
* [Variables](#variables)
  * [Variable evaluation](#variable-evaluation)
* [Functions](#functions)
  * [Evaluation contexts](#evaluation-contexts)
  * [Nullary (arity 0)](#nullary-fns)
  * [Unary (arity 1)](#unary-fns)
  * [Binary (arity 2)](#binary-fns)
  * [Ternary (arity 3)](#ternary-fns)
  * [Quaternary (arity 4)](#quaternary-fns)
* [Extensions](#extensions)
  * [Command line arguments](#ext-command-line-arguments)
  * [Handling undefined behaviour](#ext-handling-undefined-behaviour)
  * [Functions](#ext-functions)
  * [Syntactic sugar](#ext-syntactic-sugar)
  * [Additional types](#ext-additional-types)
  * [Changing functionality](#ext-changing-functionality)
  * [Extensibility](#ext-extensibility)

# <a name="overview"></a>Overview

Knight is a simple programming language designed with the primary goal of being
straightforward to implement in a wide range of host languages. To accommodate
the diverse paradigms and capabilities of these languages, the Knight
specification deliberately leaves certain aspects open to interpretation. This
approach allows each implementation to adopt idiomatic solutions suited to its
host language.

## <a name="undefined-behavior"></a>Undefined behaviour

Knight includes the concept of **undefined behavior**, a characteristic often
considered undesirable in programming language design due to its potential to
complicate program development. However, for Knight, the presence of undefined
behavior is a deliberate trade-off. It simplifies the process of creating
compilers and interpreters, which aligns with Knight's primary objective: to be
easily implementable in any language, from Python and Prolog to sed and APL.
Usability, while important, is a secondary concern.

Whenever the specification identifies a scenario as undefined behavior, it
implies that the program in question becomes entirely invalid if such behavior
arises during parsing or execution. Implementations have the freedom to respond
as they see fit—whether by ignoring the issue, terminating with an error,
invoking custom extensions, or encountering runtime errors such as segmentation
faults.

Certain instances of undefined behavior may be straightforward to detect, such
as division by zero, which most languages can identify through built-in
mechanisms. Others, such as detecting when standard output has been closed, may
be impractical or impossible to handle, particularly in minimalist environments
like Brainf*ck. While implementations are encouraged to handle detectable
undefined behavior gracefully, there is no requirement to do so.

In summary, encountering undefined behavior at any stage of a program renders
the program invalid. Implementations are granted full discretion in determining
how to proceed in such cases.

# <a name="syntax"></a>Syntax

Knight is a Polish Notation (PN) programming language, meaning functions and
operators precede their arguments. This contrasts with traditional infix
notation. For example, instead of writing `output(1 + 2 * 4)` as in many
languages, Knight expresses this as `OUTPUT + 1 * 2 4`.

Knight also eliminates the distinction between statements and expressions. Every
function in Knight returns a value, which can be directly used as input for
other functions. This uniformity enables concise constructs that integrate
control flow into expressions. For instance, instead of the conventional C-style
syntax:

```c
if (x < 3) {
 output("hi");
} else {
 output("bye");
}
```

Knight allows this to be written as a single expression, utilizing the return
value of `IF`:

```nim  
OUTPUT IF < x 3 "hi" "bye"
```

Each Knight program consists of exactly one expression. Examples include `OUTPUT
3` or `; (= a 4) (OUTPUT (+ "a=" a))`. Any additional tokens beyond the first
complete expression—aside from [whitespace](#whitespace) and
[comments](#comments)—constitute undefined behavior.

## <a name="required-encoding"></a>Required encoding

To ensure Knight is implementable in a wide range of languages, only a specific
subset of ASCII characters is required to be supported. Implementations may
optionally support additional characters (such as the full ASCII set or
Unicode), but this is not mandatory. The required subset is as follows:

```text
 [tab] [newline] [carriage return] [space] 
   ! " # $ % & ' ( ) * + , - . /
 0 1 2 3 4 5 6 7 8 9 : ; < = > ?
 @ A B C D E F G H I J K L M N O
 P Q R S T U V W X Y Z [ \ ] ^ _
 ` a b c d e f g h i j k l m n o
 p q r s t u v w x y z { | } ~
```

The appearance of any character outside this subset within Knight source
code—including [comments](#comments) or [strings](#string) (such as those
returned by [`PROMPT`](#fn-prompt))—constitutes undefined behavior.
Implementations are free to handle this behavior in any way they choose, but it
is recommended to adhere to this minimum requirement for broad compatibility.

## <a name="whitespace"></a>Whitespace

In Knight, whitespace is not always necessary due to its syntax design. For
instance, `OUTPUT1` should be interpreted as two separate tokens, `OUTPUT` and
`1`. However, whitespace is sometimes required to clearly distinguish tokens,
such as between two identifiers.

Implementations must recognize at least the following characters as whitespace:

* Tab (0x09, represented as `\t`)
* Carriage return (0x0D, represented as `\r`)
* Line feed (0x0A, represented as `\n`)
* Space (0x20, a single space character ``)

### <a name="other-whitespace"></a>Interpreting `(`, `)`, and `:` as whitespace

Although `(`, `)`, and `:` are not defined as whitespace, implementations may
treat them as such by ignoring them in source files. This allowance is based on
their behavior in valid Knight programs:

* Parentheses (`(` and `)`) are functionally inert (see [Parentheses
  groupings](#parentheses-groupings));
* Colon (`:`) is defined as a function ([`NOOP`](#fn-noop)) that simply returns
  its argument and can be omitted without altering program behavior.

This flexibility is optional and left to the discretion of the implementer.

## <a name="comments"></a>Comments

In Knight, comments begin with the pound sign (0x23, i.e., `#`) and extend
until either a newline character (0x0A, i.e., `\n`) or the end of the file.
All text following the `#` is ignored by the parser. Knight does not support
multiline or embedded comments.

Per the [required encoding section](#required-encoding), comments must not
contain illegal characters. Including such characters results in **undefined
behavior**. However, as with other undefined behaviors in Knight, implementations
are free to define how they handle such situations, which may include permitting
non-Knight-encoding characters in comments.

For regex users, Knight's comment syntax can be expressed as:

```regex
/#[^\n]*(\n|$)/
```

## <a name="integer-literals"></a>Integer literals

In Knight, [integer](#integer) literals consist of a sequence of ASCII digits
ranging from 0 (0x30) to 9 (0x39). Leading zeros do not indicate octal numbers;
for example, `011` is interpreted as eleven, not nine. Only base-10 integers are
supported, and no fractional or non-integer numbers are allowed.

> [!NOTE]  
> Unlike most languages, integers in Knight may be followed by any non-digit
> character. For example, `+1a` is parsed as three tokens: `+`, `1`, and `a`.

Knight does not include negative integer literals. Instead, numerical negation
is performed using the [`~`](#fn-negate) function. For example, `~5` represents
the negative value `-5`. Implementations are free to optimize this parsing
behavior and treat `~5` as a single negative integer if desired, as the result
remains the same.

It is undefined behavior for integer literals to exceed the [maximum required
size](#integer-bounds). Implementations may define their own handling of this
scenario.

## <a name="string-literals"></a>String literals

String literals in Knight are enclosed by either single quotes (0x27, i.e., `'`)
or double quotes (0x22, i.e., `"`). All characters within the opening and
closing quotes are interpreted literally, as Knight does not support escape
sequences. For example, to include a newline in a string:

```nim  
OUTPUT "this is a newline:
cool, right?"
```

Since escape sequences are not available, string literals may only include the
type of quote they did not use for enclosure. For instance, single-quoted
strings can contain double quotes, and vice versa. There is no semantic
distinction between single-quoted and double-quoted strings.

Due to the lack of escape sequences, each string may only contain one of the two
types of quotes (as the same quote again denotes the end of a string). There is
no difference between single quoted or double quoted strings (asides from the
fact that double quotes can appear in single-quoted strings and vice versa).

> [!CAUTION]
>
> It is considered **undefined behavior** for a string literal to lack a closing
> quote or for its length to exceed the [maximum integer size](#integer-bounds).

For regex users, string literals can be matched with the following expression:

```regex
/'[^']*'|"[^"]*"/
```

## <a name="parsing-variables"></a>Variables

In Knight, all [variables](#variables) are written in lowercase, as uppercase
letters are reserved for built-in functions. Variable names must begin with an
ASCII lowercase letter (`a`–`z`, 0x61–0x7A) or an underscore (`_`, 0x5F). After the
initial character, variable names may include:

* lowercase letters (a-z);
* underscores (_);
* digits (0-9).

> [!NOTE]  
>
> Since uppercase letters are not part of variable names, they may immediately
> follow them without requiring whitespace. For example, `+aRANDOM` should be
> parsed as three tokens: `+`, `a`, and `RANDOM`.

> [!CAUTION]
>
> Variable names are limited to a maximum length of **127 characters**.
> Exceeding this limit constitutes undefined behavior, although implementations
> may choose to support longer names.

For regex users, valid variable names can be matched with the following expression:

```regex
/[a-z_][a-z_0-9]*/
```

## <a name="parsing-functions"></a>Functions

Knight supports two styles of functions: **word-based** and **symbolic**. The
parsing rules and behavior differ between the two.

### <a name="word-based-fns"></a>Word-based functions

Word-based functions begin with an uppercase ASCII letter (`A`–`Z`, 0x41–0x5A). The
function name consists of the initial uppercase letter, followed by an optional
sequence of uppercase letters and underscores (`_`, 0x5f). However, all variations
of the name map to the same function. For example, the following all represent
the same function as `R`:

* `R`
* `RAND`
* `RANDOM`
* `RAND_INT`
* `R___`
  
The function's arity (number of arguments it requires) is determined by
the specific function, and its name cannot extend beyond the uppercase portion
and underscores.

### <a name="symbolic-fns"></a>Symbolic functions

Symbolic functions are single-character operators such as [`+`](#fn-plus),
[`;`](#fn-then), or [`%`](#fn-remainder). Unlike word-based functions, symbolic
functions:

* Are limited to a single character.
* Do not consume characters following them. For instance, `+++` is parsed as
  `+`, `+`, `+`.

### <a name="fixed-arity"></a>Fixed arity

All functions in Knight have a **fixed arity**, meaning they require an exact
number of arguments. Variadic functions are not supported. After parsing a
function's name, the parser must ensure the correct number of arguments are
provided. For example, after parsing `+`, two expressions must follow, such as
`+ 1 2`

If fewer arguments than required are provided, this is **undefined
behavior**. Implementations are encouraged (though not required) to provide
clear error messages, such as: `line 10: missing argument 2 for '+'` or
`missing an argument for '+'`.

### <a name="required-fns"></a>Required functions

Knight defines the following set of built-in functions by their arity:

| **Arity** | **Functions** |
|:---------:|---------------|
| 0 | [`TRUE`](#fn-true), [`FALSE`](#fn-false), [`NULL`](#fn-null), [`@`](#fn-empty-list), [`PROMPT`](#fn-prompt), [`RANDOM`](#fn-random) |
| 1 | [`:`](#fn-noop), [`BLOCK`](#fn-block), [`CALL`](#fn-call), [`QUIT`](#fn-quit), [`DUMP`](#fn-dump), [`OUTPUT`](#fn-output), [`LENGTH`](#fn-length), [`!`](#fn-not), [`~`](#fn-negate), [`ASCII`](#fn-ascii), [`,`](#fn-box), [`[`](#fn-head), [`]`](#fn-tail) |
| 2 | [`+`](#fn-add), [`-`](#fn-subtract), [`*`](#fn-multiply), [`/`](#fn-divide), [`%`](#fn-remainder), [`^`](#fn-power), [`<`](#fn-less-than), [`>`](#fn-greater-than), [`?`](#fn-equals), [`&`](#fn-and), [`\|`](#fn-or), [`;`](#fn-then), [`=`](#fn-assign), [`WHILE`](#fn-while) |
| 3 | [`IF`](#fn-if), [`GET`](#fn-get) |
| 4 | [`SET`](#fn-set) |

> [!NOTE]  
>
> 1. As `TRUE`/`FALSE`/`NULL`/`@` are nullary functions and simply return a value
>    (true, false, null, and an empty list, respectively), they can be instead
>    interpreted as literals. That is, there's no functional difference between
>    parsing `TRUE` as a function that returns `true` when executed and parsing
>    `TRUE` simply as the true value.
> 2. Custom functions may be added by implementations, as long as their names
>    conform to the rules (uppercase for word-based, symbols for symbolic).
> 3. The `X` function name is reserved for extensions. See the
>    [Extensions](#extensions) section for details.

## <a name="parentheses-groupings"></a>Parentheses groupings

Since Knight is a Polish-notation language with fixed-arity functions,
parentheses are **not required** for parsing valid programs. However, parentheses
can make complex programs easier to read and debug. They serve as an **optional
visual aid** to explicitly group expressions.

The rules for parantheses are as follows:

* Parantheses (`(` and `)`) **must enclose a single expression**;
* Implementations **may ignore parentheses** during parsing. Programs with valid
  parentheses will run correctly even if parentheses are disregarded.
* If parentheses are mismatched or do not enclose a single expression, the
  program is **invalid**.

| Program | Valid? | Notes |
| ------- | :------: | ------ |
| `OUTPUT * a 2` |✅| No parentheses, valid program. |
| `(OUTPUT * a 2)` |✅| Parentheses enclose the expression, valid. |
| `(OUTPUT (* (a) (2)))` |✅| Nested parentheses, valid. |
| `OUTPUT * ((((a)))) 2` |✅| Deeply nested parentheses, valid. |
| `= (a) 4` |✅| Parentheses around the identifier do not affect parsing. |
| `OUTPUT (* a 2` |❌| Mismatched parentheses. |
| `OUTPUT (*) a 2` |❌| Parentheses do not enclose a single expression. |
| `OUTPUT ((*) a 2)` |❌| `(*)` is not a valid single expression. |

## <a name="parsing-example"></a>Parsing example

Below is a walkthrough of how the provided Knight program is parsed into a
syntax tree. The program demonstrates a guessing game where the user compares
their input against a randomly generated secret number.

```nim
# Simple guessing game
; = secret RANDOM
; = guess + 0 PROMPT
  OUTPUT IF (? secret guess) "correct!" "wrong!"
```

```nim
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

# <a name="types"></a>Types

Knight provides six core types: [integers](#integer), [strings](#string),
[booleans](#boolean), [null](#null), [lists](#list), and [blocks](#block). Each
type supports coercion (except blocks) and is immutable, ensuring their values
cannot be altered after creation. Below is a breakdown of the types, their
coercion rules, and specific characteristics.

## <a name="coercions-overview"></a>Coercion overview

Knight types support automatic coercion in specific contexts, which means
arguments passed to functions may be converted to a type required by the
function. These conversions follow these general rules:
<!-- 
Many functions in Knight have contexts defined on them. They will automatically
coerce their arguments from one type to another. For example,
[`OUTPUT`](#fn-output) always coerces its argument into a string.

The following is a rough overview of all the conversions. See each type's
"Coercion" section for more details. Note that the `Block` has no conversions
defined whatsoever, and using it in any conversion context is **undefined
behaviour**. -->

| **From \ To** | **[Integer](#integer)** | **[String](#string)**       | **[Boolean](#boolean)**   | **[List](#list)**                |
|--------------------------|-------------------------|-----------------------------|---------------------------|-----------------------------------|
| **[Integer](#integer)**  | _Itself_               | Base-10 string representation       | `false` if `0`, `true` otherwise | List of digits (negated if negative) |
| **[String](#string)**    | C-style `atoi` conversion        | _Itself_                    | `false` if empty, `true` otherwise | Characters as list               |
| **[Boolean](#boolean)**  | `0` for `false`, `1` for `true` | `"false"` or `"true"`        | _Itself_                  | Empty list for `false`, boxed `TRUE` for `true` |
| **[List](#list)**        | Length of the list     | [Concatenated](#fn-power) by newline characters      | `false` if empty, `true` otherwise | _Itself_                        |
| **[Null](#null)**        | `0`                    | `""` (empty string)         | `false`                   | Empty list                       |

> [!NOTE]
>
> Blocks have no coercion rules defined. Using blocks in coercion contexts
> leads to **undefined behavior**.

## <a name="evaluation-of-types"></a>Evaluation of types

Unlike variables or functions, built-in types evaluate to themselves. For
instance:

* An integer evaluates to its integer value.
* A string evaluates to its literal string value.
* A boolean evaluates to its truth value.

## <a name="integer"></a>Integer

Knight supports only integers. Operations producing non-integral results are
truncated.

### <a name="integer-bounds"></a>Minimum required bounds

All implementations must handle integers within the range $[-2^{31}, 2^{31} -
1]$. Implementations are free to support larger, and smaller integers (for
example, by using a 64-bit integer).

> [!NOTE]
>
> Any mathematical operation causing integer overflow or underflow results in
> **undefined behavior**. Implementations are free to perform optimizations.

### <a name="integer-contexts"></a>Contexts

See [Evaluation contexts](#evaluation-contexts) for general details on contexts.

* **Integer**: Returns the integer itself.
* **String**: Converts to a base-10 string representation. Negative numbers are
  prefixed with `-` (no `+` for positives). Examples:
  * `0` turns into `"0"`;
  * `123` turns into `"123"`;
  * `~12` turns into `"-12"`.
* **Boolean**: 0 is false; all other integers are true.
* **List**: Converts to a list of digits. Negative numbers include negated
  digits. Examples:
  * `123` turns into `"[1, 2, 3]"`;
  * `~123` turns into `"[-1, -2, -3]"`;

## <a name="string"></a>String

Strings in Knight are immutable and primarily support a specific subset of ASCII
([details](#required-encoding)). Implementations may optionally support extended
ASCII or Unicode.

Strings cannot exceed the maximum length defined by integer bounds. For example,
`LENGTH string` will always return a valid integer.

### <a name="string-contexts"></a>Contexts

See [Evaluation contexts](#evaluation-contexts) for general details on contexts.

* **Integer**: To convert a string to an integer, the following is done:
  * Strip leading [whitespace](#whitespace);
  * Optionally parse a `+` or `-` sign;
  * Parse consecutive digits as the integer value, stopping at the first
    non-digit character.
  * Negate if `-` was present. If no digits are found, return 0.

  If the resulting integer is out of bounds, it is **undefined behavior**.

* **String**: Returns the string itself.
* **Boolean**: Non-empty strings are true, empty strings are false.
* **List**:  Converts the string into a list of its characters. Examples:
  * `"abc"` turns into `["a", "b", "c"]`

## <a name="boolean"></a>Boolean

Booleans in Knight have two values: false and true. They are used for truthiness
checks and remain unchanged when evaluated.

### <a name="boolean-contexts"></a>Contexts

See [Evaluation contexts](#evaluation-contexts) for general details on contexts.

* **integer**: `false` becomes `0` and `true` becomes `1`.
* **string**: `false` becomes `"false"` and `true` becomes
  `"true"`.
* **boolean**: Returns itself.
* **list**:  Converts to an empty list for false or a single-element list
  (`,TRUE`) for true.

> [!NOTE]
>
> Because of the conversion rules, `+@TRUE` is equivalent to `,TRUE`, and
> `+@FALSE` is equivalent to `@`.

## <a name="null"></a>Null

The null type represents the absence of a value. Functions like
[`OUTPUT`](#fn-output) and [`WHILE`](#fn-while) return null. While conversions
from null exist, no conversions to null are defined.

### <a name="null-contexts"></a>Contexts

See [Evaluation contexts](#evaluation-contexts) for general details on contexts.

* **integer**: In integer contexts, null becomes `0`.
* **string**: In string contexts, null becomes an **empty string** (notably, not
  `"null"`, as some languages do).
* **boolean**: In boolean contexts, null becomes `false`.
* **list**: In list contexts, null becomes an empty list.

## <a name="list"></a>List

Lists are Knight’s only container type. They are immutable, ordered, and
heterogeneous (can contain mixed types). Operations that modify lists instead
return new lists.

Lists cannot exceed the maximum length defined by integer bounds (see details
[here](#integer-bounds)). For instance, `LENGTH list` always returns a valid
integer.

### <a name="list-contexts"></a>Contexts

See [Evaluation contexts](#evaluation-contexts) for general details on contexts.

* **integer**: Returns the list’s length.
* **string**: Converts the list elements to strings and joins them with
  newlines. It is the same behavior as calling the [`^` operator](#fn-power)
  with a newline as the second argument. Because of this, an empty list becomes
  an empty string, and a list of just one element becomes just that element's
  string value.
* **boolean**: Empty lists are false; non-empty lists are true.
* **list**: Returns the list itself.

### <a name="list-literals"></a>List literals

Due to Knight's fixed-arity syntax, list literals cannot be directly
represented. However, lists can be created in three primary ways:

1. Automatic coercion via `+@`

   Adding an integer or string to the empty list `@` automatically coerces it
   into a list of its elements:

   ```nim
   +@123   # => [1, 2, 3]
   +@"abc" # => ["a", "b", "c"]
   ```

2. Combining boxed elements

   Using the [`+`](#fn-plus) operator with boxed elements (using the
   [`,`](#fn-box) operator), you can construct a list:

   ```nim
   + (+ ,1 ,2) ,3 # => [1, 2, 3]
   + ,TRUE ,FALSE # => [true, false]
   ```

3. Iterative construction

   Lists can be built iteratively using loops and assignment. This example
   illustrates how to add the length of the current list until the list is 100
   elements long (in effect, the resulting list consists of 100 consecutive
   integers):

   ```nim
   ; = list @
   ; WHILE > 100 list
   : = list + list ,LENGTH list
   ```

## <a name="block"></a>Block

Blocks are the most distinct type in Knight. A block is created exclusively
using the [`BLOCK`](#fn-block) function, which captures a piece of code to delay
its execution. Blocks act as a basic mechanism for creating closures or
anonymous functions.

Blocks are executed using the [`CALL`](#fn-call) function, which takes a block
as its sole argument. Unlike traditional functions, blocks do not accept
parameters—all variables used within a block are global.

### <a name="block-contexts"></a>Contexts

Blocks are **not coercible**., and using them in a coercion context causes
**undefined behavior**.

### Valid block usage

Blocks can only be used in specific, well-defined places. Any other usage is
considered undefined behavior. Valid scenarios include:

* The sole argument to:
  * [`:`](#fn-noop)
  * [`BLOCK`](#fn-block) (e.g. `BLOCK BLOCK ...`)
  * [`CALL`](#fn-call), and
  * [`,`](#fn-box);
* The second argument to:
  * [`=`](#fn-assign),
  * [`&`](#fn-and), or
  * [`|`](#fn-or);
* Either argument of [`;`](#fn-then);
* Either the second or third argument of [`IF`](#fn-if).

Some functions, such as [`?`](#fn-equals) and [`DUMP`](#fn-dump), do not
interact with blocks and require no special handling for them.

# <a name="variables"></a>Variables

In Knight, all variables are **global** and persist throughout the duration of
the program. Once assigned a value, a variable remains accessible at any point
in the program until termination. This global scope ensures that the variable is
always available, but also means the programmer must be mindful of potential
unintended side effects from variable reuse. They are not bound to specific
types, and their value can change at any time during the program. For example, a
variable initially holding a string can later be reassigned to hold a block or
any other type.

Variable names must match the regex: `/[a-z_][a-z0-9_]*/`.
This means they:

* Must begin with a lowercase letter (a-z) or underscore (_).
* May contain lowercase letters, digits (0-9), and underscores.

Implementations are required to support variable names between 1 and 127
characters. While longer names may be supported, this is optional.

## <a name="variable-evaluation"></a>Variable evaluation

When a variable is evaluated, it must return the **exact value** previously
assigned to it, without any further evaluation. For example:

```nim
= foo BLOCK (QUIT 1)  
foo          # => Returns the block, does NOT quit the program
```

Multiple variables can reference the same value. For instance:

```nim
= foo 42
= bar foo     
# `bar` now refers to the same value as `foo`

# Another way of writing it:
= bar (= foo 42) 
```

> [!CAUTION]
>
> It is **undefined behaviour** to attempt to evaluate a variable that has not
> been assigned a value yet. This would likely result in an error or unexpected
> behavior during runtime.

## <a name="possible-optimizations"></a>Possible optimizations for variables

Because Knight lacks runtime introspection or dynamic variable lookup. Without
optional extensions like [`EVAL`](#ext-eval) or [`VALUE`](#ext-value), Knight
programs cannot dynamically create or query variable names at runtime.

This absence of introspection enables several potential optimizations:

* **Dead value elimination**: If a variable is proven to be unused at any point
  after its assignment, it can be safely discarded to optimize memory usage;
* **Type specialization**: If a variable is always assigned a specific type
  (e.g., always an integer), this knowledge can be used to optimize code
  execution, reducing the overhead of type checks;
* **Memory management**: Since Knight programs lack dynamic variable creation or
  querying, memory management techniques such as garbage collection can be
  applied to clean up variables that are no longer referenced, improving overall
  memory efficiency.

# <a name="functions"></a>Functions

All functions in Knight have a **fixed arity**, meaning each function expects a
specific number of arguments. Functions cannot accept a variable number of
arguments, and the number of arguments must match the function's expected arity
for the program to run correctly.

## Function evaluation

By default, Knight functions **evaluate their arguments before execution**. This
means that the values of the arguments are calculated first, and the resulting
values are used when performing the function's operation.

```nim
+ a b
```

Here, both `a` and `b` are evaluated to their respective values before being
added together. The function does not work with the raw identifiers `a` and `b`
themselves, but with their evaluated values. This ensures the function operates
on concrete values rather than unprocessed symbols or literals.

## Order of evaluation

Arguments must be evaluated in **strict left-to-right order**. Some functions,
such as [`;`](#fn-then),depend on the order in which their arguments are
evaluated.

## <a name="evaluation-contexts"></a>Evaluation contexts

Certain functions in Knight enforce specific **evaluation contexts** on their
arguments. These contexts may require arguments to be converted (coerced) into a
particular type. The following are the possible contexts for arguments:

* `string`: The argument is evaluated first, then converted to a
  [String](#string).
* `boolean`: The argument is evaluated first, then converted to a
  [Boolean](#boolean).
* `integer`: The argument is evaluated first, then converted to an
  [Integer](#integer).
* `list`: The argument is evaluated first, then converted to a [List](#list).
* `coerced`: The argument is evaluated, and then the coercion occurs within the
  function itself, according to the function's needs.
* `unchanged`: The argument is evaluated, but passed as-is, without any further
  processing or conversion.
* `unevaluated`: The argument is **not** evaluated before being passed to the
  function. This is typically used for blocks or situations where you want to
  delay evaluation.

## <a name="nullary-fns"></a>Nullary (arity 0)

### <a name="fn-true"></a>`TRUE`

#### Description

The function `TRUE` returns the boolean value `true`.

#### Interpretation

It may be interpreted as a nullary function or as a literal value.

#### Usage

```nim
TRUE # Returns true
```

### <a name="fn-false"></a>`FALSE`

#### Description

The function `FALSE` returns the boolean value `false`.

#### Interpretation

It may be interpreted as a nullary function or as a literal value.

#### Usage

```nim
FALSE # Returns true
```

### <a name="fn-null"></a> `NULL`

#### Description

The function `NULL` returns the `null` value.

#### Interpretation

It may be interpreted as a nullary function or as a literal value.

#### Usage

```nim
NULL # Returns true
```

### <a name="fn-empty-list"></a> `@`

#### Description

The function `@` returns the empty list.

#### Interpretation

It may be interpreted as a nullary function or as a literal value.

#### Usage

```nim
@ # Returns the empty list
```

### <a name="fn-prompt"></a> `PROMPT`

#### Description

The `PROMPT` function reads a line of input from standard input (stdin).

#### Behavior

The line is considered complete when either a newline character (\n) or the
end-of-file (EOF) is encountered, whichever comes first. Once the input is
processed, the function performs cleanup and returns the result.

If the line input ends with a `\n`, it is removed. Then, as many trailing `\r`
characters as possible are removed. If EOF is encountered before any characters
are read, the function returns `NULL`.

> [!CAUTION]
>
> If there's a problem reading from stdin (e.g, closed stream, permission issues
etc.), it is considered **undefined behaviour**.
>
> If the input contains characters not supported by Knight (as defined in [required encoding](#required-encoding)), it is considered **undefined behaviour**.

#### Examples

| Input (escaped)     | Output           | Explanation                               |
| ---------------     | ---------        | ----------------------------------------- |
| `hello\n`           | `"hello"`        | Trailing `\n` is removed.                 |
| `hello\r\n`         | `"hello"`        | Both `\r` and `\n` are removed.           |
| `hello\r\r\r\r\r\n` | `"hello"`        | Multiple trailing `\r`s are removed.      |
| `hello\rworld\r\n`  | `"hello\rworld"` | Only the final `\r\n` is removed.         |
| `hello\r\r\r<eof>`  | `"hello"`        | Trailing `\r`s are removed.               |
| `hello<eof>`        | `"hello"`        | Line is returned as is (no `\n` to trim). |
| `<eof>`             | `NULL`           | EOF encountered without input.            |

### <a name="fn-random"></a> `RANDOM`

#### Description

The `RANDOM` function generates a pseudo-random integer.

#### Range

The returned integer must be in the range $[0, 2^{16} - 1]$ (between 0 and
32767). Implementations are free to return a larger random integer if they
desire, however, negative integers aren't permitted.

#### Expected behavior

While it's not strictly verifiable, `RANDOM` should strive to produce different
integers across subsequent calls within the same program execution and between
different runs of the program. Programs relying on `RANDOM` should expect
reasonable pseudo-randomness.

#### Usage

```nim
RANDOM  # Returns a pseudo-random integer between 0 and 32767
```

## <a name="unary-fns"></a> Unary (arity 1)

### <a name="fn-noop"></a> `: unchanged`

#### Description

The `:` function returns its value unchanged, after executing it.

#### Behavior

The value of the argument is returned as-is, without any modification.

#### Interpretation

It may be interpreted as a unary function, or simply as whitespace that can be discarded.

#### Usage

```nim
: foo  # Returns foo unchanged
```

### <a name="fn-block"></a> `BLOCK unevaluated`

#### Description

The `BLOCK` function is a special unary function that does not evaluate its
argument but instead returns it unevaluated. This is used to define code blocks
for later execution.

#### Purpose

The primary use of `BLOCK` is to facilitate user-defined "functions," which can
be executed later using the [`CALL`](#fn-call) function. Since Knight relies on
global variables, there is no mechanism for passing arguments to these
"functions." Any required data must be stored and accessed through global
variables.

#### Example

```nim
; = max BLOCK      
   : IF (< a b) a b
; = a 3            
; = b 4            
: OUTPUT + "Max of a and b is: " (CALL max)
```

In this example, `BLOCK` defines a block of code that returns the maximum of `a`
and `b`. The values of `a` and `b` are assigned globally, and the block can be
called later using [`CALL`](#fn-call). See the [block type](#block) for exact
semantics of how to use `BLOCK`'s return value.

### <a name="fn-call"></a> `CALL <special>`

#### Description

The `CALL` function executes a block of code that was created using the `BLOCK`
function. It "resumes" the execution of the code block at the point where it was
defined.

#### Behavior

The argument to `CALL` must be the return value of a `BLOCK`. Any other type of
argument results in **undefined behavior**.

#### Example

```nim
; = foo BLOCK bar
; = bar 3
; OUTPUT CALL foo # => 3
; = bar 4
: OUTPUT CALL foo # => 4
```

Here, `CALL` is used to execute the block defined by `BLOCK` with the variable
`bar`. As the value of `bar` changes, the result of `CALL foo` reflects the
updated value.

### <a name="fn-quit"></a> `QUIT integer`

#### Purpose

Terminates the Knight program with a specified exit status.

#### Behavior

The integer argument specifies the program's exit code. If the exit code is not
an integer (e.g., a string or block), it must first be coerced into an integer.

The exit code must be in the range [0, 127]. Exiting with codes outside this
range results in **undefined behavior**, although implementations may define
specific behavior for such cases.

#### Examples

```nim
QUIT 12    # => Program exits with status 12
QUIT 0     # => Program exits with status 0 (success)
QUIT "127" # => Program exits with status 127 (after coercion)
QUIT ~1    # => Undefined behavior (negative value)
QUIT 128   # => Undefined behavior (out of range)
```

### <a name="fn-output"></a> `OUTPUT string`

#### Purpose

Writes the argument to the standard output as a string and flushes the output.

#### Behavior

The argument is converted to a string and printed. If the string does not end
with a backslash (`\`), a newline is added after the string. If the string ends
with a backslash (`\`), no newline is added, and the backslash is not output.
After writing, the output is flushed to standard output.

> [!CAUTION]
>
> It is considered **undefined behaviour** if any problems arise when writing to
> or flushing stdout (e.g. it's closed, permission issues, etc.).

#### Examples

Strings (including empty ones) emit newlines:

```nim
; OUTPUT "foo"
; OUTPUT ""
; OUTPUT "bar"
```

```text
foo

bar
```

Strings ending with a backslash don't emit newlines:

```nim
; OUTPUT "foo\"
; OUTPUT "bar"
```

```text
foobar
```

To include newlines in a string, you must explicitly include them:

```nim
; OUTPUT "foo
"
; OUTPUT "bar"
```

```text
foo

bar
```

### <a name="fn-dump"></a> `DUMP unchanged`

#### Purpose

Outputs a debug representation of the argument to standard output without modifying it, then returns the evaluated argument.

This function is also with the unit testing framework uses to ensure that
implementations conform to the Knight specifications.

#### Behavior

* **`integer`**: Its string representation:

  ```nim
  DUMP 3  #=> 3
  DUMP ~3 #=> -3
  ```

* **`boolean`** and **`null`**: Their canonical string representation:

  ```nim
  DUMP TRUE  #=> true
  DUMP FALSE #=> false
  DUMP NULL  #=> null
  ```

* **`string`**: A `"`, followed by the contents of the string, and ended with
  another `"`. The contents of the string should be verbatim, except for the
  following replacements:
  * tab (`0x09`): `\t`
  * newline (`0x0A`): `\n`
  * carriage return (`0x0D`): `\r`
  * backslash (`0x5C`): `\\`
  * double quote (`0x22`): `\"`:

  ```py
  DUMP 'hello'         #=> "hello"
  DUMP 'hel"lo'        #=> "hel\"lo"
  DUMP "hel'lo"        #=> "hel'lo"
  DUMP "<cr>
  <tab>"               #=> "\r\n\t"
  DUMP '\"'            #=> "\\\""
  ```

* **`list`**: Outputs the list with elements inside square brackets. Elements
  are separated by commas:

  ```nim
  DUMP @       #=> []
  DUMP ,3      #=> [3]
  DUMP ,,,3    #=> [[[3]]]
  DUMP ,"[]"   #=> ["[]"]
  DUMP +@123   #=> [1, 2, 3]
  DUMP +@'\\3' #=> ["\\", "\\", "3"]
  ```

For all other types, it is considered **undefined behavior**.

Like [`OUTPUT`](#fn-output), it's **undefined behaviour** if there's any issues
writing to stdout.

### <a name="fn-length"></a> `LENGTH list`

#### Purpose

Returns the length of the argument when it is coerced into a list.

#### Behavior

Strings are treated as lists of characters, so their length is the same as the
number of characters. Other types that are not lists or strings are coerced into
a list for the purpose of determining length. If the argument is NULL, FALSE, or
an empty list, the length is 0.

#### Examples

```nim  
LENGTH TRUE      # => 1
LENGTH FALSE     # => 0
LENGTH NULL      # => 0
LENGTH 1234      # => 4
LENGTH ~1234     # => 4
LENGTH "hello!"  # => 6
LENGTH @         # => 0
LENGTH (*,0 100) # => 100
```

### <a name="fn-not"></a> `! boolean`

#### Purpose

Returns the logical negation of its argument.

#### Behavior

Truthy values (non-zero, non-empty) become `false`, and falsey values (FALSE,
NULL and empty strings) become `true`.

#### Examples

```nim  
!TRUE # => false
!1234 # => false
!""   # => true
!,0   # => true
```

### <a name="fn-negate"></a> `~ integer`

#### Purpose

Converts the argument to an integer, then negates it (performs numeric negation).

#### Behavior

This is numeric negation, similar to the unary `-` in other languages, and _not_
a bitwise negation. The negation of a positive integer makes it negative, and
the negation of zero leaves it unchanged. If the argument is a boolean (TRUE or
FALSE), they are treated as 1 and 0, respectively, before negation.

If the argument exceeds the maximum integer value (2147483647), the behavior is **undefined**.

#### Examples

```nim  
~38         # => -38
~0          # => 0
~(- 1 2)    # => 1
~~5         # => 5
~TRUE       # => -1
~,123       # => -1
~2147483648 #=> undefined (max integer is 2147483647)
```

### <a name="fn-ascii"></a> `ASCII unchanged`

#### Purpose

Converts between ASCII characters and their numerical equivalents, depending on the type of the argument.

#### Behavior

The return value of this function depends on its first argument's type:

* **`Integer`**: Interprets the integer as an ASCII codepoint and returns the
  corresponding character. If the codepoint is not valid (not [in the
  encoding](#required-encoding)), the behavior is **undefined**.
* **`String`**: Converts the first character of the string to its ASCII
  numerical equivalent. An empty string results in **undefined behavior**.
* **Other types**: Undefined behaviour

> [!NOTE]
>
> Implementations may feel free to extend `ASCII` to go beyond ASCII and even
support Unicode. However, this is not required.

#### Examples

```nim  
ASCII 38 # => &
ASCII 50 # => ;
ASCII 10 # => <newline>
ASCII 19 # undefined (19 isn't a valid codepoint)

ASCII "H"     # => 72
ASCII "HELLO" # => 72
ASCII "
" # => 10
ASCII "" # undefined (empty isn't valid)
```

### <a name="fn-box"></a> `, unchanged`

#### Purpose

Purpose: Wraps its argument in a list.

#### Behavior

Converts the argument into a list containing just that element.

#### Examples

```nim  
,1   # => [1]
,,"" # => [[""]]
,,@  # => [[[]]]
```

### <a name="fn-head"></a> `[ unchanged`

#### Purpose

Retrieves the first element or character of the argument.

#### Behavior

The return value of this function depends on its first argument's type:

* **`String`**: Returns a string of just first character. It is **undefined
  behaviour** for the string to be empty.
* **`List`**: Returns the first element of the list. It is **undefined
  behaviour** for the list to be empty.
* **Other types**: Undefined behaviour.

#### Examples

```nim  
["h"      # => "h"
["hello"  # => "h"
[""       # => undefined, empty string

[,1       # => 1
[(+@1234) # => 1
[@        # => undefined, empty list.
```

### <a name="fn-tail"></a> `] unchanged`

#### Purpose

Retrieves everything except the first element or character of the argument.

#### Behavior

The return value of this function depends on its first argument's type:

* **`String`**: Returns the string excluding the first character. Undefined behavior for empty strings.
* **`List`**: Returns the list excluding the first element. Undefined behavior for empty lists.
* **Other types**: Undefined behaviour.

#### Examples

```nim  
]"h"      # => ""
]"hello"  # => "ello"
]"aaaaa"  # => "aaaa"
]""       # => undefined, empty string

],1       # => empty list
](+@1234) # => [2, 3, 4]
](+@1111) # => [1, 1, 1]
]@        # => undefined, empty list.
```

## <a name="binary-fns"></a> Binary (arity 2)

### <a name="fn-add"></a> `+ unchanged coerced`

#### Purpose

This functions add numbers, concatenates strings or concatenates list.

#### Behavior

The return value of this function depends on its first argument's type:

* **`Integer`**: The second argument is coerced to an integer and added to the first.
* **`String`**: The second argument is coerced to a string, and concatenated
  with the first.
* **`List`**: The second argument is coerced to a list, and concatenated with
  the first.
* **Other types**: Undefined behaviour.

#### Examples

```nim  
+ "2a" 3         # => "2a3"
+ 3 "2a"         # => 5
+ @ "abc"        # => ["a", "b", "c"]
+ (+@12) 34      # => [1, 2, 3, 4]
+ (+@12) ,(+@34) # => [1, 2, [3, 4]]
```

### <a name="fn-subtract"></a> `- unchanged coerced`

#### Purpose

Subtracts the second argument from the first, after coercion to integers.

#### Behavior

The second argument is coerced to an integer, and then subtracted from the
first. This function's first argument must be an integer. It is **undefined
behavior** for all other types.  

#### Examples

```nim  
- 3 "2"  #=> 1
- ~1 4   #=> -5
```

### <a name="fn-multiply"></a> `* unchanged coerced`

#### Purpose

Depending on the type of the first argument, this function either multiplies
numbers or repeats strings or lists.

#### Behavior

The behavior depends on its first argument's type:

* **`Integer`**: The second argument is coerced to an integer and multiplied
  with the first.
* **`String`**: The second argument is coerced to an integer, and the string is
  repeated that many times. Undefined behavior if the second argument is
  negative.
* **`List`**:  The second argument is coerced to an integer, and the list is
  repeated that many times. Undefined behavior if the second argument is
  negative.
* **Other types**: Undefined behaviour.

#### Examples

```nim  
* 3 "2"  # => 6
* 3 FALSE # => 0
* "2a" 3  # => "2a2a2a"
* (,1) 5  # => [1, 1, 1, 1, 1]
* (,1) 0  # => empty list
* "2a" ~3 # undefined, negative length
* (,1) ~1 # undefined, negative length
```

### <a name="fn-divide"></a> `/ unchanged coerced`

#### Purpose

Divides the first argument by the second after coercion to integers.

#### Behavior

Non-whole results are rounded towards zero. It is **undefined behavior** when dividing by zero.

If the first argument is an integer, the second argument is coerced to an
integer, and then divided from the first. It is **undefined behavior** for all
other types.

#### Examples

```
/ 7 3    # => 2
/ ~5 2   # => -2
/ 5 "-3" # => -1
/ 1 0    # undefined
```

### <a name="fn-remainder"></a> `% unchanged coerced`

#### Purpose

Returns the remainder of dividing the first argument by the second, after coercion to integers.

#### Behavior

The second argument must be strictly positive. **Undefined behavior** occurs if the first argument is negative or the second argument is zero or non-positive.

If the first argument is an integer, the second argument is coerced to an
integer, and the remainder of the division is returned. It is **undefined
behavior** for all other types.

#### Examples

```nim
% 7 3    # => 1
% 10 5   # => 0
% 5 10   # => 5
% 7 0    # undefined, 0 is not positive
% 7 ~2   # undefined, -2 is not positive
% ~7 2   # undefined, -7 is not positive
```

### <a name="fn-power"></a> `^ unchanged coerced`

#### Purpose

This function either raises the first argument to the power of the second, or joins list elements with a separator, depending on the type of the first argument.

#### Behavior

If the first argument is an **integer**, the second argument is coerced to an
integer, and then the first integer is raised to the power of the second
integer. Exponentiation by zero should return 1. Undefined behavior occurs when
the second argument is negative.

If the first argument is a **list**, the second argument is coerced to a string.
Then, each element of the list is converted to a string and concatenated
together, with the second argument being inserted between adjacent elements.

#### Examples

```nim  
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

### <a name="fn-less-than"></a> `< unchanged coerced`

#### Purpose

Compares the first argument to the second, returning whether the first is "smaller" than the second.

#### Behavior

If the first argument is an **integer**, it coerces the second argument to an integer, then returns whether

If the first argument is a **string**, it coerces the second argument to a
string, and then returns whether the first is lexicographically smaller than the
second. Lexicographical comparisons should find the first non-equivalent
character in each string and compare them based on their ASCII value (e.g. in
`abcd` and `abde`, `c` and `d` would be compared), returning `true` if the first
argument's character is smaller. If both strings have equivalent characters,
then this function should return whether the first string has a smaller size
than the second.

If the first argument is a **boolean**, it coerces the second argument to a
boolean, and returns whether the first is false and the second is true.

If the first argument is a **list**, it  coerces the second argument to a list, and then compares each
element of the two, returning the whether the non-equal comparison is less
than. If each element is equal, return whether the first list is smaller.

For all other types, it is **undefined behavior**.

#### Examples

```nim  
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

### <a name="fn-greater-than"></a> `> unchanged coerced`

#### Purpose

Compares the first argument to the second, returning whether the first is "larger" than the second.

#### Behavior

See details and examples in the [`<`](#fn-less-than) operator. `> a b` is equivalent to `< b a`.

### <a name="fn-equals"></a> `? unchanged unchanged`

#### Purpose

This function checks if two arguments are exactly the same, both in type and value.

#### Behavior

It does not coerce types, so 1 is not equal to "1", and TRUE is not equal to FALSE.

It is **undefined behavior** if either argument is a [`block`](#block).

#### Examples

```nim  
? 1 2        # => false
? ~0 0       # => true
? "1" "1 "   # => false
? FALSE NULl # => false
? NULL NULL  # => true
? ,@ ,,@     # => false
```

### <a name="fn-and"></a> `& unchanged unevaluated`

#### Purpose

This function evaluates the first argument, and returns the conjunction between them.

#### Behavior

If the first argument is falsey (0, FALSE, or NULL), it returns that value. If
the first argument is truthy, the second argument is evaluated and returned.

Unlike most functions, blocks can be passed as the second argument.

#### Examples

```nim  
& 0 (QUIT 1)   # => 0
& "hi" "there" # => "there"
& TRUE ""      # => ""
& @ 4          # => @
```

### <a name="fn-or"></a> `| unchanged unevaluated`

#### Purpose

This function evaluates the first argument, and returns the disjunction between them.

#### Behavior

If the first argument is truthy (not 0, FALSE, or NULL), it returns that value. If
the first argument is falsey, the second argument is evaluated and returned.

Unlike most functions, blocks can be passed as the second argument.

#### Examples

```nim  
| 2 (QUIT 1)   # => 2
| "hi" "there" # => "hi"
| TRUE ""      # => TRUE
| @ 4          # => 4
```

### <a name="fn-then"></a> `; unchanged unchanged`

#### Purpose

This function allows for sequencing of operations.

#### Behavior

The first argument is evaluated and discarded, and the second argument is
returned. It acts as a way to execute one expression and then execute another,
ignoring the result of the first expression.

Unlike most functions, blocks can be passed as either argument to `;`.

> [!NOTE]
>
> Using `:` as the last function in a chain of `;`s can look visually appealing.

#### Examples

```nim  
; = x 3 OUTPUT x    # 3
OUTPUT ; = x 3 x    # 3
```

```nim
; = i 10
; = prod 1
; WHILE i
  ; = prod (* prod i)
  : = i (- i 1)
: OUTPUT prod        
#=> 3628800
```

### <a name="fn-assign"></a> `= <special> unchanged`

#### Purpose

This function is used for variable assignment.

#### Behavior

It evaluates the second argument and assigns the result to the variable in the
first argument. The result of the assignment is then returned.

> [!NOTE]
>
> If the first argument is not a [variable](#variables), it is considered
> **undefined behaviour**. However, see the optional [assign to
> strings](#ext-assign-to-strings) extension.

This function evaluates the second argument, and then both assigns it to the
variable in the first argument and returns it. This is the only way to update
variables within Knight.

Blocks can also be passed as the second argument to `=`, allowing for
assignments with evaluated expressions.

#### Examples

```nim  
= a 3       # => 3 (a is 3)
* (= a 4) a # => 16 (a is 4)
= a = b 3   # => 3 (a and b are both 3; assignments can be chained)
= "a" 4     # undefined, `"a"` isn't a variable
```

### <a name="fn-while"></a> `WHILE unevaluated unevaluated`

#### Purpose

This function creates a loop.

#### Behavior

The loop continues evaluating the second argument as long as the first argument
evaluates to a truthy value. Once the condition becomes falsey, the loop
terminates, and null is returned. Knight does not have built-in mechanisms like
break or continue—the loop only stops when the condition becomes false. However,
the [control flow](#ext-control-flow) is an optional extension relevant to this.

#### Examples

```nim  
; = i 10
; = prod 1
; WHILE i
  ; = prod (* prod i)
  : = i (- i 1)
: OUTPUT prod 
#=> prints out 3628800
```

```nim
# Look through a string for the first digit

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

## <a name="ternary-fns"></a> Ternary (arity 3)

### <a name="fn-if"></a> `IF boolean unevaluated unevaluated`

#### Purpose

This function allows for conditional execution.

#### Behavior

If the first argument is truthy, this function will evaluate and return the
second argument. However, if it's falsey, it will evaluate and return the third
argument.

Blocks can be passed as either the second or third argument to `IF`.

#### Examples

```nim  
IF @ "nonempty" "empty"    # => "empty"
IF 1 2 3                   # => 2
IF FALSE QUIT 1 "!"        # => "!"; it won't quit.
IF "0" TRUE QUIT 1         # => true
```

### <a name="fn-get"></a> `GET unchanged integer integer`

#### Purpose

This function extracts a substring from a string or a sublist from a list.

### Behavior

The first argument is the data to extract from (either a string or list), the
second is the starting index, and the third is the length of the substring or
sublist.

If the first argument is a **string**, then the function returns a substring
starting at the second argument with a length of the third argument. Indexing
starts at `0`. It is **undefined behaviour** for either the second or third
arguments to be negative, or their sum to be larger than the length of the
string.

If the first argument is a **list**, it returns a sublist starting at the second
argument with a length of the third argument. Indexing starts at `0`. It is
**undefined behaviour** for either the second or third arguments to be
negative, or their sum to be larger than the length of the list.

For all other types, it is **undefined behavior**.

#### Examples

```nim  
GET "" 0 0       # => ""
GET "abcde" 2 2  # => "cd"
GET "abcde" 2 0  # => ""
GET "abcde" 5 1  # => undefined, `5+1 > length("abcde")`
GET "abcde" 5 0  # => "" (`5 <= length("abcde")`)
GET "abcde" 4 1  # => "e"
GET "abcde" ~1 1 # => undefined, negative start
GET "abcde" 1 ~1 # => undefined, negative length
```

```nim
GET @ 0 0          # => empty list
GET (+@12345) 2 2  # => list of 3 then 4
GET (+@12345) 2 0  # => empty list
GET (+@12345) 5 1  # => undefined, `5+1 > length(+@12345)`
GET (+@12345) 5 0  # => empty list (`5 <= length(+@12345)`)
GET (+@12345) 4 1  # => list of just 5
GET (+@12345) ~1 1 # => undefined, negative start
GET (+@12345) 1 ~1 # => undefined, negative length
```

## <a name="quaternary-fns"></a> Quaternary (arity 4)

### <a name="fn-set"></a> `SET unchanged integer integer coerced`

#### Purpose

The function allows you to modify an existing string or list by replacing a
specified range (substring or sublist) with a new value.

#### Behavior

The function takes four arguments: the data to modify (either a string or list),
the start index, the length of the range to replace, and the value to insert,
which is coerced into the appropriate type (either a string or a list).

For **strings**, it returns a new string where the substring of the first
argument, starting at the second argument with length of the third argument, is
replaced by the fourth argument coerced to a string.

For **lists**, it returns a new list where the sublist of the first argument,
starting at the second argument with length of the third argument, is replaced
by the fourth argument coerced to a list.

It is **undefined behaviour** for either the second or third arguments to be
negative, or their sum to be larger than the length of the string/list or for
the first argument to not be a string/list.

#### Examples

```nim
SET "" 0 0 "Hello"  # => "Hello"
SET "abcd" 2 1 "!"  # => "ab!d" (replaces)
SET "abcd" 2 0 "!"  # => "ab!cd" (inserts before index `2`)
SET "abcd" 1 2 TRUE # => "atrued" (replaces range)
SET "abcd" 0 2 @    # => "cd" (deletes range; @ to string is empty)
```

```nim
SET @ 0 0 "Hello"        # => list of "H", "e", "l", "l", and "o"
SET (+@1234) 2 1 ,9      # => list of 1, 2, 9, and 4 (replaces)
SET (+@1234) 2 0 "!"     # => list of 1, 2, "!", 3, and 4 (inserts before index `2`)
SET (+@1234) 1 2 (+@789) # => list of 1, 7, 8, 9, and 4 (replaces range)
SET (+@1234) 0 2 @       # => list of 3 and 4 (deletes range; "" to list is empty)
```

# <a name="extensions"></a>Extensions

This section explores optional extensions that Knight implementations could
include to enhance the usability or flexibility of the language. These
extensions are not part of the core Knight specification and are not required to
be implemented, but they can make the language more user-friendly in specific
environments or provide additional features.

## <a name="ext-command-line-arguments"></a> Command line arguments

While Knight doesn’t require command-line argument support, implementing a
standardized set of command-line options can enhance the language's utility.
This extension allows Knight programs to be invoked with different command-line
arguments for more dynamic execution.

There is a standardized set of command-line options that most Knight
implementations follow:

* `-e 'expr'`: Interprets the second argument as a Knight program expression and
  executes it directly. This allows for quick evaluation of expressions directly
  from the command line.
* `-f <path>`: Interprets the second argument as a file path, reads the contents
  of the file, and executes the Knight program in the file. This is useful for
  running pre-written Knight scripts.
* If no arguments are passed, the program prints out a usage message with
  instructions on how to run the Knight program using `-e` or `-f`.

The Knight unit tester expects `-e 'expr'` to be defined, and you won't be able
to use it without this.

Example usage:

```sh
./knight -e 'OUTPUT "hello"'    # Prints: hello
./knight -f /path/to/script.kn  # Executes the script in the file
```

> [!NOTE]
>
> If command-line arguments are not supported by the implementation language
> (e.g., if Knight is written in a language without access to command-line
> arguments), you can implement a workaround by reading arguments from stdin.
> For example:
>
> ```shell
> #/bin/sh
> cat <(echo "$*") /dev/stdin | ./knight
> ```
>
> Some programming languages (such as AWK) are not able to be invoked with a
> simple `./knight -e 'OUTPUT "hi"'`, and require extra flags (eg AWK's
> `./knight.awk -- -e 'OUTPUT "hi'`). If desired, you could simply make a wrapper
> shell file that executes your program, such as
>
> ```shell
> #/bin/sh
> ./knight.awk -- "$@"
> ```

## <a name="ext-handling-undefined-behaviour"></a> Handling undefined behaviour

The Knight language has some undefined behavior (UB) areas where the program’s execution can become unpredictable, which might lead to errors or crashes. Implementing a mechanism to handle or detect some common forms of undefined behavior could improve the stability and usability of Knight implementations.

Some forms of UB (like division by zero) are easier to detect and handle. Other
forms, such as handling string length overflows or ensuring index bounds, may
require more complex checks but can help improve robustness. Knight
implementations could implement optional UB checks to avoid crashes or
misbehavior in programs. For example, if division by zero is detected, the
program could print an error message or gracefully exit.

Not every type of UB needs to be handled by the implementation. It may be
reasonable to handle some errors (e.g., division by zero) while leaving others
(e.g., string length overflows) for the user to debug. Checking for undefined
behavior may introduce overhead, so implementations could provide configuration
options to enable or disable these checks, especially during runtime
optimization.

## <a name="ext-functions"></a> Functions

In this section, several optional extensions to Knight's function system are
outlined. These extensions allow for added flexibility and new functionalities,
which can be implemented by Knight implementations to enhance the language's
capabilities. Below are the key extensions described.

### <a name="ext-x-function"></a> The `X` Function

The `X` function is explicitly reserved for Knight implementations. It is a
placeholder for any additional function that an implementation may define. This
function is not part of the official Knight specification, meaning it is left
entirely up to the implementation to decide its behavior.

Implementations may choose to have different functions starting with `X`, e.g.,
`X_OPENFILE`, `X_READFILE`, `X_CLOSEFILE`.

### <a name="ext-value"></a> `VALUE string`: Dynamically look up variables

The `VALUE` function allows for dynamically looking up variables based on their
name. It takes a string as its argument, interprets it as the name of a
variable, and then retrieves the value of that variable.

```nim  
; = ab 3
: OUTPUT VALUE + "a" "b"    # 3
```

### <a name="ext-assign-to-strings"></a> Assign to strings within `=`

In base Knight, the `=` operator is used for assignment to variables, but this
extension allows implementations to extend the behavior of `=` to handle string
assignments.

If the first argument to `=` evaluates to a string, it can be treated as a
variable name, and the assignment can occur to that variable.

More advanced features, such as destructuring assignments for lists, are also
possible. In this case, the first argument can be a list, and the second
argument is converted into a list to assign values sequentially.

#### Examples

```nim  
; = (+ "a" "b") 3
: OUTPUT ab  # prints out 3
```

Here, "a" "b" is interpreted as a variable ab, which is then assigned the value 3.

```
; = (+@"ab") (+@12)
: OUTPUT a  # prints out 1
: OUTPUT b  # prints out 2
```

In this example, the list `(+@"ab")` is destructured, and the values from `(+@12)` are assigned sequentially to the variables a and b.

### <a name="ext-handle"></a> `HANDLE unevaluated unevaluated`: Try-catch

The HANDLE function introduces a way to implement try-catch behavior in Knight. This function attempts to evaluate its first argument and return its result. If any error or undefined behavior occurs during the evaluation, it catches the error and evaluates the second argument instead, returning its result.

```nim  
HANDLE (+1 2) 9 # => 3, because no errors occurred
HANDLE (/1 0) 9 # => 9, because division by zero occurred
```

You can also add the optional feature of setting an error message using the `_` variable, which stores the error message:

```nim
OUTPUT HANDLE (/ 1 0) _ 
# => prints out the division by zero error message
```

### <a name="ext-yeet"></a> `YEET string`: Throw an exception

The YEET function allows Knight programs to throw exceptions (i.e., crash with
an error message). This function can be used instead of the traditional method
of using OUTPUT followed by QUIT, and it provides a more flexible way to handle
errors in implementations that support exceptions.

When YEET is invoked, it will cause the program to crash with the specified
error message. If the implementation supports exceptions, this can be integrated
with the HANDLE function to create a more comprehensive error handling system.

```nim  
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

In this example, if the number is not even, YEET is called to throw an error
with the message "not even". The HANDLE function ensures that the program
doesn't crash outright but instead provides a fallback message.

### <a name="ext-use"></a> `USE string`: Import other Knight files

Currently, Knight does not provide a way to import other files, meaning every Knight program is a single monolithic file. The USE extension allows Knight implementations to import external files, making it easier to manage larger programs.

A few ideas:

* Imports files are relative to the file that invokes USE.
* The `.kn` file extension can be omitted, and Knight will infer it.
* Duplicate imports are avoided.
* Only accept static strings at the top of a file.

```nim
# /code/knight/greet.kn
: = greet BLOCK
 : OUTPUT ++ greeting ", " place
```

```nim
# /code/knight/main.kn
; USE "/code/knight/greeting.kn" # if no relative files
; USE "greeting.kn"              # if relative files
; USE "greeting"                 # if omit extension
# (Only import the file once if skipping duplicates)

; = greeting "Hello"
; = place "world"
: CALL greet
```

### <a name="ext-system"></a> `$ string unchanged`: Run a shell command and return its stdout

This extension allows Knight to interact with the system shell by running shell
commands and capturing their output. The function takes a string representing a
shell command, executes it, and returns the standard output as a string.

The first argument is a string representing the shell command to execute. The
second argument is an optional stdin to pass to the shell command (if NULL, the
parent process's stdin is inherited). If the command exits with a nonzero
status, the exit status is returned. A variable called stderr can be set to
capture the error output from the shell command.

```nim
; = result $ "ls -l"  # Runs 'ls -l' in the shell and returns the output
: OUTPUT result       # Prints the stdout of the 'ls' command
```

### <a name="ext-eval"></a> `EVAL string`: Evaluate a string as Knight code

The EVAL function allows Knight programs to evaluate a string as Knight code.
This function takes a string, interprets it as Knight code, and executes it.
This allows for dynamic evaluation of Knight code within a program. Key It
converts the argument to a string and evaluates it as if the string were the
Knight code itself. The string must contain valid Knight code; otherwise, it
results in undefined behavior.

```nim
; = a 3
; = bar "* a 4"
: OUTPUT + "a*4=" (EVAL bar)
```

is equivalent to

```nim
; = a 3
; = bar "* a 4"
: OUTPUT + "a*4=" (* a 4)
```

## <a name="ext-syntactic-sugar"></a> Syntactic sugar

This section introduces various extensions that add syntactic sugar and
additional types to Knight, providing simpler syntax for common idioms and more
powerful data types for advanced use cases.

### <a name="ext-string-interpolation"></a> `` ` ``-string literals

Knight does not natively support string interpolation, and working with strings
requires concatenation. However, implementations could introduce a new syntax
for string literals using the ` symbol to support both escape sequences and
string interpolation, making string handling much more convenient.

```nim  
OUTPUT `{greeting}, {name}, aged {age}!\nHow are you?`
```

### <a name="ext-list-literal"></a> `{ ... }`: List literals

Knight lacks native list literals, requiring lists to be constructed manually
using the `,` operator. The `{ ... }` syntax could be used to define list
literals, offering a more intuitive way to create lists.

```nim
? ,1      {1}     # => true
? +@123   {1 2 3} # => true
? +,1,"a" {1 "a"} # => true
```

Here, {1} creates a list with the single element 1, {1 2 3} creates a list with three elements, and {1 "a"} creates a list with the integer 1 and the string "a".

## <a name="ext-additional-types"></a> Additional types

These extensions are additional types implementations could define.

### <a name="ext-floats"></a> Floats

Knight's only native number type is integers. However, implementations could
introduce a floating-point type by using the `.` symbol for float literals, such
as 1.0. This extension would allow for more precise numeric calculations.

Knight's only native number type is the [integer](#integer). Additionally,
Knight does not use the `.` symbol at all. Implementations could introduce a
float data type, using the `.` for float literals (eg `1.0`).

> [!NOTE] Implementation notes
>
> They could follow similar conversion rules as integers (such as adding
> something to a float converts the second argument to a float). One thing to be
> careful about is to not have `^` or `/` return floats if the first argument is
> an integer, as that'd make the program no longer spec compliant. Instead, you
> could overload `^` and `/` so that if the first argument is a float, the
> return value is a float.

```nim
OUTPUT 1.2           # prints 1.2
OUTPUT +0.1 123      # prints 123.1
OUTPUT / (+0.0 10) 4 # prints 2.5
```

Special constants like XNAN and XINF could be used to represent "Not a Number"
(NaN) and infinity (INF), respectively.

```nim
OUTPUT XINF          # prints "Infinity"
OUTPUT XNAN          # prints "NaN"
```

### <a name="ext-map"></a> Maps

Knight doesn't have built-in support for maps, but this could be added using a
custom data type. Implementations could define a map type with the `{ key :
value }` syntax to allow for easy key-value pairs.

```nim
{}                 # => empty map
{1 : 2}            # => a map of just 1 to 2
{"hello" : "world" # => a map of "hello" to "world" and
 123 : 456}        #    123 to 456.
```

This allows the creation of maps (associative arrays or dictionaries), which can hold key-value pairs for efficient lookups.

### <a name="ext-objects"></a> Objects

Knight implementations could define an object type that allows for
object-oriented features. Objects could support methods, static methods,
inheritance, and even multiple inheritance.

A possible syntax could be:

```nim
: = MyObject BLOCK{field1 field2}
  : field1 10
  : field2 "Hello"

: = instance MyObject
: CALL instance:method()  # calling a method on the object
```

## <a name="ext-changing-functionality"></a> Changing functionality

These extensions modify the behavior of the base Knight implementation,
providing more advanced features such as local variables, methods, and enhanced
control flow.

### <a name="ext-local-variables"></a> Local variables

In vanilla Knight, all variables are global, meaning any modification to a
variable in one block affects all other blocks. Implementations could introduce
local variables, allowing for variables that are scoped within a particular
block or function.

This feature would support more complex programming patterns, such as recursion
and encapsulation.

### <a name="ext-methods"></a> Methods

Currently, Knight's blocks operate solely on global variables, which can make it
difficult to write recursive functions or pass arguments effectively. By adding
a method type, Knight could allow for better handling of local variables within
methods, reducing the risk of accidental variable overwriting.

```nim
; = greet BLOCK{greeting where}
  : ++ greeting ", " where

: OUTPUT CALL greet{"Hello" "world"}
```

### <a name="ext-control-flow"></a>Control flow

Knight lacks advanced control flow features like breaking out of loops or
returning early from functions. Implementations could add control flow
extensions such as:

* **XBREAK**: Break out of the innermost loop.
* **XCONTINUE**: Continue to the next iteration of the innermost loop.
* **XRETURN**: Return from a function or block.
* **XGOTO**/**XLABEL**: Jump to a specific label within the code (similar to
   goto in other languages).
* **XFOR**/**XFOREACH**: Create more expressive for or foreach loops.

## <a name="ext-extensibility"></a> Extensibility

These extensions are more aimed towards implementations that intend to be
libraries.

### <a name="ext-embedability"></a> Embedability

To facilitate embedding Knight into other systems or libraries, the behavior of
commands like OUTPUT, DUMP, PROMPT, and QUIT could be customized. Instead of
defaulting to standard output or terminating the program, these commands could
be routed to a string or captured for later use, allowing Knight to be more
easily embedded in other environments.

### <a name="ext-native-functions"></a> Register arbitrary native functions

Implementations could provide support for registering custom native functions,
allowing Knight to be extended with functions written in other languages (e.g.,
C, Python). This allows developers to create specialized functions that can be
invoked directly from Knight code.

> [!NOTE] Considerations for implementors
>
> * Do you only want to allow `X` functions (which would probably be the
>   simplest, parsing-wise), or also "normal" functions?
> * Are extension functions restricted to only undefined symbols, or can they
>   override native functions too?

### <a name="ext-native-types"></a> Register arbitrary native types

Similarly, native types could be registered to extend Knight with new data
types. This would allow Knight to handle complex data structures that are not
part of the core language, such as custom objects, arrays, or other advanced
types.
