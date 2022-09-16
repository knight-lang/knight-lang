section 'CALL' do
	it 'should run something returned by `BLOCK`' do
		assert_result 12, %|CALL BLOCK 12|
		assert_result '12', %|CALL BLOCK "12"|

		assert_result true, %|CALL BLOCK TRUE|
		assert_result false, %|CALL BLOCK FALSE|
		assert_result :null, %|CALL BLOCK NULL|

		assert_result 'twelve', %|; = foo BLOCK bar ; = bar "twelve" : CALL foo|
		assert_result 15, %|; = foo BLOCK * x 5 ; = x 3 : CALL foo|
	end

	it 'should _only_ eval BLOCK return values', when_testing: :strict_compliance do
		refute_runs %|CALL 1|
		refute_runs %|CALL "1"|
		refute_runs %|CALL TRUE|
		refute_runs %|CALL FALSE|
		refute_runs %|CALL NULL|
	end

	it 'requires exactly one argument', when_testing: :argument_count do
		refute_runs %|CALL|
		assert_runs %|CALL BLOCK + 1 2|
	end
end
