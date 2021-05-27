# Knight
An extremely simple programming language that I've designed to be easy to implement in a variety of languages. It's not actually meant to be used, though it is a fully-functional language.

Unofficial Tag-line: "Knight: Runs everywhere. Not because it's cross-platform, but because it has a implementation in virtually all major languages."

Checkout the [community](COMMUNITY.md), and join us on discord: https://discord.gg/SE3TjsewDk.

# Implementations
The following is the list of all languages that I've written it in. All in-progress implementations are in separate branches.

| Language | 100% Spec Conformance | Documented | Mostly Functional | Begun | Notes |
| -------- |:---------------------:|:----------:|:-----------------:|:-----:| ----- |
| [AWK](https://github.com/knight-lang/shell/knight.awk) | X | X | X | X | My AWK interpreter segfaults randomly, but after running each test 100x, they all passed. |
| [Assembly (x86)](https://github.com/knight-lang/asm) |   |   |   | X | The parser is completed.|
| [C](https://github.com/knight-lang/c) | X | X | X | X | Fully functional, and the fastest. |
| [C++](https://github.com/knight-lang/cpp) | X | X | X | X | Works with C++17; It could use a facelift though, as I used a bit too much dynamic dispatch. |
| [C#](https://github.com/knight-lang/csharp) | X | X | X | X | Simple version without any documentation. It can be cleaned up slightly though. |
| [Go](https://github.com/knight-lang/go) | X |  | X | X | Fully functional, but undocumented. |
| [Haskell](https://github.com/knight-lang/haskell) |   |  | ish | X | Works for an older spec of Knight, needs to be updated. |
| [Java](https://github.com/knight-lang/java) | X |   | X | X | Simple version without any documentation. It can be cleaned up slightly though. |
| [JavaScript](https://github.com/knight-lang/knight.js) | X | X | X | X | Fully Functional, although it requires Node.js for the OS-related functions. |
| [Knight](https://github.com/knight-lang/knight/knight.kn) |   |   | X | X | Yes, this is a Knight interpreter, written in Knight; It's yet to be tested for spec compliance, though. |
| [Kotlin](https://github.com/knight-lang/kotlin) | X | X | X | X | Fully funcitonal, and barring `` ` ``, can be compiled to native. |
| [Perl](https://github.com/knight-lang/perl) | X | X | X | X | Fully Functional on at least v5.18. |
| [PHP](https://github.com/knight-lang/php) | X | X | X | X | Fully Functional, with type annotations. |
| [POSIX-Compliant SH](https://github.com/knight-lang/shell/knight.sh) |   |   | X | X | Mostly works, but has some bug fixes that need to be done. It could definitely use some TL&C, though. |
| [Prolog](https://github.com/knight-lang/prolog) |   |   |   | X | The very beginnings of a Prolog implementation. |
| [Python](https://github.com/knight-lang/python) | X | X | X | X | Fully Functional, though `setrecursionlimit` is needed to ensure "FizzBuzz in Knight in Python" works. |
| [Quest](https://github.com/knight-lang/quest) |   |    |   | X | An implementation in [my other programming language](https://github.com/sampersand/quest). |
| [Raku](https://github.com/knight-lang/raku) | X | X | X | X | Fully Functional, but quite slow. But hey, it was fun to write in. |
| [Ruby](https://github.com/knight-lang/ruby) | X |   | X | X | A hacky version currently exists; a more sophisticated one is being worked on. |
| [Rust](https://github.com/knight-lang/rust) | X |   | X | X | Simple implementation without comments. It intentionally captures all UB, but eventually will have an efficient implementation. |
| SML |   |   |   |   | Planned. I used this in college, and enjoyed it. |
| Racket |   |   |   |   | Planned. I used this in college, and enjoyed it. |
| LaTeX |   |   |   |   | Eventually; Because why not? I did a lot of LaTeX in college. |
| Scratch |   |   |   |   | My first language! Might be fun to implement it in this |

## Time Comparisons
The following able describes how fast each implementation (in `user` time) was at running `examples/fizzbuzz.kn` in `knight.kn` in `knight.kn` in their implementation, on my machine. You can test it yourself via the [timeit](timeit) script provided.

Note that these are simply benchmarks of _my_ implementations of Knight, and not a reflection of the efficiency of the languages themselves.

|  Language  |  Time   | `<implementation>` | Notes |
| ---------- |--------:|--------------------|-------|
| C          |   3.31s | `c/ast/knight`     | Compiled using `COMPUTED_GOTOS=1 CFLAGS='-DKN_RECKLESS -DKN_USE_EXTENSIONS' make optimized`; See [https://github.com/knight-lang/c/ast/README.md](c/ast/README.md) for details. |
| Kotlin     |   5.84s | `kotlin/knight` |  |
| Java       |   6.99s | `java/knight` | Requires a larger stack to prevent overflow; `java -Xss515m` was used. |
| Rust       |  10.06s | `rust/target/release/knight` | Built with `cargo build --release --no-default-features --features=unsafe-optimized`. Still being improved. 
| C#         |  11.82s | `csharp/bin/Release/netcoreapp2.1/<impl>/Knight` | |
| C++        |  13.61s | `cpp/knight`       | Compiled using `make optimized` |
| Go         |  14.17s | `go/knight/knight` | |
| JavaScript |  30.64s | `node --stack-size=1000000 javasript/bin/knight.js` | Default stack's too small, so we had to bump it up. |
| PHP        |  64.73s | `php/knight.php`   | |
| Ruby       | 110.04s | `ruby/knight.rb`   | Default stack's too small, so `RUBY_THREAD_VM_STACK_SIZE=10000000` was needed. |
| Python     | 236.01s | `python/main.py`   | Default stack's too small, so `setrecursionlimit(100000)` was needed. |
| Perl       | 436.55s | `perl/bin/knight.pl` | |



# Examples
Here's some examples of the syntax to give you a feel for it:

## Guessing Game
```
; = max 100                                   # max = 100
; = secret (RAND 1 max)                       # secret = rand(1, max)
; = nguess 0                                  # nguess = 0
; = guess 0                                   # guess = 0
; OUTPUT (+ 'guess 1-' max)                   # print('pick from 1-' + m)
; WHILE (| (< guess secret) (> guess secret)) # while guess != s:
  ; = guess (+ 0 (PROMPT '> '))               #   guess = int(prompt('> '))
  ; = nguess (+ nguess 1)                     #   nguess += 1
  : OUTPUT (                                  #   print(
     IF (< guess secret) 'too low'            #     if guess < secret: 'too low'
     IF (> guess secret) 'too high'           #     if guess > secret: 'too high'
                         'correct')           #     else: 'correct')
: OUTPUT (+ 'tries: ' nguess)                 # print('tries: ' + n)
```

## Fibonacci
```
; = fib BLOCK                           # function fib:
    ; = a 0                             #    a = 0
    ; = b 1                             #    b = 1
    ; WHILE n                           #    while n != 0:
        ; = b + a = tmp b               #       b = a + (tmp = b)
        ; = a tmp                       #       a = tmp
        : = n - n 1                     #       n -= 1
    : a                                 #    return a
; = n 10                                # n = 10
: OUTPUT +++ 'fib(' n ')=' CALL fib     # print "fib(" + n + ")=" + fib()
# => fib(10)=55
```

# Specs
For exact details please see [specs.md](specs.md). The following is just a rough overview, and is probably out of date.
## Syntax
Every Knight program is a single expression. (The `;` function can be used to write more than one expression, sequentially.) Because of this, parsing is extremely simple: Parse a token, then parse as many arguments as that expression dictates.

Non-symbol functions are defined by their first character: additional uppercase characters following it are ignored. Because of this, `OUTPUT` is the same as `OUT`, which is the same as `OFOOBARBAZ`.

All whitespace (including `(`, `)`, `[`, `],` `{,` `}`, and `:`) outside of strings is completely ignored except in four cases:
1. Between two "word" keywords, such as `IF PROMPT`
2. Between two numbers, such as `+ 1 2`
3. Between two identifiers, such as `* a b`
4. Between an identifier and a number, such as `+ a 3`.

As such, expressions such as `OUTPUT * a (IF b 3 b)` can be written as `O*aIb 3b`.
```ebnf
expr
 := nullary
  | unary expr
  | binary expr expr
  | ternary expr expr expr
  | quaternary expr expr expr expr

nullary 
 := [0-9]+
  | `'` [^']* `'` | `"` [^"]* `"`
  | [a-z_][a-z_0-9]*
  | ('T' | 'F' | 'N' | 'P' | 'R') {UPPER}
  ;

unary
 := ('B' | 'C' | 'O' | 'Q' | 'L') {UPPER}
  | '`'
  | '!'
  ;

binary
 := 'W' {UPPER}
  | '-' | '+' | '*' | '/' | '^'
  | '<' | '>' | '&' | '|' | '?'
  | ';' | '='
  ;

ternary := 'I' | 'G' ;
quaternary := 'S' ;

UPPER := [A-Z_]
```

## Functions
```
# - comment until EOL

TRUE () - `TRUE` literal.
FALSE () - `FALSE` literal.
NULL () - `NULL` literal.
PROMPT () - Reads a line from stdin.
RAND () - Returns a random integer.

EVAL (string) - Evaluates `string`.
BLOCK (body) - Anonymous function.
CALL (block) - Calls `block`.
QUIT (status) - Quits with `status`.
! (x) - Boolean negation of `x`.
` (x) - Runs `x` as a shell command, returns `x`'s stdout.
DEBUG (code) - Prints debugging information for `code`.
LENGTH (string) - Length of `string`.
OUTPUT (thing) - Prints `thing`. If `thing` ends with `\`, it omits the last character, otherwise appends a newline.

X(...) -- This function identifier is explicitly unassigned, so extensions may do with it as they wish.

+ (x, y) - If `x` is a string, converts `y` to a string and concats. Otherwise, convert both to a number and add them.
- (x, y) - Converts both to an integer returns `x - y`.
* (x, y) - Converts both to an integer returns `x * y`.
/ (x, y) - Converts both to an integer returns `x / y`.
% (x, y) - Converts both to an integer returns `x % y`. Optionally supports printf for a single argument if the language
has easy support for it.
^ (x, y) - Converts both to an integer returns `x ^ y`.
& (x, y) - Evaluates both, returns `x` if `x` is truthy, otherwise returns `y`.
| (x, y) - Evaluates both, returns `y` if `x` is truthy, otherwise returns `x`.
< (x, y) - If `x` is a string, converts `y` to a string and checks to see if `x` is less than `y` in the current local. Otherwise, converts both to an integer and sees if `x` is less than `y`.
> (x, y) - If `x` is a string, converts `y` to a string and checks to see if `x` is greater than `y` in the current local. Otherwise, converts both to an integer and sees if `x` is greater than `y`.
? (x, y) - If `x` is a string, converts `y` to a string and checks to see if both are equal. Otherwise, converts both to an integer and sees if theyre both equal.
; (x, y) - Evaluates `x`, then `y`, and returns `y`.
= (x, y) - Sets `x` in the global scope to `y`, crashing if `x` isnt an identifier.
WHILE (cond, body) - Evaluates the `body` while the `cond`s true. Returns `body`s last value, or `NULL` if it never ran.

GET (string, index, length) - Gets a substring of length `length` from `string` starting at `index`.
IF (cond, if_t, if_f) - Evaluates and returns `if_t` if `cond` is truthy. Otherwise, evaluates and returns `if_f`.

SET (string, start, len, repl) - Returns a new string with the substring of length `len`, starting at `start`, replaced with `repl`.
```

## Details
The exact details of the language are not nailed down: This is intentional, as it's meant to be fairly easy to be implemented in each language. Thus, the maximum and minimum of integer types is unspecified
