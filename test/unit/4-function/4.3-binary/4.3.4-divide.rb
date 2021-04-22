require_relative '../function-spec'

section '4.3.4', '/' do
	include Kn::Test::Spec
	include Kn::Test::Spec::Function

	it 'divides nonzero numbers normally' do
		assert_equal 1, eval('/ 1 1')
		assert_equal 5, eval('/ 10 2')
		assert_equal -5, eval('/ (- 0 10) 2')
		assert_equal -10, eval('/ 40 (- 0 4)')
		assert_equal 20, eval('/ (- 0 80) (- 0 4)')

		assert_equal 3, eval('/ 13 4')
		assert_equal -3, eval('/ 13 (- 0 4)')
		assert_equal -3, eval('/ (- 0 13) 4')
		assert_equal 3, eval('/ (- 0 13) (- 0 4)')
	end

	it 'rounds downwards' do
		assert_equal 0, eval('/ 4 5')
		assert_equal 2, eval('/ 10 4')
		assert_equal -1, eval('/ (- 0 5) 3')
		assert_equal -2, eval('/ (- 0 7) 3')
	end

	it 'evaluates arguments in order' do
		assert_equal 15, eval('/ (= n 45) (- n 42)')
		assert_equal -15, eval('/ (= n 15) (- n 14)')
		assert_equal -15, eval('/ (= n 15) (- n 16)')
	end

	it 'converts other values to integers' do
		assert_equal 7, eval('/ 15 "2"')
		assert_equal 22, eval('/ 91 "4"')
		assert_equal 9, eval('/ 9 TRUE')
	end

	# Note that there's no way to overflow with division, as we only have integers.

	it 'does not divide by zero', when_testing: :zero_division do
		assert_fails { eval('/ (- 0 1) 0') }
		assert_fails { eval('/ 100 0') }
		assert_fails { eval('/ 1 FALSE') }
		assert_fails { eval('/ 1 NULL') }
	end

	it 'only allows a number as the first operand', when_testing: :invalid_types do
		assert_fails { eval('/ TRUE 1') }
		assert_fails { eval('/ FALSE 1') }
		assert_fails { eval('/ NULL 1') }
		assert_fails { eval('/ "not-a-number" 1') }
		assert_fails { eval('/ "123" 1') } # ie a numeric string

		if testing? :strict_types
			assert_fails { eval('; = a 3 : / (BLOCK a) 1') }
			assert_fails { eval('/ (BLOCK QUIT 0) 1') }
		end
	end

	#test_argument_count '/', '1', '2'
end
