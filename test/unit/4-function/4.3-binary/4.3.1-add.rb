describe '4. Function' do
	include Kn::Test::Spec

	describe '4.3.1 +' do
		describe 'when the first arg is a string' do
			it 'concatenates' do
				assert_equal "1121a3", eval('+ "112" "1a3"')
				assert_equal "Plato Aristotle", eval('+ "Plato" " Aristotle"')
				assert_equal "Because why not?", eval('++ "Because " "why" " not?"')
			end

			it 'coerces to a string' do
				assert_equal 'truth is true', eval('+ "truth is " TRUE')
				assert_equal 'falsehood is false', eval('+ "falsehood is " FALLSE')
				assert_equal 'it is null and void', eval('++ "it is " NULL " and void"')
				assert_equal 'twelve is 12', eval('+ "twelve is " 12')
			end

			it 'can be used to coerce to a string when the lhs is empty' do
				assert_equal 'true', eval('+ "" TRUE')
				assert_equal 'false', eval('+ "" FALSE')
				assert_equal 'null', eval('+ "" NULL')
				assert_equal '1234', eval('+ "" 1234')
				assert_equal '-123', eval('+ "" (- 0 123)')
			end

 			# a bug from the c impl
			it 'does not reuse the same number buffer' do
				assert_equal '1234', eval('; = a + "" 12 ; = b + "" 34 : + a b')
			end
		end

		describe 'when the first arg is a number' do
			it 'adds other numbers' do
				assert_equal 0, eval('+ 0 0')
				assert_equal 3, eval('+ 1 2')
				assert_equal 10, eval('+ 4 6')
				assert_equal 111, eval('+ 112 (- 0 1)')

				assert_equal 17, eval('+ 4 13')
				assert_equal -9, eval('+ 4 (- 0 13)')
				assert_equal 9, eval('+ (- 0 4) 13')
				assert_equal -17, eval('+ (- 0 4) (- 0 13)')
			end

			it 'converts other values to numbers' do
				assert_equal 3, eval('+ 1 "2"')
				assert_equal 95, eval('+ 4 "91"')
				assert_equal 10, eval('+ 9 TRUE')
				assert_equal 9, eval('+ 9 FALSE')
				assert_equal 9, eval('+ 9 NULL')
			end

			it 'can be used to coerce to a number when the lhs is zero' do
				assert_equal 12, eval('+ 0 "12"')
				assert_equal 1, eval('+ 0 TRUE')
				assert_equal 0, eval('+ 0 FALSE')
				assert_equal 0, eval('+ 0 NULL')
			end

			it 'errors on overflow', when_testing: :overflow do
				fail "todo: overflow (need to get bit length)"
			end
		end

		it 'evaluates arguments in order' do
			assert_equal 48, eval('+ (= n 45) (- n 42)')
			assert_equal 16, eval('+ (= n 15) (- n 14)')
			assert_equal 14, eval('+ (= n 15) (- n 16)')
		end

		it 'only allows a number or string as the first operand', when_testing: :invalid_types do
			assert_fails { eval('+ TRUE 1') }
			assert_fails { eval('+ FALSE 1') }
			assert_fails { eval('+ NULL 1') }

			if testing? :strict_types
				assert_fails { eval('; = a 3 : + (BLOCK a) 1') }
				assert_fails { eval('+ (BLOCK QUIT 0) 1') }
			end
		end

		it 'requires exactly two arguments', when_testing: :argument_count do
			assert_fails { eval('+') }
			assert_fails { eval('+ 1') }
			assert_fails { eval('+ "1"') }
			assert_runs  { eval('+ 1 1') }
			assert_runs  { eval('+ "1" 1') }
		end
	end
end