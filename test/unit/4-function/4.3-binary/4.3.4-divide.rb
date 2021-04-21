require_relative '../function-spec'

section '4.3.4', '/' do
	include Kn::Test::Spec
	include Kn::Test::Spec::Function

	it 'divides nonzero numbers normally' do
		assert_equal 1, evaluate('/ 1 1')
		assert_equal 5, evaluate('/ 10 2')
		assert_equal -5, evaluate('/ (- 0 10) 2')
		assert_equal -10, evaluate('/ 40 (- 0 4)')
		assert_equal 20, evaluate('/ (- 0 80) (- 0 4)')

		assert_equal 3, evaluate('/ 13 4')
		assert_equal -3, evaluate('/ 13 (- 0 4)')
		assert_equal -3, evaluate('/ (- 0 13) 4')
		assert_equal 3, evaluate('/ (- 0 13) (- 0 4)')
	end

	it 'rounds downwards' do
		assert_equal 0, evaluate('/ 4 5')
		assert_equal 2, evaluate('/ 10 4')
		assert_equal -1, evaluate('/ (- 0 5) 3')
		assert_equal -2, evaluate('/ (- 0 7) 3')
	end

	it 'evaluates arguments in order' do
		assert_equal 15, evaluate('/ (= n 45) (- n 42)')
		assert_equal -15, evaluate('/ (= n 15) (- n 14)')
		assert_equal -15, evaluate('/ (= n 15) (- n 16)')
	end

	it 'converts other values to integers' do
		assert_equal 7, evaluate('/ 15 "2"')
		assert_equal 22, evaluate('/ 91 "4"')
		assert_equal 9, evaluate('/ 9 TRUE')
	end

	# Note that there's no way to overflow with division, as we only have integers.

	it 'does not divide by zero', when_testing: :zero_division do
		assert_fails { evaluate('/ (- 0 1) 0') }
		assert_fails { evaluate('/ 100 0') }
		assert_fails { evaluate('/ 1 FALSE') }
		assert_fails { evaluate('/ 1 NULL') }
	end

	it 'only allows a number as the first operand', when_testing: :invalid_types do
		assert_fails { evaluate('/ TRUE 1') }
		assert_fails { evaluate('/ FALSE 1') }
		assert_fails { evaluate('/ NULL 1') }
		assert_fails { evaluate('/ "not-a-number" 1') }
		assert_fails { evaluate('/ "123" 1') } # ie a numeric string

		if testing? :strict_types
			assert_fails { evaluate('; = a 3 : / (BLOCK a) 1') }
			assert_fails { evaluate('/ (BLOCK QUIT 0) 1') }
		end
	end

	test_argument_count '/', '1', '2'
end
