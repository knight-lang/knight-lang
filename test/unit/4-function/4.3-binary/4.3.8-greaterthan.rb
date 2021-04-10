require_relative '../function-spec'

section '4.3.8', '>' do
	include Kn::Test::Spec

	describe 'when the first arg is a boolean' do
		it 'is only true when TRUTHY and the rhs is falsey' do
			assert_equal true, eval('> TRUE FALSE')
			assert_equal true, eval('> TRUE 0')
			assert_equal true, eval('> TRUE ""')
			assert_equal true, eval('> TRUE NULL')
		end

		it 'is false all other times' do
			assert_equal false, eval('> TRUE TRUE')
			assert_equal false, eval('> TRUE 1')
			assert_equal false, eval('> TRUE "1"')

			assert_equal false, eval('> FALSE (- 0 1)')
			assert_equal false, eval('> FALSE TRUE')
			assert_equal false, eval('> FALSE FALSE')
			assert_equal false, eval('> FALSE 1')
			assert_equal false, eval('> FALSE "1"')
			assert_equal false, eval('> FALSE 0')
			assert_equal false, eval('> FALSE ""')
			assert_equal false, eval('> FALSE NULL')
		end
	end

	describe 'when the first arg is a string' do
		it 'performs lexicographical comparison' do
			assert_equal false, eval('> "a" "aa"')
			assert_equal true,  eval('> "b" "aa"')

			assert_equal true,  eval('> "aa" "a"')
			assert_equal false, eval('> "aa" "b"')

			assert_equal false, eval('> "A" "AA"')
			assert_equal true,  eval('> "B" "AA"')

			assert_equal true,  eval('> "AA" "A"')
			assert_equal false, eval('> "AA" "B"')

			# ensure it obeys ascii
			assert_equal true,  eval('> "a" "A"')
			assert_equal false, eval('> "A" "a"')
			assert_equal true,  eval('> "z" "Z"')
			assert_equal false, eval('> "Z" "z"')

			assert_equal true, eval('> ":" 9')
			assert_equal true, eval('> "1" 0')
		end

		it 'performs it even with numbers' do
			assert_equal false, eval('> "0" "00"')
			assert_equal false, eval('> "1" "12"')
			assert_equal false, eval('> "100" "12"')
			assert_equal true, eval('> "00" "0"')
			assert_equal true, eval('> "12" "1"')
			assert_equal true, eval('> "12" "100"')

			assert_equal false, eval('> "  0" "  00"')
			assert_equal false, eval('> "  1" "  12"')
			assert_equal false, eval('> "  100" "  12"')
		end

		it 'coerces the RHS to a number' do
			assert_equal false, eval('> "0" 1')
			assert_equal false, eval('> "1" 12')
			assert_equal false, eval('> "100" 12')
			assert_equal true, eval('> "00" 0')
			assert_equal true, eval('> "12" 100')
			assert_equal true, eval('> "12" 100')

			assert_equal false, eval('> "trud" TRUE')
			assert_equal false, eval('> "true" TRUE')
			assert_equal true,  eval('> "truf" TRUE')

			assert_equal false, eval('> "falsd" FALSE')
			assert_equal false, eval('> "false" FALSE')
			assert_equal true,  eval('> "faslf" FALSE')

			assert_equal false, eval('> "nulk" NULL')
			assert_equal false, eval('> "null" NULL')
			assert_equal true,  eval('> "nulm" NULL')
		end
	end

	describe 'when the first arg is a number' do
		it 'performs numeric comparison' do
			assert_equal false, eval('> 1 1')
			assert_equal false, eval('> 0 0')
			assert_equal false, eval('> 12 100')
			assert_equal false, eval('> 1 2')
			assert_equal false, eval('> 91 491')

			assert_equal true, eval('> 100 12')
			assert_equal true, eval('> 2 1')
			assert_equal true, eval('> 491 91')

			assert_equal false, eval('> 4 13')
			assert_equal true,  eval('> 4 (- 0 13)')
			assert_equal false, eval('> (- 0 4) 13')
			assert_equal true,  eval('> (- 0 4) (- 0 13)')
		end

		it 'coerces the RHS to a number' do
			assert_equal false, eval('> 0 TRUE')
			assert_equal false, eval('> 0 "1"')
			assert_equal false, eval('> 0 "49"')
			assert_equal false, eval('< (- 0 2) "-1"')

			assert_equal true, eval('> 1 FALSE')
			assert_equal true, eval('> 1 NULL')
			assert_equal true, eval('> 1 "0"')
			assert_equal true, eval('> 01 ""')
			assert_equal true, eval('> 0 "-1"')
			assert_equal true, eval('> (- 0 1) "-2"')
		end
	end

	it 'evaluates arguments in order' do
		assert_equal true,  eval('> (= n 45) 44')
		assert_equal false, eval('> (= n 45) 46')

		assert_equal false, eval('> (= n "mhm") (+ n "m")')
		assert_equal true,  eval('> (+ (= n "mhm") "m") n')

		assert_equal false, eval('> (= n TRUE) !n')
		assert_equal true,  eval('> (= n FALSE) !n')
	end

	it 'only allows a number, boolean, or string as the first operand', when_testing: :invalid_types do
		assert_fails { eval('> NULL 1') }

		if testing? :strict_types
			assert_fails { eval('; = a 3 : > (BLOCK a) 1') }
			assert_fails { eval('> (BLOCK QUIT 0) 1') }
		end
	end

	test_argument_count '>', '1', '2'
end