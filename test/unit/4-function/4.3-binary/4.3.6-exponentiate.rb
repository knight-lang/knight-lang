require_relative '../function-spec'

section '4.3.6', '^' do
	include Kn::Test::Spec

	it 'raises positive numbers correctly' do
		assert_equal 1, evaluate('^ 1 1')
		assert_equal 1, evaluate('^ 1 100')
		assert_equal 16, evaluate('^ 2 4')
		assert_equal 125, evaluate('^ 5 3')
		assert_equal 3375, evaluate('^ 15 3')
		assert_equal 15129, evaluate('^ 123 2')
	end

	it 'returns 0 when the base is zero, unless the power is zero' do
		assert_equal 0, evaluate('^ 0 1')
		assert_equal 0, evaluate('^ 0 100')
		assert_equal 0, evaluate('^ 0 4')
		assert_equal 0, evaluate('^ 0 3')
	end

	it 'returns 1 when raising to the power of 0' do
		assert_equal 1, evaluate('^ 1 0')
		assert_equal 1, evaluate('^ 100 0')
		assert_equal 1, evaluate('^ 4 0')
		assert_equal 1, evaluate('^ 3 0')
		assert_equal 1, evaluate('^ (- 0 3) 0')
	end

	# Since we only have integral types, anything (normal) raised to a negative number is zero.
	it 'always returns zero when a > 1 number is raised to a negative power' do
		assert_equal 0, evaluate('^ 2 (- 0 2)')
		assert_equal 0, evaluate('^ 100 (- 0 2)')
		assert_equal 0, evaluate('^ 4 (- 0 2)')
		assert_equal 0, evaluate('^ 3 (- 0 2)')
		assert_equal 0, evaluate('^ (- 0 3) (- 0 2)')
	end

	it 'returns a negative number when a negative number is raised ot an odd power' do
		assert_equal -1, evaluate('^ (- 0 1) 1')
		assert_equal -8, evaluate('^ (- 0 2) 3')
		assert_equal 16, evaluate('^ (- 0 2) 4')
		assert_equal -32, evaluate('^ (- 0 2) 5')
		assert_equal 100, evaluate('^ (- 0 10) 2')
		assert_equal -1331, evaluate('^ (- 0 11) 3')
		assert_equal 20736, evaluate('^ (- 0 12) 4')
	end

	it 'handles one, zero, and negative one properly' do
		assert_equal 0, evaluate('^ 0 3')
		assert_equal 0, evaluate('^ 0 2')
		assert_equal 0, evaluate('^ 0 1')
		assert_equal 1, evaluate('^ 0 0')
		# 0 to a negative power is undefined.

		assert_equal 1, evaluate('^ 1 3')
		assert_equal 1, evaluate('^ 1 2')
		assert_equal 1, evaluate('^ 1 1')
		assert_equal 1, evaluate('^ 1 0')
		assert_equal 1, evaluate('^ 1 (- 0 1)')
		assert_equal 1, evaluate('^ 1 (- 0 2)')
		assert_equal 1, evaluate('^ 1 (- 0 3)')

		assert_equal -1, evaluate('^ (- 0 1) 3')
		assert_equal 1, evaluate('^ (- 0 1) 2')
		assert_equal -1, evaluate('^ (- 0 1) 1')
		assert_equal 1, evaluate('^ (- 0 1) 0')
		assert_equal -1, evaluate('^ (- 0 1) (- 0 1)')
		assert_equal 1, evaluate('^ (- 0 1) (- 0 2)')
		assert_equal -1, evaluate('^ (- 0 1) (- 0 3)')
	end

	it 'converts other values to integers' do
		assert_equal 225, evaluate('^ 15 "2"')
		assert_equal 1, evaluate('^ 91 FALSE')
		assert_equal 1, evaluate('^ 91 NULL')
		assert_equal 9, evaluate('^ 9 TRUE')
	end


	it 'evaluates arguments in order' do
		assert_equal 91125, evaluate('^ (= n 45) (- n 42)')
		assert_equal 15, evaluate('^ (= n 15) (- n 14)')
		assert_equal 0, evaluate('^ (= n 15) (- n 16)')
	end

	it 'does not allow 0 to be raised to a negative power', when_testing: :zero_division do
		assert_fails { evaluate('^ (- 0 1) 0') }
		assert_fails { evaluate('^ 100 0') }
		assert_fails { evaluate('^ 1 FALSE') }
		assert_fails { evaluate('^ 1 NULL') }
	end

	it 'only allows a number as the first operand', when_testing: :invalid_types do
		assert_fails { evaluate('^ TRUE 1') }
		assert_fails { evaluate('^ FALSE 1') }
		assert_fails { evaluate('^ NULL 1') }
		assert_fails { evaluate('^ "not-a-number" 1') }
		assert_fails { evaluate('^ "123" 1') } # ie a numeric string

		if testing? :strict_types
			assert_fails { evaluate('; = a 3 : ^ (BLOCK a) 1') }
			assert_fails { evaluate('^ (BLOCK QUIT 0) 1') }
		end
	end

	test_argument_count '^', '1', '2'
end
