require 'minitest'
require 'minitest/spec'
require 'stringio'
require_relative 'shared'

describe '4. Function' do
	include Kn::Test::Shared
	parallelize_me!

	describe 'parsing' do
		describe 'symbol functions' do
			it 'should only consume one character' do
				assert_equal false, eval('!1')
				assert_equal 2, eval('+1 1')
			end

			it 'will not consume additional symbolic chars' do
				assert_equal 5, eval('--9 3 1')
			end
		end

		describe 'keyword functions' do
			it 'should strip trailing uppercase chars and _' do
				assert_equal 3, eval('LABCDEFH_IJKLMNOPQRSTUVWXYZ"foo"')
			end

			it 'should not strip trailing `_`s' do
				assert_equal 3, eval('; = _ 99 : + LENGTH _T') # 99 + true = 99 + 1 = 100
			end
		end
	end

	describe '4.1 Nullary' do
		describe '4.1.1 TRUE' do
			it 'is true' do
				assert_equal true, eval('TRUE')
			end
		end

		describe '4.1.2 FALSE' do
			it 'is false' do
				assert_equal false, eval('FALSE')
			end
		end

		describe '4.1.3 NULL' do
			it 'is null' do
				assert_equal :null, eval('NULL')
			end
		end

		describe '4.1.4 PROMPT' do
			it 'should return a string without the \n or \r\n' do
				old_stdin = $stdin
				IO.pipe do |r,w|
					w.write "line one\nline two\r\na\r\n\r\n\nline three"
					$stdin = r
					assert_equal 'line one', eval('PROMPT')
					assert_equal 'line two', eval('PROMPT')
					assert_equal 'a', eval('PROMPT')
					assert_equal '', eval('PROMPT')
					assert_equal '', eval('PROMPT')
					assert_equal 'line three', eval('PROMPT')
				ensure
					$stdin = old_stdin
				end
			end
		end

		describe '4.1.5 RANDOM' do
			it 'should return a random value each time its called.' do
				assert_equal false, eval('? RANDOM RANDOM')
			end
		end
	end

	describe '4.2 Unary' do
		describe '4.2.1 :' do
			it 'should return its argument unchanged, but evaluated' do
				assert_equal 0, eval(': 0')
				assert_equal 1, eval(': 1')
				assert_equal true, eval(': TRUE')
				assert_equal false, eval(': FALSE')
				assert_equal :null, eval(': NULL')
				assert_equal "", eval(': ""')
				assert_equal "a", eval(': "a"')
				assert_runs { eval(': BLOCK QUIT 1') }
				assert_runs { eval(': BLOCK a') }
			end
		end

		describe '4.2.2 EVAL' do
			it 'should evaluate text' do
				assert_equal 12, eval('EVAL "12"')
				assert_fails { eval('EVAL "missing identifier"') }
				assert_equal 12, eval('EVAL "12"') # convert to a string
			end

			it 'should convert values to a string' do
				assert_equal 23, eval('; = true 23 : EVAL TRUE')
				assert_equal 23, eval('; = false 23 : EVAL FALSE')
				assert_equal 23, eval('; = null 23 : EVAL NULL')
				assert_equal 19, eval('EVAL 19')
			end

			it 'should update the global scope' do
				assert_equal 591, eval('; EVAL "= foo 591" foo')
			end
		end

		describe '4.2.3 BLOCK' do
			it 'should not evaluate its argument' do
				assert_runs { 'BLOCK bar' }
			end

			it 'should be usable as the rhs argument to `=`' do
				assert_runs { '= foo BLOCK bar' }
			end

			it 'should be usable as the sole argument to `:`' do
				assert_runs { ': BLOCK bar' }
			end

			it 'should be usable as either argument to `;`' do
				assert_runs { '; 12 BLOCK bar' }
				assert_runs { '; BLOCK bar 12' }
			end

			it 'should be usable as the sole argument of CALL' do
				assert_equal 12, eval('CALL BLOCK 12')
				assert_equal 3, eval('; = foo 3 ; = bar BLOCK foo : CALL bar')
			end
		end

		describe '4.2.4 CALL' do
			it 'should evaluate something returned by `BLOCK`' do
				assert_equal 12, eval('CALL BLOCK 12')
				assert_equal "12", eval('CALL BLOCK "12"')
	
				assert_equal true, eval('CALL BLOCK TRUE')
				assert_equal false, eval('CALL BLOCK FALSE')
				assert_equal :null, eval('CALL BLOCK NULL')

				assert_equal "twelve", eval('; = foo BLOCK bar ; = bar "twelve" : CALL foo')
				assert_equal 15, eval('; = foo BLOCK * x 5 ; = x 3 : CALL foo')
			end
		end

		describe '4.2.5 `' do
			it 'should return the stdout of the subshell' do
				assert_equal "and then there was -1\n", eval(%q|` 'echo "and then there was -1"'|)
			end

			it 'should return an empty string with no output' do
				assert_equal '', eval('` ":"')
			end

			it 'should convert its argument to a string' do
				assert_equal '', eval('` TRUE')
				# we can't test any of the others, as `false` has a nonzero exit status,
				# and numbers and null aren't likely to be valid programs.
			end
		end

		describe '4.2.6 QUIT' do
			def exit_code(expr)
				assert_silent do
					execute "QUIT #{expr}", raise_on_failure: false
				rescue
					nil
				end

				$?.exitstatus
			end

			it 'must quit the process with the given return value' do
				assert_equal 0, exit_code(0)
				assert_equal 1, exit_code(1)
				assert_equal 2, exit_code(2)
				assert_equal 10, exit_code(10)
				assert_equal 49, exit_code(49)
				assert_equal 123, exit_code(123)
				assert_equal 126, exit_code(126)
				assert_equal 127, exit_code(127)
			end

			it 'must convert to an integer' do
				assert_equal 1, exit_code('TRUE')
				assert_equal 0, exit_code('FALSE')
				assert_equal 0, exit_code('NULL')
				assert_equal 12, exit_code('"12"')
			end
		end

		describe '4.2.7 !' do
			it 'negates its argument' do
				assert_equal true,  eval('! FALSE')
				assert_equal false, eval('! TRUE')
			end

			it 'converts its argument to a boolean' do
				assert_equal true,  eval('! ""')
				assert_equal false, eval('! "0"')
				assert_equal false, eval('! "1"')

				assert_equal true,  eval('! NULL')

				assert_equal true, eval('! 0')
				assert_equal false,  eval('! 1')
			end
		end

		describe '4.2.8 LENGTH' do
			it 'gets the length of a string' do
				assert_equal 0, eval('LENGTH ""')
				assert_equal 1, eval('LENGTH "0"')
				assert_equal 3, eval('LENGTH "foo"')
				assert_equal 10, eval("LENGTH 'fooba\nrbaz'")
			end

			it 'converts its value to a string' do
				assert_equal 1, eval('LENGTH 0')
				assert_equal 3, eval('LENGTH 923')
				assert_equal 4, eval('LENGTH TRUE')
				assert_equal 5, eval('LENGTH FALSE')
				assert_equal 4, eval('LENGTH NULL')
			end
		end

		describe '4.2.9 DUMP' do
			# this is literally how we test everything, so no need for individual tests.
		end

		describe '4.2.10 OUTPUT' do
			it 'prints out a string' do end
			it 'converts its argument to a string' do end
			it 'prints out a trailing newline when `\\` is not added' do end
			it 'removes the last character and omits a newline when a trailing `\\` is present' do end
			it 'returns the result of executing its value' do end
		end

		describe '4.3.1 +' do
			# see `number.rb` and `string.rb`
		end

		describe '4.3.2 -' do
			# see `number.rb`
		end

		describe '4.3.3 *' do
			# see `number.rb` and `string.rb`
		end

		describe '4.3.4 /' do
			# see `number.rb`
		end

		describe '4.3.5 %' do
			# see `number.rb`
		end

		describe '4.3.6 ^' do
			# see `number.rb`
		end

		describe '4.3.7 <' do
			# see `number.rb` ,`string.rb`, and `boolean.rb`
		end

		describe '4.3.8 >' do
			# see `number.rb` ,`string.rb`, and `boolean.rb`
		end

		describe '4.3.9 ?' do
			# see `number.rb` ,`string.rb`, `boolean.rb`, and `null.r`
		end

		describe '4.3.10 &' do
			it 'returns the lhs if its falsey' do
				assert_equal 0, eval('& 0 QUIT 1')
				assert_equal false, eval('& FALSE QUIT 1')
				assert_equal :null, eval('& NULL QUIT 1')
				assert_equal '', eval('& "" QUIT 1')
			end

			it 'executes the rhs only if the lhs is truthy' do
				assert_equal 1, eval('; & 1 (= a 1) a')
				assert_equal 2, eval('; & TRUE (= a 2) a')
				assert_equal 3, eval('; & "hi" (= a 3) a')
				assert_equal 4, eval('; & "0" (= a 4) a')
				assert_equal 5, eval('; & "NaN" (= a 5) a')
			end

			it 'returns the lhs if its falsey' do end
			it 'executes the rhs only if the lhs is truthy' do end
		end

		describe '4.3.11 |' do
			it 'returns the lhs if its truthy' do
				assert_equal 1, eval('| 1 QUIT 1')
				assert_equal 2, eval('| 2 QUIT 1')
				assert_equal true, eval('| TRUE QUIT 1')
				assert_equal 'hi', eval('| "hi" QUIT 1')
				assert_equal '0', eval('| "0" QUIT 1')
				assert_equal 'NaN', eval('| "NaN" QUIT 1')
			end

			it 'executes the rhs only if the lhs is falsey' do
				assert_equal 1, eval('; | 0 (= a 1) a')
				assert_equal 2, eval('; | FALSE (= a 2) a')
				assert_equal 3, eval('; | NULL (= a 3) a')
				assert_equal 4, eval('; | "" (= a 4) a')
			end
		end

		describe '4.3.12 ;' do
			it "executes the first argument, then the second, then returns the second's value" do
				assert_equal 1, eval('; 0 1')
				assert_equal 3, eval('; = a 3 : a')
			end
		end

		describe '4.3.13 =' do
			it 'assigns to variables' do
				assert_equal 12, eval('; = a 12 : a')
			end

			it 'returns its given value' do
				assert_equal 12, eval('= a 12')
			end
		end

		describe '4.3.14 WHILE' do
			it 'returns null' do
				assert_equal :null, eval('WHILE 0 0')
			end

			it 'will not evaluate the body if the condition is true' do
				assert_equal 12, eval('; WHILE FALSE (QUIT 1) : 12')
			end

			it 'will evaluate the body until the condition is false' do
				assert_equal 10, eval('; = i 0 ; WHILE (< i 10) (= i + i 1) : i')
			end
		end
	end

	describe '4.4 Ternary' do
		describe '4.4.1 IF' do
			it 'only executes and returns the second argument if the condition is truthy' do
				assert_equal 12, eval('IF 1 12 (QUIT 1)')
			end

			it 'only executes and returns the third argument if the condition is falsey' do
				assert_equal 12, eval('IF NULL (QUIT 1) 12')
			end

			it 'executes the condition before the result' do
				assert_equal 12, eval('IF (= a 3) (+ a 9) (QUIT 1)')
			end
		end

		describe '4.4.2 GET' do
			# it ''
			# TODO: this
		end
	end

	describe '4.5 Quaternary' do
		describe '4.5.1 SUBSTITUTE' do
			# TODO: this
		end
	end
end
