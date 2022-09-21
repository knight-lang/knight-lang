require_relative '../../shared'

section '^' do
	describe 'when the first argument is an integer' do
		it 'raises positive integers correctly' do
			assert_result 1, %|^ 1 1|
			assert_result 1, %|^ 1 100|
			assert_result 16, %|^ 2 4|
			assert_result 125, %|^ 5 3|
			assert_result 3375, %|^ 15 3|
			assert_result 15129, %|^ 123 2|
		end

		it 'raises negative positive integers correctly' do
			assert_result -1, %|^ ~1 1|
			assert_result  1, %|^ ~1 2|
			assert_result -1, %|^ ~1 3|
			assert_result  1, %|^ ~1 4|
			assert_result 1, %|^ ~1 100|

			assert_result 16, %|^ ~2 4|
			assert_result -32, %|^ ~2 5|

			assert_result -125, %|^ ~5 3|
			assert_result 625, %|^ ~5 4|

			assert_result -3375, %|^ ~15 3|
			assert_result 50625, %|^ ~15 4|

			assert_result 15129, %|^ ~123 2|
			assert_result -1860867, %|^ ~123 3|
		end

		it 'always returns 1 for exponents of 0' do
			assert_result 1, %|^ 0 0|

			assert_result 1, %|^ 1 0|
			assert_result 1, %|^ 1 0|
			assert_result 1, %|^ 2 0|
			assert_result 1, %|^ 5 0|
			assert_result 1, %|^ 15 0|
			assert_result 1, %|^ 123 0|

			assert_result 1, %|^ ~1 0|
			assert_result 1, %|^ ~1 0|
			assert_result 1, %|^ ~2 0|
			assert_result 1, %|^ ~5 0|
			assert_result 1, %|^ ~15 0|
			assert_result 1, %|^ ~123 0|
		end

		it 'returns 0 when the base is zero, unless the power is zero' do
			assert_result 0, %|^ 0 1|
			assert_result 0, %|^ 0 100|
			assert_result 0, %|^ 0 4|
			assert_result 0, %|^ 0 3|
		end

		it 'converts other values to integers' do
			assert_result 225, %|^ 15 "2"|
			assert_result 1, %|^ 91 FALSE|
			assert_result 1, %|^ 91 NULL|
			assert_result 9, %|^ 9 TRUE|
			assert_result 729, %|^ 9 +@123|
		end
	end

	describe 'when the first argument is a list' do
		it 'returns an empty string for empty lists' do
			assert_result '', %|^ @ ''|
			assert_result '', %|^ @ 'hello'|
			assert_result '', %|^ @ TRUE|
			assert_result '', %|^ @ 1234|
		end

		it 'returns the stringification of its element for one-length lists' do
			assert_result 'hello', %|^ ,"hello" ''|
			assert_result '123', %|^ ,123 ''|
			assert_result 'true', %|^ ,,,,TRUE ''|
			assert_result '', %|^ ,@ ''|
			assert_result '45', %|^ ,,,,,,45 ''|
		end

		it 'returns the list joined by the second argument' do
			assert_result '1-2-3', %|^ +@123 '-'|
			assert_result "4\n5\n6\n7", %|^ +@4567 '\n'|
			assert_result 'a' + ("XXa"*99), %|^ *'a' 100 'XX'|
			assert_result 'ab'*100, %|^ *'ab' 100 ''|
		end

		it 'coerces the second argument to a string' do
			assert_result '10203', %|^ +@123 0|
			assert_result "4true5true6true6", %|^ +@4567 TRUE|
			assert_result 'a' + ("XXa"*99), %|^ *'a' 100 ,'XX'|
			assert_result 'ab'*100, %|^ *'ab' 100 NULL|
			assert_result 'ab'*100, %|^ *'ab' 100 @|
		end
	end

	it 'evaluates arguments in order' do
		assert_result 91125, %|^ (= n 45) (- n 42)|
		assert_result 15, %|^ (= n 15) (- n 14)|
		assert_result 0, %|^ (= n 15) (- n 16)|
	end

	it 'does not allow 0 to be raised to a negative power', when_testing: :zero_division do
		refute_runs %|^ 0 ~1|
		refute_runs %|^ 0 ~2|
		refute_runs %|^ 0 ~12|
	end

	it 'only allows an integer or list as the first operand', when_testing: :invalid_types do
		refute_runs %|^ TRUE 1|
		refute_runs %|^ FALSE 1|
		refute_runs %|^ NULL 1|
		refute_runs %|^ "not-a-integer" 1|
		refute_runs %|^ "123" 1| # ie a numeric string
	end

	it 'does not allow a block as any operand', when_testing: :strict_types do
		refute_runs %|; = a 3 : ^ (BLOCK a) 1|
		refute_runs %|; = a 3 : ^ 1 (BLOCK a)|
		refute_runs %|^ (BLOCK QUIT 0) 1|
		refute_runs %|^ 1 (BLOCK QUIT 0)|
	end

	it 'requires exactly two arguments', when_testing: :argument_count do
		refute_runs %|^|
		refute_runs %|^ 1|
		assert_runs %|^ 1 1|
	end
end
