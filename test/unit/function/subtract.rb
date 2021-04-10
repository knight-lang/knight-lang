require_relative '../../spec'

describe '4. Function' do
	include Kn::Test::Spec

	describe '4.3.2 -' do
		it 'adds numbers normally' do
			assert_equal 0, eval('- 0 0')
			assert_equal -1, eval('- 1 2')
			assert_equal -2, eval('- 4 6')
			assert_equal 113, eval('- 112 (- 0 1)')

			assert_equal -9, eval('- 4 13')
			assert_equal 17, eval('- 4 (- 0 13)')
			assert_equal -17, eval('- (- 0 4) 13')
			assert_equal 9, eval('- (- 0 4) (- 0 13)')
		end

		it 'converts other values to numbers' do
			assert_equal -1, eval('- 1 "2"')
			assert_equal -136, eval('- 91 "-45"')
			assert_equal 8, eval('- 9 TRUE')
			assert_equal 9, eval('- 9 FALSE')
			assert_equal 9, eval('- 9 NULL')
		end

		it 'evaluates arguments in order' do
			assert_equal 87, eval('- (= n 45) (- 3 n)')
			assert_equal 16, eval('- (= n 15) (- 14 n)')
			assert_equal 14, eval('- (= n 15) (- 16 n)')
		end

		it 'errors on overflow', when_testing: :overflow do
			fail "todo: overflow (need to get bit length)"
		end

		it 'only allows a number as the first operand', when_testing: :invalid_types do
			assert_fails { eval('- TRUE 1') }
			assert_fails { eval('- FALSE 1') }
			assert_fails { eval('- NULL 1') }
			assert_fails { eval('- "not-a-number" 1') }
			assert_fails { eval('- "123" 1') } # ie a numeric string

			if testing? :strict_types
				assert_fails { eval('; = a 3 : - (BLOCK a) 1') }
				assert_fails { eval('- (BLOCK QUIT 0) 1') }
			end
		end

		it 'requires exactly two arguments', when_testing: :argument_count do
			assert_fails { eval('-') }
			assert_fails { eval('- 1') }
			assert_runs  { eval('- 1 1') }
		end
	end
end
