section '4.3.3', '*' do
	describe 'when the first arg is a string' do
		it 'duplicates itself with positive integers' do
			assert_result '', %|* "" 12|
			assert_result 'foo', %|* "foo" 1|
			assert_result 'a1a1a1a1', %|* "a1" 4|
			assert_result 'haihaihaihaihaihaihaihai', %|* "hai" 8|
		end

		it 'returns an empty string when multiplied by zero' do
			assert_result '', %|* "hi" 0|
			assert_result '', %|* "what up?" 0|
		end

		it 'coerces the RHS to a number' do
			assert_result 'foofoofoo', %|* "foo" "3"|
			assert_result 'foo', %|* "foo" TRUE|
			assert_result '', %|* "foo" NULL|
			assert_result '', %|* "foo" FALSE|
		end

		it 'only allows for a nonnegative duplication amount', when_testing: :invalid_values do
			refute_runs %|* "hello" (- 0 1)|
			refute_runs %|* "hello" (- 0 4)|
			refute_runs %|* "" (- 0 4)|
			refute_runs %|* "1" (- 0 4)|
		end
	end

	describe 'when the first arg is a number' do
		it 'works with integers' do
			assert_result 0, %|* 0 0|
			assert_result 2, %|* 1 2|
			assert_result 24, %|* 4 6|
			assert_result -36, %|* 12 (- 0 3)|

			assert_result 52, %|* 4 13|
			assert_result -52, %|* 4 (- 0 13)|
			assert_result -52, %|* (- 0 4) 13|
			assert_result 52, %|* (- 0 4) (- 0 13)|
		end

		it 'converts other values to integers' do
			assert_result -2, %|* 1 "-2"|
			assert_result 364, %|* 91 "4"|
			assert_result 9, %|* 9 TRUE|
			assert_result 0, %|* 9 FALSE|
			assert_result 0, %|* 9 NULL|
		end

		it 'errors on overflow', when_testing: :overflow do
			fail "todo: overflow (need to get bit length)"
		end
	end

	it 'evaluates arguments in order' do
		assert_result 135, %|* (= n 45) (- n 42)|
		assert_result 15, %|* (= n 15) (- n 14)|
		assert_result -15, %|* (= n 15) (- n 16)|
	end

	it 'only allows a number or string as the first operand', when_testing: :invalid_types do
		refute_runs %|* TRUE 1|
		refute_runs %|* FALSE 1|
		refute_runs %|* NULL 1|
	end

	it 'does not allow a function or variable as any operand', when_testing: :strict_types do
		refute_runs %|; = a 3 : * (BLOCK a) 1|
		refute_runs %|; = a 3 : * 1 (BLOCK a)|
		refute_runs %|* (BLOCK QUIT 0) 1|
		refute_runs %|* 1 (BLOCK QUIT 0)|
	end

	it 'requires exactly two arguments', when_testing: :argument_count do
		refute_runs %|*|
		refute_runs %|* 1|
		assert_runs %|* 1 1|
	end
end
