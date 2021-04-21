require_relative '../function-spec'

section '4.3.5', '%' do
	include Kn::Test::Spec

	it 'modulos positive numbers normally' do
		assert_equal 0, evaluate('% 1 1')
		assert_equal 0, evaluate('% 4 4')
		assert_equal 0, evaluate('% 15 1')
		assert_equal 3, evaluate('% 123 10')
		assert_equal 0, evaluate('% 15 3')
	end

	it 'converts other values to integers' do
		assert_equal 1, evaluate('% 15 "2"')
		assert_equal 3, evaluate('% 91 "4"')
		assert_equal 0, evaluate('% 9 TRUE')
	end

	it 'evaluates arguments in order' do
		assert_equal 5, evaluate('% (= n 45) (- n 35)')
		assert_equal 7, evaluate('% (= n 17) (- n 7)')
		assert_equal 4, evaluate('% (= n 15) (- n 4)')
	end

	it 'does not modulo by zero', when_testing: :zero_division do
		assert_fails { evaluate('% 1 0') }
		assert_fails { evaluate('% 100 0') }
		assert_fails { evaluate('% 1 FALSE') }
		assert_fails { evaluate('% 1 NULL') }
	end

	# note that, as per the Knight spec, modulo where either number is negative is undefined.
	it 'does not allow for negative numbers anywhere', when_testing: :invalid_values do
		assert_fails { evaluate('% 1 (- 0 1)') }
		assert_fails { evaluate('% (- 0 1) 1') }
		assert_fails { evaluate('% (- 0 1) (- 0 1)') }
	end

	it 'only allows a number as the first operand', when_testing: :invalid_types do
		assert_fails { evaluate('% TRUE 1') }
		assert_fails { evaluate('% FALSE 1') }
		assert_fails { evaluate('% NULL 1') }
		assert_fails { evaluate('% "not-a-number" 1') }
		assert_fails { evaluate('% "123" 1') } # ie a numeric string

		if testing? :strict_types
			assert_fails { evaluate('; = a 3 : % (BLOCK a) 1') }
			assert_fails { evaluate('% (BLOCK QUIT 0) 1') }
		end
	end

	test_argument_count '%', '1', '2'
end
