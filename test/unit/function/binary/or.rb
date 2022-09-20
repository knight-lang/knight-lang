require_relative '../shared'

section '|' do
	it 'returns the lhs if its truthy' do
		assert_result 1, %(| 1 QUIT 1)
		assert_result 2, %(| 2 QUIT 1)
		assert_result true, %(| TRUE QUIT 1)
		assert_result 'hi', %(| "hi" QUIT 1)
		assert_result '0', %(| "0" QUIT 1)
		assert_result 'NaN', %(| "NaN" QUIT 1)
		assert_result [1], %(| ,1 QUIT 1)
	end

	it 'executes the rhs only if the lhs is falsey' do
		assert_result 1, %(; | 0 (= a 1) a)
		assert_result 2, %(; | FALSE (= a 2) a)
		assert_result 3, %(; | NULL (= a 3) a)
		assert_result 4, %(; | "" (= a 4) a)
		assert_result 5, %(; | @ (= a 4) a)
	end

	it 'works with BLOCK for the second argument' do
		assert_result 3, %(; = a 3 : CALL | 0 BLOCK a)
		assert_result 5, %(; = a 3 : CALL | 0 BLOCK + a 2)
	end

	it 'does not accept BLOCK values for the first arg', when_testing: :strict_types do
		refute_runs %(; = a 3 : | (BLOCK a) 1)
		refute_runs %(| (BLOCK QUIT 0) 1)
	end

	it 'requires exactly two arguments', when_testing: :argument_count do
		refute_runs %(|)
		refute_runs %(| 1)
		assert_runs %(| 1 1)
	end
end
