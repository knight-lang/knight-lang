require_relative '../function-spec'

section '4.3.2', '-' do
	it 'adds numbers normally' do
		assert_equal 0, evaluate('- 0 0')
		assert_equal -1, evaluate('- 1 2')
		assert_equal -2, evaluate('- 4 6')
		assert_equal 113, evaluate('- 112 (- 0 1)')

		assert_equal -9, evaluate('- 4 13')
		assert_equal 17, evaluate('- 4 (- 0 13)')
		assert_equal -17, evaluate('- (- 0 4) 13')
		assert_equal 9, evaluate('- (- 0 4) (- 0 13)')
	end

	it 'converts other values to numbers' do
		assert_equal -1, evaluate('- 1 "2"')
		assert_equal -136, evaluate('- 91 "-45"')
		assert_equal 8, evaluate('- 9 TRUE')
		assert_equal 9, evaluate('- 9 FALSE')
		assert_equal 9, evaluate('- 9 NULL')
	end

	it 'evaluates arguments in order' do
		assert_equal 87, evaluate('- (= n 45) (- 3 n)')
		assert_equal 16, evaluate('- (= n 15) (- 14 n)')
		assert_equal 14, evaluate('- (= n 15) (- 16 n)')
	end

	it 'errors on overflow', when_testing: :overflow do
		fail "todo: overflow (need to get bit length)"
	end

	it 'only allows a number as the first operand', when_testing: :invalid_types do
		assert_fails { evaluate('- TRUE 1') }
		assert_fails { evaluate('- FALSE 1') }
		assert_fails { evaluate('- NULL 1') }
		assert_fails { evaluate('- "not-a-number" 1') }
		assert_fails { evaluate('- "123" 1') } # ie a numeric string

		if testing? :strict_types
			assert_fails { evaluate('; = a 3 : - (BLOCK a) 1') }
			assert_fails { evaluate('- (BLOCK QUIT 0) 1') }
		end
	end

	test_argument_count '-', '1', '2'
end
