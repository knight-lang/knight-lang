section '4.2.1', ':' do
	it 'simply returns its argument' do
		assert_result 4, %|: 4|
		assert_result 'hi', %|: "hi"|
		assert_result true, %|: TRUE|
		assert_result false, %|: FALSE|
		assert_result :null, %|: NULL|
	end

	it 'also works with BLOCK return values' do
		assert_result 3, %|; = a 3 CALL : BLOCK a |
		assert_result 5, %|; = a 3 CALL : BLOCK + a 2|
	end

	it 'requires exactly one argument', when_testing: :argument_count do
		refute_runs %|:|
		assert_runs %|: 1|
	end
end
