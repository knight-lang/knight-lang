require_relative '../function-spec'

section '4.3.3', '*' do
	include Kn::Test::Spec

	describe 'when the first arg is a string' do
		it 'duplicates itself with positive integers' do
			assert_equal '', evaluate('* "" 12')
			assert_equal 'foo', evaluate('* "foo" 1')
			assert_equal 'a1a1a1a1', evaluate('* "a1" 4')
			assert_equal 'haihaihaihaihaihaihaihai', evaluate('* "hai" 8')
		end

		it 'returns an empty string when multiplied by zero' do
			assert_equal '', evaluate('* "hi" 0')
			assert_equal '', evaluate('* "what up?" 0')
		end

		it 'coerces the RHS to a number' do
			assert_equal 'foofoofoo', evaluate('* "foo" "3"')
			assert_equal 'foo', evaluate('* "foo" TRUE')
			assert_equal '', evaluate('* "foo" NULL')
			assert_equal '', evaluate('* "foo" FALSE')
		end

		it 'only allows for a nonnegative duplication amount', when_testing: :invalid_values do
			assert_fails { evaluate('* "hello" (- 0 1)') }
			assert_fails { evaluate('* "hello" (- 0 4)') }
			assert_fails { evaluate('* "" (- 0 4)') }
			assert_fails { evaluate('* "1" (- 0 4)') }
		end
	end

	describe 'when the first arg is a number' do
		it 'works with integers' do
			assert_equal 0, evaluate('* 0 0')
			assert_equal 2, evaluate('* 1 2')
			assert_equal 24, evaluate('* 4 6')
			assert_equal -36, evaluate('* 12 (- 0 3)')

			assert_equal 52, evaluate('* 4 13')
			assert_equal -52, evaluate('* 4 (- 0 13)')
			assert_equal -52, evaluate('* (- 0 4) 13')
			assert_equal 52, evaluate('* (- 0 4) (- 0 13)')
		end

		it 'converts other values to integers' do
			assert_equal -2, evaluate('* 1 "-2"')
			assert_equal 364, evaluate('* 91 "4"')
			assert_equal 9, evaluate('* 9 TRUE')
			assert_equal 0, evaluate('* 9 FALSE')
			assert_equal 0, evaluate('* 9 NULL')
		end

		it 'errors on overflow', when_testing: :overflow do
			fail "todo: overflow (need to get bit length)"
		end
	end

	it 'evaluates arguments in order' do
		assert_equal 135, evaluate('* (= n 45) (- n 42)')
		assert_equal 15, evaluate('* (= n 15) (- n 14)')
		assert_equal -15, evaluate('* (= n 15) (- n 16)')
	end

	it 'only allows a number or string as the first operand', when_testing: :invalid_types do
		assert_fails { evaluate('* TRUE 1') }
		assert_fails { evaluate('* FALSE 1') }
		assert_fails { evaluate('* NULL 1') }

		if testing? :strict_types
			assert_fails { evaluate('; = a 3 : * (BLOCK a) 1') }
			assert_fails { evaluate('* (BLOCK QUIT 0) 1') }
		end
	end

	test_argument_count '*', '1', '2'
end
