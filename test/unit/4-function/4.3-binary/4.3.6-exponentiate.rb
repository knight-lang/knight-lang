section '4.3.6', '^' do
	it 'raises positive numbers correctly' do
		assert_result 1, %|^ 1 1|
		assert_result 1, %|^ 1 100|
		assert_result 16, %|^ 2 4|
		assert_result 125, %|^ 5 3|
		assert_result 3375, %|^ 15 3|
		assert_result 15129, %|^ 123 2|
	end

	it 'returns 0 when the base is zero, unless the power is zero' do
		assert_result 0, %|^ 0 1|
		assert_result 0, %|^ 0 100|
		assert_result 0, %|^ 0 4|
		assert_result 0, %|^ 0 3|
	end

	it 'returns 1 when raising to the power of 0' do
		assert_result 1, %|^ 1 0|
		assert_result 1, %|^ 100 0|
		assert_result 1, %|^ 4 0|
		assert_result 1, %|^ 3 0|
		assert_result 1, %|^ ~3 0|
	end

	# Since we only have integral types, anything (normal) raised to a negative number is zero.
	it 'always returns zero when a > 1 number is raised to a negative power' do
		assert_result 0, %|^ 2 ~2|
		assert_result 0, %|^ 100 ~2|
		assert_result 0, %|^ 4 ~2|
		assert_result 0, %|^ 3 ~2|
		assert_result 0, %|^ ~3 ~2|
	end

	it 'returns a negative number when a negative number is raised ot an odd power' do
		assert_result -1, %|^ ~1 1|
		assert_result -8, %|^ ~2 3|
		assert_result 16, %|^ ~2 4|
		assert_result -32, %|^ ~2 5|
		assert_result 100, %|^ ~10 2|
		assert_result -1331, %|^ ~11 3|
		assert_result 20736, %|^ ~12 4|
	end

	it 'handles one, zero, and negative one properly' do
		assert_result 0, %|^ 0 3|
		assert_result 0, %|^ 0 2|
		assert_result 0, %|^ 0 1|
		assert_result 1, %|^ 0 0|
		# 0 to a negative power is undefined.

		assert_result 1, %|^ 1 3|
		assert_result 1, %|^ 1 2|
		assert_result 1, %|^ 1 1|
		assert_result 1, %|^ 1 0|
		assert_result 1, %|^ 1 ~1|
		assert_result 1, %|^ 1 ~2|
		assert_result 1, %|^ 1 ~3|

		assert_result -1, %|^ ~1 3|
		assert_result 1, %|^ ~1 2|
		assert_result -1, %|^ ~1 1|
		assert_result 1, %|^ ~1 0|
		assert_result -1, %|^ ~1 ~1|
		assert_result 1, %|^ ~1 ~2|
		assert_result -1, %|^ ~1 ~3|
	end

	it 'converts other values to integers' do
		assert_result 225, %|^ 15 "2"|
		assert_result 1, %|^ 91 FALSE|
		assert_result 1, %|^ 91 NULL|
		assert_result 9, %|^ 9 TRUE|
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

	it 'only allows a number as the first operand', when_testing: :invalid_types do
		refute_runs %|^ TRUE 1|
		refute_runs %|^ FALSE 1|
		refute_runs %|^ NULL 1|
		refute_runs %|^ "not-a-number" 1|
		refute_runs %|^ "123" 1| # ie a numeric string
	end

	it 'does not allow a function or variable as any operand', when_testing: :strict_types do
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
