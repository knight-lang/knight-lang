require_relative '../function-spec'

section '4.', 'Function' do
	include Kn::Test::Spec

	describe '4.3.1 +' do
		describe 'when the first arg is a string' do
			it 'concatenates' do
				assert_equal "1121a3", evaluate('+ "112" "1a3"')
				assert_equal "Plato Aristotle", evaluate('+ "Plato" " Aristotle"')
				assert_equal "Because why not?", evaluate('++ "Because " "why" " not?"')
			end

			it 'coerces to a string' do
				assert_equal 'truth is true', evaluate('+ "truth is " TRUE')
				assert_equal 'falsehood is false', evaluate('+ "falsehood is " FALLSE')
				assert_equal 'it is null and void', evaluate('++ "it is " NULL " and void"')
				assert_equal 'twelve is 12', evaluate('+ "twelve is " 12')
			end

			it 'can be used to coerce to a string when the lhs is empty' do
				assert_equal 'true', evaluate('+ "" TRUE')
				assert_equal 'false', evaluate('+ "" FALSE')
				assert_equal 'null', evaluate('+ "" NULL')
				assert_equal '1234', evaluate('+ "" 1234')
				assert_equal '-123', evaluate('+ "" (- 0 123)')
			end

 			# a bug from the c impl
			it 'does not reuse the same number buffer' do
				assert_equal '1234', evaluate('; = a + "" 12 ; = b + "" 34 : + a b')
			end
		end

		describe 'when the first arg is a number' do
			it 'adds other numbers' do
				assert_equal 0, evaluate('+ 0 0')
				assert_equal 3, evaluate('+ 1 2')
				assert_equal 10, evaluate('+ 4 6')
				assert_equal 111, evaluate('+ 112 (- 0 1)')

				assert_equal 17, evaluate('+ 4 13')
				assert_equal -9, evaluate('+ 4 (- 0 13)')
				assert_equal 9, evaluate('+ (- 0 4) 13')
				assert_equal -17, evaluate('+ (- 0 4) (- 0 13)')
			end

			it 'converts other values to numbers' do
				assert_equal 3, evaluate('+ 1 "2"')
				assert_equal 95, evaluate('+ 4 "91"')
				assert_equal 10, evaluate('+ 9 TRUE')
				assert_equal 9, evaluate('+ 9 FALSE')
				assert_equal 9, evaluate('+ 9 NULL')
			end

			it 'can be used to coerce to a number when the lhs is zero' do
				assert_equal 12, evaluate('+ 0 "12"')
				assert_equal 1, evaluate('+ 0 TRUE')
				assert_equal 0, evaluate('+ 0 FALSE')
				assert_equal 0, evaluate('+ 0 NULL')
			end

			it 'errors on overflow', when_testing: :overflow do
				fail "todo: overflow (need to get bit length)"
			end
		end

		it 'evaluates arguments in order' do
			assert_equal 48, evaluate('+ (= n 45) (- n 42)')
			assert_equal 16, evaluate('+ (= n 15) (- n 14)')
			assert_equal 14, evaluate('+ (= n 15) (- n 16)')
		end

		it 'only allows a number or string as the first operand', when_testing: :invalid_types do
			assert_fails { evaluate('+ TRUE 1') }
			assert_fails { evaluate('+ FALSE 1') }
			assert_fails { evaluate('+ NULL 1') }

			if testing? :strict_types
				assert_fails { evaluate('; = a 3 : + (BLOCK a) 1') }
				assert_fails { evaluate('+ (BLOCK QUIT 0) 1') }
			end
		end

		test_argument_count '+', '1', '2'
	end
end
