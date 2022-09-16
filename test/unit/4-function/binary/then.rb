section ';' do
	it 'executes arguments in order' do
		assert_result 3, %|; (= a 3) a|
	end

	it 'returns the second argument' do
		assert_result 1, %|; 0 1|
	end

	it 'also works with BLOCK return values' do
		assert_result 3, %|CALL ; = a 3 BLOCK a|
	end

	it 'accepts blocks as either argument' do
		assert_result 3, %|; (BLOCK QUIT 1) 3|
		assert_result 4, %|CALL ; 3 (BLOCK 4)|
	end

	it 'requires exactly two arguments', when_testing: :argument_count do
		refute_runs %|;|
		refute_runs %|; 1|
		assert_runs %|; 1 1|
	end
end
