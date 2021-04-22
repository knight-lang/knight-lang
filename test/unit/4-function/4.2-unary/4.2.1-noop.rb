section '4.2.1', ':' do
	it 'simply returns its argument' do
		assert_run_equal 4, %|: 4|
		assert_run_equal 'hi', %|: "hi"|
		assert_run_equal true, %|: TRUE|
		assert_run_equal false, %|: FALSE|
		assert_run_equal :null, %|: NULL|
	end

	it 'also works with BLOCK return values' do
		assert_run_equal 3, %|; = a 3 CALL : BLOCK a |
		assert_run_equal 5, %|; = a 3 CALL : BLOCK + a 2|
	end

	it 'requires exactly one argument', when_testing: :argument_count do
		refute_runs %|:|
		assert_runs %|: 1|
	end
end
