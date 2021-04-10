require_relative '../../spec'

describe '4. Function' do
	include Kn::Test::Spec

	describe '4.3.3 *' do
		describe 'when the first arg is a string' do
			it 'duplicates itself with positive integers' do
				assert_equal '', eval('* "" 12')
				assert_equal 'foo', eval('* "foo" 1')
				assert_equal 'a1a1a1a1', eval('* "a1" 4')
				assert_equal 'haihaihaihaihaihaihaihai', eval('* "hai" 8')
			end

			it 'returns an empty string when multiplied by zero' do
				assert_equal '', eval('* "hi" 0')
				assert_equal '', eval('* "what up?" 0')
			end

			it 'coerces the RHS to a number' do
				assert_equal 'foofoofoo', eval('* "foo" "3"')
				assert_equal 'foo', eval('* "foo" TRUE')
				assert_equal '', eval('* "foo" NULL')
				assert_equal '', eval('* "foo" FALSE')
			end

			it 'only allows for a nonnegative duplication amount', when_testing: :invalid_value do
				assert_fails { eval('* "hello" (- 0 1)') }
				assert_fails { eval('* "hello" (- 0 4)') }
				assert_fails { eval('* "" (- 0 4)') }
				assert_fails { eval('* "1" (- 0 4)') }
			end
		end

		describe 'when the first arg is a number' do
			it 'works with integers' do
				assert_equal 0, eval('* 0 0')
				assert_equal 2, eval('* 1 2')
				assert_equal 24, eval('* 4 6')
				assert_equal -36, eval('* 12 (- 0 3)')

				assert_equal 52, eval('* 4 13')
				assert_equal -52, eval('* 4 (- 0 13)')
				assert_equal -52, eval('* (- 0 4) 13')
				assert_equal 52, eval('* (- 0 4) (- 0 13)')
			end

			it 'converts other values to integers' do
				assert_equal -2, eval('* 1 "-2"')
				assert_equal 364, eval('* 91 "4"')
				assert_equal 9, eval('* 9 TRUE')
				assert_equal 0, eval('* 9 FALSE')
				assert_equal 0, eval('* 9 NULL')
			end

			it 'errors on overflow', when_testing: :overflow do
				fail "todo: overflow (need to get bit length)"
			end
		end

		it 'evaluates arguments in order' do
			assert_equal 135, eval('* (= n 45) (- n 42)')
			assert_equal 15, eval('* (= n 15) (- n 14)')
			assert_equal -15, eval('* (= n 15) (- n 16)')
		end

		it 'only allows a number or string as the first operand', when_testing: :invalid_types do
			assert_fails { eval('* TRUE 1') }
			assert_fails { eval('* FALSE 1') }
			assert_fails { eval('* NULL 1') }

			if testing? :strict_types
				assert_fails { eval('; = a 3 : * (BLOCK a) 1') }
				assert_fails { eval('* (BLOCK QUIT 0) 1') }
			end
		end

		it 'requires exactly two arguments', when_testing: :argument_count do
			assert_fails { eval('*') }
			assert_fails { eval('* 1') }
			assert_fails { eval('* "1"') }
			assert_runs  { eval('* 1 1') }
			assert_runs  { eval('* "1" 1') }
		end
	end
end
