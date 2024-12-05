# Knight
Knight is a minimalistic programming language designed to be easily implementable in a variety of languages. While it _is_ a fully-functional programming language, it's main purpose is to be a somewhat-easy-to-implement language.

Unofficial Tag-line: "Knight: Runs everywhere. Not because it's cross-platform, but because it works in any almost any language you have."

Checkout the [community](COMMUNITY.md), and join us on discord: https://discord.gg/SE3TjsewDk.

# Implementations
I've implemented Knight in quite a few languages over the years. Some of the implementations only implement older versions of the spec (eg Knight 1.0, which was before lists); my eventual plan is to upgrade them all. There are three implementations of special note:

- [go](https://github.com/knight-lang/go): The **exemplar** implementation, intentionally written without any fancy tricks or optimizations, and is thoroughly documented. If you don't know how to get started writing a Knight program, take a look at this one!
- [rust](https://github.com/knight-lang/rust): The **fully-functional** implementation. It has all the suggested extensions (and a few of its own) implemented (`--features=all-extensions`), and **has the ability to check for _all_ forms of undefined behaviour** (`--features=strict-compliance`). If you're not sure if a piece of Knight code is spec compliant, you can run it with `cargo run --no-default-features --features=strict-compliance -- -e ...`!
- [c](https://github.com/knight-lang/c/tree/master/ast): The **fastest**, currently. When compiled with `-DKN_RECKLESS`, it will assume that every input program is 100% spec-compliant (and won't ever error).

## List
The following is the list of all languages that I've written it in:

| Language | Version | 100% Spec Conformance | Documented | Notes |
| -------- |---------|:---------------------:|:----------:|-------|
| [AWK](https://github.com/knight-lang/awk) | 2.0.1 | X | X | Unfortunately, MacOS's awk segfaults on `DUMP PROMPT` sometimes. Other than that, it works. |
| [Assembly (x86)](https://github.com/knight-lang/asm) | 1.0 |   |   | Functional enough to run the benchmark. A few auxiliary functions (eg `* STRING NUM`) are left. |
| [C](https://github.com/knight-lang/c/tree/master/ast) | 2.0.1 | X | X | Fully functional  |
| [C++](https://github.com/knight-lang/cpp) | 2.0.1 | X | X | Works with C++17 |
| [C#](https://github.com/knight-lang/csharp) | 1.0 | X | X | Simple version without any documentation. It can be cleaned up slightly though. |
| [Go](https://github.com/knight-lang/go) | 2.1.0 | X | X | The "exemplar" Knight implementation: Simply made, fully documented. |
| [Haskell](https://github.com/knight-lang/haskell) | pre-1.0 |   |  | ish | X | Works for an older spec of Knight, needs to be updated. |
| [Java](https://github.com/knight-lang/java) | 1.0 | X |   | Simple version without any documentation. It can be cleaned up slightly though. |
| [JavaScript](https://github.com/knight-lang/knight.js) | 1.0 | X | X | Fully Functional, although it requires Node.js for the OS-related functions. |
| [Knight](https://github.com/knight-lang/knight-lang/blob/master/examples/knight.kn) | 2.0.1 |   |   | Yes, this is a Knight interpreter, written in Knight. |
| [Kotlin](https://github.com/knight-lang/kotlin) | 1.0 | X | X | Fully funcitonal, and barring `` ` ``, can be compiled to native. |
| [Perl](https://github.com/knight-lang/perl) | 1.1 | X | X | Fully Functional on at least v5.18. |
| [PHP](https://github.com/knight-lang/php) | 1.0 | X | X | Fully Functional, with type annotations. |
| [POSIX-Compliant SH](https://github.com/knight-lang/shell) | 2.0.1 | X | X | 100% Spec complaint. Requires POSIX-2017 compliance at a minimum, but might be 2008-compliant (I haven't tested). |
| [Python](https://github.com/knight-lang/python) | 1.0 | X | X | Fully Functional, though `setrecursionlimit` is needed to ensure "FizzBuzz in Knight in Python" works. |
| [Raku](https://github.com/knight-lang/raku) | 1.1 | X | X | Fully Functional, but quite slow. But hey, it was fun to write in. |
| [Ruby](https://github.com/knight-lang/ruby) | 1.0 | X |   | A hacky version currently exists; a more sophisticated one is being worked on. |
| [Rust](https://github.com/knight-lang/rust) | 2.0.1 | X |   | Captures _all_ UB if you enable `strict-compliance`. Also has most extensions |
| [ZSH](https://github.com/knight-lang/zsh) | 2.0.1 | X | X | |

## Personal Languages
I love language design, and have written quite a few programming languages. I generally try to get the languages fleshed out enough so that I can write a fully compliant Knight interpreter in it.

| Language | 100% Spec Conformance | Documented | Mostly Functional | Begun | Notes |
| -------- |:---------------------:|:----------:|:-----------------:|:-----:| ----- |
| [Brick](https://github.com/sampersand/Brick/tree/master/examples) | X |   |  |
| [Squire](https://github.com/sampersand/squire/tree/master/examples/knight) | X | | |
| Quest | | | | X | Implemented in quest 1, so not entirely working. |
| Stick | | | | X | |
| Lance | | | Few bugs left to workout |
| Mercenary | | | | | |

## Future
In addition, the following is a list of languages which I want to write an implementation in at some point.

| Language | Notes |
| :------- | ----- |
| Elixir | Probably the next one I'll do. |
| Lua | Planned for somepoint soon. |
| SML | Eventually. I used this in college, and enjoyed it. |
| Racket | Eventually. I used this in college, and enjoyed it. |
| LaTeX | Eventually. Because why not? I did a lot of LaTeX in college. |
| Scratch | My first language! Might be fun to implement it in this |
| [Prolog](https://github.com/knight-lang/prolog) | The very beginnings of a Prolog implementation. |
| Fortran | This might be fun to try, but there's not a lot of documentations about it. |

## Time Comparisons
**NOTE**: _These are outdated. I no longer own the computer I tested them on, and the `timeit` file doesn't actually work. I'll be updating them in the future._
The following able describes how fast each implementation (in `user` time) was at running `examples/fizzbuzz.kn` in `knight.kn` in `knight.kn` in their implementation, on my machine. You can test it yourself via the [timeit](timeit) script provided.

Note that these are simply benchmarks of _my_ implementations of Knight, and not a reflection of the efficiency of the languages themselves.

|   Language   |  Time   | `<implementation>` | Notes |
| ------------ |--------:|--------------------|-------|
| C            |   3.31s | `c/ast/knight`     | Compiled using `COMPUTED_GOTOS=1 CFLAGS='-DKN_RECKLESS -DKN_USE_EXTENSIONS' make optimized`; See [https://github.com/knight-lang/c/ast/README.md](c/ast/README.md) for details. |
| Kotlin       |   5.84s | `kotlin/knight` |  |
| x86 Assembly |   6.29s | `asm/knight` | Currently only has AST caching. (The C impl without caching runs 10.22s) |
| Java         |   6.99s | `java/knight` | Requires a larger stack to prevent overflow; `java -Xss515m` was used. |
| Rust         |  10.06s | `rust/target/release/knight` | Built with `cargo build --release --no-default-features --features=unsafe-optimized`. Still being improved. 
| C#           |  11.82s | `csharp/bin/Release/netcoreapp2.1/<impl>/Knight` | |
| C++          |  13.61s | `cpp/knight`       | Copiled using `make optimized` |
| Go           |  14.17s | `go/knight/knight` | |
| JavaScript   |  30.64s | `node --stack-size=1000000 javasript/bin/knight.js` | Default stack's too small, so we had to bump it up. |
| PHP          |  64.73s | `php/knight.php`   | |
| Ruby         | 110.04s | `ruby/knight.rb`   | Default stack's too small, so `RUBY_THREAD_VM_STACK_SIZE=10000000` was needed. |
| Python       | 236.01s | `python/main.py`   | Default stack's too small, so `setrecursionlimit(100000)` was needed. |
| Perl         | 436.55s | `perl/bin/knight.pl` | |

# Examples
Here's some examples of the syntax to give you a feel for it:

## Guessing Game
```
; = max 100                                   # max = 100
; = secret + 1 (% RAND max)                   # secret = rand(1, max)
; = nguess 0                                  # nguess = 0
; = guess 0                                   # guess = 0
; OUTPUT (+ 'guess 1-' max)                   # print('pick from 1-' + m)
; WHILE (| (< guess secret) (> guess secret)) # while guess != s:
  ; OUTPUT '> \'                              #   print('> ', end='')
  ; = guess (+ 0 PROMPT)                      #   guess = int(prompt())
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
        ; = b + a (= tmp b              #       b = a + (tmp = b)
        ; = a tmp                       #       a = tmp
        : = n - n 1                     #       n -= 1
    : a                                 #    return a
; = n 10                                # n = 10
: OUTPUT +++ 'fib(' n ')=' CALL fib     # print "fib(" + n + ")=" + fib()
# => fib(10)=55
```

# Spec Overview
The following is just a rough overview, and is not to be taken as authoritative; for exact details please see [specs.md](specs.md). 

## Syntax
Every Knight program is a single expression. (The `;` function can be used to write more than one expression, sequentially.) Because of this, parsing is extremely simple: Parse a token, then parse as many arguments as that expression dictates.

Non-symbol functions are defined by their first character: additional uppercase characters following it are ignored. Because of this, `OUTPUT` is the same as `OUT`, which is the same as `OFOOBARBAZ`.

Tokens may follow directly one after another (eg `1a` is parsed as `1` and then `a`), except in the following four cases (which must have whitespace or comments):

1. Between two "word" keywords, such as `IF PROMPT`
2. Between two numbers, such as `+ 1 2`
3. Between two identifiers, such as `* a b`
4. Between an identifier and a number, such as `+ a 3`.

Additionally, while not technically whitesapce, `(`, `)`, and `:` can be safely interpreted as whitespace as well. As such, expressions such as `OUTPUT * a (IF b 3 b)` can be written as `O*aIb 3b`.

## EBNF
Knight's ENBF is as follows:
```ebnf
program := expr ;
expr := integer-literal
      | string-literal
      | identifier
      | nullary
      | unary      expr
      | binary     expr expr
      | ternary    expr expr expr
      | quaternary expr expr expr expr ;

integer-literal := DIGIT {DIGIT} ;
string-literal  := `'` {NON_SINGLE} `'` | `"` {NON_DOUBLE} `"` ;
identifier      := LOWER {LOWER | DIGIT} ;

nullary := '@'
         | ('T' | 'F' | 'N' | 'P' | 'R') {UPPER} ;

unary := ':' | '!' | '~' | ',' | '[' | ']'
       | ('B' | 'C' | 'Q' | 'D' | 'O' | 'L' | 'A') {UPPER} ;

binary := '+' | '-' | '*' | '/' | '%' | '^'
        | '<' | '>' | '?' | '&' | '|' | ';' | '='
        | 'W' {UPPER} ;

ternary := ('I' | 'G') {UPPER} ;

quaternary := 'S' {UPPER} ;

UPPER := [A-Z] | '_' ;
LOWER := [a-z] | '_' ;
DIGIT := [0-9] ;
NON_SINGLE := (? any character except single quote (`'`) *) ;
NON_DOUBLE := (? any character except double quote (`"`) *) ;
```

