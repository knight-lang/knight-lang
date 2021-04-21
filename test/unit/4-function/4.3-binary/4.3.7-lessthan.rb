require_relative '../function-spec'

section '4.3.7', '<' do
	include Kn::Test::Spec

	describe 'when the first arg is a boolean' do
		it 'is only true when FALSE and the rhs is truthy' do
			assert_equal true, evaluate('< FALSE TRUE')
			assert_equal true, evaluate('< FALSE 1')
			assert_equal true, evaluate('< FALSE "1"')
			assert_equal true, evaluate('< FALSE (- 0 1)')
		end

		it 'is false all other times' do
			assert_equal false, evaluate('< FALSE FALSE')
			assert_equal false, evaluate('< FALSE 0')
			assert_equal false, evaluate('< FALSE ""')
			assert_equal false, evaluate('< FALSE NULL')

			assert_equal false, evaluate('< TRUE TRUE')
			assert_equal false, evaluate('< TRUE FALSE')
			assert_equal false, evaluate('< TRUE 1')
			assert_equal false, evaluate('< TRUE "1"')
			assert_equal false, evaluate('< TRUE 2')
			assert_equal false, evaluate('< TRUE (- 0 2)')
			assert_equal false, evaluate('< TRUE 0')
			assert_equal false, evaluate('< TRUE ""')
			assert_equal false, evaluate('< TRUE NULL')
		end
	end

	describe 'when the first arg is a string' do
		it 'performs lexicographical comparison' do
			assert_equal true,  evaluate('< "a" "aa"')
			assert_equal false, evaluate('< "b" "aa"')

			assert_equal false, evaluate('< "aa" "a"')
			assert_equal true,  evaluate('< "aa" "b"')

			assert_equal true,  evaluate('< "A" "AA"')
			assert_equal false, evaluate('< "B" "AA"')

			assert_equal false, evaluate('< "AA" "A"')
			assert_equal true,  evaluate('< "AA" "B"')

			# ensure it obeys ascii
			assert_equal false, evaluate('< "a" "A"')
			assert_equal true,  evaluate('< "A" "a"')
			assert_equal false, evaluate('< "z" "Z"')
			assert_equal true,  evaluate('< "Z" "z"')

			assert_equal true, evaluate('< "/" 0')
			assert_equal true, evaluate('< "8" 9')
		end

		it 'performs it even with numbers' do
			assert_equal true, evaluate('< "0" "00"')
			assert_equal true, evaluate('< "1" "12"')
			assert_equal true, evaluate('< "100" "12"')
			assert_equal false, evaluate('< "00" "0"')
			assert_equal false, evaluate('< "12" "1"')
			assert_equal false, evaluate('< "12" "100"')

			assert_equal true, evaluate('< "  0" "  00"')
			assert_equal true, evaluate('< "  1" "  12"')
			assert_equal true, evaluate('< "  100" "  12"')
		end

		it 'coerces the RHS to a string' do
			assert_equal true, evaluate('< "0" 1')
			assert_equal true, evaluate('< "1" 12')
			assert_equal true, evaluate('< "100" 12')
			assert_equal false, evaluate('< "00" 0')
			assert_equal false, evaluate('< "12" 100')
			assert_equal false, evaluate('< "12" 100')

			assert_equal true, evaluate('< "trud" TRUE')
			assert_equal false, evaluate('< "true" TRUE')
			assert_equal false, evaluate('< "truf" TRUE')

			assert_equal true, evaluate('< "falsd" FALSE')
			assert_equal false, evaluate('< "false" FALSE')
			assert_equal false, evaluate('< "faslf" FALSE')

			assert_equal true, evaluate('< "nulk" NULL')
			assert_equal false, evaluate('< "null" NULL')
			assert_equal false, evaluate('< "nulm" NULL')
		end
	end

	describe 'when the first arg is a number' do
		it 'performs numeric comparison' do
			assert_equal false, evaluate('< 1 1')
			assert_equal false, evaluate('< 0 0')
			assert_equal true, evaluate('< 12 100')
			assert_equal true, evaluate('< 1 2')
			assert_equal true, evaluate('< 91 491')

			assert_equal false, evaluate('< 100 12')
			assert_equal false, evaluate('< 2 1')
			assert_equal false, evaluate('< 491 91')

			assert_equal true, evaluate('< 4 13')
			assert_equal false, evaluate('< 4 (- 0 13)')
			assert_equal true, evaluate('< (- 0 4) 13')
			assert_equal false, evaluate('< (- 0 4) (- 0 13)')
		end

		it 'coerces the RHS to a number' do
			assert_equal true, evaluate('< 0 TRUE')
			assert_equal true, evaluate('< 0 "1"')
			assert_equal true, evaluate('< 0 "49"')
			assert_equal true, evaluate('< (- 0 2) "-1"')

			assert_equal false, evaluate('< 0 FALSE')
			assert_equal false, evaluate('< 0 NULL')
			assert_equal false, evaluate('< 0 "0"')
			assert_equal false, evaluate('< 0 "-1"')
			assert_equal false, evaluate('< 0 ""')
		end
	end

	it 'evaluates arguments in order' do
		assert_equal true,  evaluate('< (= n 45) 46')
		assert_equal false, evaluate('< (= n 45) 44')

		assert_equal true,  evaluate('< (= n "mhm") (+ n "m")')
		assert_equal false, evaluate('< (+ (= n "mhm") "m") n')

		assert_equal false, evaluate('< (= n TRUE) !n')
		assert_equal true,  evaluate('< (= n FALSE) !n')
	end

	it 'only allows a number, boolean, or string as the first operand', when_testing: :invalid_types do
		assert_fails { evaluate('< NULL 1') }

		if testing? :strict_types
			assert_fails { evaluate('; = a 3 : < (BLOCK a) 1') }
			assert_fails { evaluate('< (BLOCK QUIT 0) 1') }
		end
	end

	test_argument_count '<', '1', '2'
end