section '-' do
	it 'subtracts integers normally' do
		assert_result 0, %|- 0 0|
		assert_result -1, %|- 1 2|
		assert_result -2, %|- 4 6|
		assert_result 113, %|- 112 ~1|

		assert_result -9, %|- 4 13|
		assert_result 17, %|- 4 ~13|
		assert_result -17, %|- ~4 13|
		assert_result 9, %|- ~4 ~13|
	end

	it 'converts other values to integers' do
		assert_result -1, %|- 1 "2"|
		assert_result 46, %|- 91 "45"|
		assert_result 8, %|- 9 TRUE|
		assert_result 9, %|- 9 FALSE|
		assert_result 9, %|- 9 NULL|
		assert_result 6, %|- 9 +@145|
	end

	it 'evaluates arguments in order' do
		assert_result 87, %|- (= n 45) (- 3 n)|
		assert_result 16, %|- (= n 15) (- 14 n)|
		assert_result 14, %|- (= n 15) (- 16 n)|
	end

	it 'errors on overflow', when_testing: :overflow do
		fail "todo: overflow (need to get bit length)"
	end

	it 'only allows an integer as the first operand', when_testing: :invalid_types do
		refute_runs %|- TRUE 1|
		refute_runs %|- FALSE 1|
		refute_runs %|- NULL 1|
		refute_runs %|- "not-a-integer" 1|
		refute_runs %|- "123" 1| # ie a numeric string
		refute_runs %|- @ 1|
	end

	it 'does not allow a block as any operand', when_testing: :strict_types do
		refute_runs %|; = a 3 : - (BLOCK a) 1|
		refute_runs %|; = a 3 : - 1 (BLOCK a)|
		refute_runs %|- (BLOCK QUIT 0) 1|
		refute_runs %|- 1 (BLOCK QUIT 0)|
	end

	it 'requires exactly two arguments', when_testing: :argument_count do
		refute_runs %|-|
		refute_runs %|- 1|
		assert_runs %|- 1 1|
	end
end
