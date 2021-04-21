require_relative '../function-spec'

section '4.3.8', '>' do
	include Kn::Test::Spec

	describe 'when the first arg is a boolean' do
		it 'is only true when TRUTHY and the rhs is falsey' do
			assert_equal true, evaluate('> TRUE FALSE')
			assert_equal true, evaluate('> TRUE 0')
			assert_equal true, evaluate('> TRUE ""')
			assert_equal true, evaluate('> TRUE NULL')
		end

		it 'is false all other times' do
			assert_equal false, evaluate('> TRUE TRUE')
			assert_equal false, evaluate('> TRUE 1')
			assert_equal false, evaluate('> TRUE "1"')

			assert_equal false, evaluate('> FALSE (- 0 1)')
			assert_equal false, evaluate('> FALSE TRUE')
			assert_equal false, evaluate('> FALSE FALSE')
			assert_equal false, evaluate('> FALSE 1')
			assert_equal false, evaluate('> FALSE "1"')
			assert_equal false, evaluate('> FALSE 0')
			assert_equal false, evaluate('> FALSE ""')
			assert_equal false, evaluate('> FALSE NULL')
		end
	end

	describe 'when the first arg is a string' do
		it 'performs lexicographical comparison' do
			assert_equal false, evaluate('> "a" "aa"')
			assert_equal true,  evaluate('> "b" "aa"')

			assert_equal true,  evaluate('> "aa" "a"')
			assert_equal false, evaluate('> "aa" "b"')

			assert_equal false, evaluate('> "A" "AA"')
			assert_equal true,  evaluate('> "B" "AA"')

			assert_equal true,  evaluate('> "AA" "A"')
			assert_equal false, evaluate('> "AA" "B"')

			# ensure it obeys ascii
			assert_equal true,  evaluate('> "a" "A"')
			assert_equal false, evaluate('> "A" "a"')
			assert_equal true,  evaluate('> "z" "Z"')
			assert_equal false, evaluate('> "Z" "z"')

			assert_equal true, evaluate('> ":" 9')
			assert_equal true, evaluate('> "1" 0')
		end

		it 'performs it even with numbers' do
			assert_equal false, evaluate('> "0" "00"')
			assert_equal false, evaluate('> "1" "12"')
			assert_equal false, evaluate('> "100" "12"')
			assert_equal true, evaluate('> "00" "0"')
			assert_equal true, evaluate('> "12" "1"')
			assert_equal true, evaluate('> "12" "100"')

			assert_equal false, evaluate('> "  0" "  00"')
			assert_equal false, evaluate('> "  1" "  12"')
			assert_equal false, evaluate('> "  100" "  12"')
		end

		it 'coerces the RHS to a number' do
			assert_equal false, evaluate('> "0" 1')
			assert_equal false, evaluate('> "1" 12')
			assert_equal false, evaluate('> "100" 12')
			assert_equal true, evaluate('> "00" 0')
			assert_equal true, evaluate('> "12" 100')
			assert_equal true, evaluate('> "12" 100')

			assert_equal false, evaluate('> "trud" TRUE')
			assert_equal false, evaluate('> "true" TRUE')
			assert_equal true,  evaluate('> "truf" TRUE')

			assert_equal false, evaluate('> "falsd" FALSE')
			assert_equal false, evaluate('> "false" FALSE')
			assert_equal true,  evaluate('> "faslf" FALSE')

			assert_equal false, evaluate('> "nulk" NULL')
			assert_equal false, evaluate('> "null" NULL')
			assert_equal true,  evaluate('> "nulm" NULL')
		end
	end

	describe 'when the first arg is a number' do
		it 'performs numeric comparison' do
			assert_equal false, evaluate('> 1 1')
			assert_equal false, evaluate('> 0 0')
			assert_equal false, evaluate('> 12 100')
			assert_equal false, evaluate('> 1 2')
			assert_equal false, evaluate('> 91 491')

			assert_equal true, evaluate('> 100 12')
			assert_equal true, evaluate('> 2 1')
			assert_equal true, evaluate('> 491 91')

			assert_equal false, evaluate('> 4 13')
			assert_equal true,  evaluate('> 4 (- 0 13)')
			assert_equal false, evaluate('> (- 0 4) 13')
			assert_equal true,  evaluate('> (- 0 4) (- 0 13)')
		end

		it 'coerces the RHS to a number' do
			assert_equal false, evaluate('> 0 TRUE')
			assert_equal false, evaluate('> 0 "1"')
			assert_equal false, evaluate('> 0 "49"')
			assert_equal false, evaluate('< (- 0 2) "-1"')

			assert_equal true, evaluate('> 1 FALSE')
			assert_equal true, evaluate('> 1 NULL')
			assert_equal true, evaluate('> 1 "0"')
			assert_equal true, evaluate('> 01 ""')
			assert_equal true, evaluate('> 0 "-1"')
			assert_equal true, evaluate('> (- 0 1) "-2"')
		end
	end

	it 'evaluates arguments in order' do
		assert_equal true,  evaluate('> (= n 45) 44')
		assert_equal false, evaluate('> (= n 45) 46')

		assert_equal false, evaluate('> (= n "mhm") (+ n "m")')
		assert_equal true,  evaluate('> (+ (= n "mhm") "m") n')

		assert_equal false, evaluate('> (= n TRUE) !n')
		assert_equal true,  evaluate('> (= n FALSE) !n')
	end

	it 'only allows a number, boolean, or string as the first operand', when_testing: :invalid_types do
		assert_fails { evaluate('> NULL 1') }

		if testing? :strict_types
			assert_fails { evaluate('; = a 3 : > (BLOCK a) 1') }
			assert_fails { evaluate('> (BLOCK QUIT 0) 1') }
		end
	end

	test_argument_count '>', '1', '2'
end