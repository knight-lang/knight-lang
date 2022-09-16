section '&' do
	it 'returns the lhs if its falsey' do
		assert_result 0, %|& 0 QUIT 1|
		assert_result false, %|& FALSE QUIT 1|
		assert_result :null, %|& NULL QUIT 1|
		assert_result '', %|& "" QUIT 1|
	end

	it 'executes the rhs only if the lhs is truthy' do
		assert_result 1, %|; & 1 (= a 1) a|
		assert_result 2, %|; & TRUE (= a 2) a|
		assert_result 3, %|; & "hi" (= a 3) a|
		assert_result 4, %|; & "0" (= a 4) a|
		assert_result 5, %|; & "NaN" (= a 5) a|
	end

	it 'works with BLOCK for the second argument' do
		assert_result 3, %|; = a 3 : CALL & 1 BLOCK a|
		assert_result 5, %|; = a 3 : CALL & 1 BLOCK + a 2|
	end

	it 'does not accept BLOCK values for the first arg', when_testing: :strict_types do
		refute_runs %|; = a 3 : & (BLOCK a) 1|
		refute_runs %|& (BLOCK QUIT 0) 1|
	end

	it 'requires exactly two arguments', when_testing: :argument_count do
		refute_runs %|&|
		refute_runs %|& 1|
		assert_runs %|& 1 1|
	end
end
