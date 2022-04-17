section '4.3.4', '/' do
	it 'divides nonzero numbers normally' do
		assert_result 1, %|/ 1 1|
		assert_result 5, %|/ 10 2|
		assert_result -5, %|/ ~10 2|
		assert_result -10, %|/ 40 ~4|
		assert_result 20, %|/ ~80 ~4|

		assert_result 3, %|/ 13 4|
		assert_result -3, %|/ 13 ~4|
		assert_result -3, %|/ ~13 4|
		assert_result 3, %|/ ~13 ~4|
	end

	it 'rounds downwards' do
		assert_result 0, %|/ 4 5|
		assert_result 2, %|/ 10 4|
		assert_result -1, %|/ ~5 3|
		assert_result -2, %|/ ~7 3|
	end

	it 'evaluates arguments in order' do
		assert_result 15, %|/ (= n 45) (- n 42)|
		assert_result 15, %|/ (= n 15) (- n 14)|
		assert_result -15, %|/ (= n 15) (- n 16)|
	end

	it 'converts other values to integers' do
		assert_result 7, %|/ 15 "2"|
		assert_result 22, %|/ 91 "4"|
		assert_result 9, %|/ 9 TRUE|
	end

	# Note that there's no way to overflow with division, as we only have integers.

	it 'does not divide by zero', when_testing: :zero_division do
		refute_runs %|/ ~1 0|
		refute_runs %|/ 100 0|
		refute_runs %|/ 1 FALSE|
		refute_runs %|/ 1 NULL|
	end

	it 'only allows a number as the first operand', when_testing: :invalid_types do
		refute_runs %|/ TRUE 1|
		refute_runs %|/ FALSE 1|
		refute_runs %|/ NULL 1|
		refute_runs %|/ "not-a-number" 1|
		refute_runs %|/ "123" 1| # ie a numeric string
	end

	it 'does not allow a function or variable as any operand', when_testing: :strict_types do
		refute_runs %|; = a 3 : / (BLOCK a) 1|
		refute_runs %|; = a 3 : / 1 (BLOCK a)|
		refute_runs %|/ (BLOCK QUIT 0) 1|
		refute_runs %|/ 1 (BLOCK QUIT 0)|
	end

	it 'requires exactly two arguments', when_testing: :argument_count do
		refute_runs %|/|
		refute_runs %|/ 1|
		assert_runs %|/ 1 1|
	end
end
