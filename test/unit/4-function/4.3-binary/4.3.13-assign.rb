# See `unit/3-variable` for more unit tests with variables specifically
section '4.3.13', '=' do
	it 'assigns to variables' do
		assert_result 12, %|; = a 12 : a|
	end

	it 'returns its given value' do
		assert_result 12, %|= a 12|
	end

	it 'only accepts a variable as the first argument', when_testing: :invalid_types do
		refute_runs %|= 1 1|
		refute_runs %|= "foo" 1|
		refute_runs %|= TRUE 1|
		refute_runs %|= FALSE 1|
		refute_runs %|= NULL 1|
	end

	it 'does not accept BLOCK values for the first arg', when_testing: :strict_types do
		refute_runs %|; = a 3 : = (BLOCK a) 1|
		refute_runs %|= (BLOCK QUIT 0) 1|
	end

	it 'requires exactly two arguments', when_testing: :argument_count do
		refute_runs %|=|
		refute_runs %|= a|
		assert_runs %|= a 1|
	end
end
