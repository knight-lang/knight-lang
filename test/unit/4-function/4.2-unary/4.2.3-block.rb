section '4.2.3', 'BLOCK' do
	it 'should not eval its argument' do
		assert_runs %|BLOCK variable|
		assert_runs %|BLOCK QUIT 1|
		assert_runs %|BLOCK + a 4|
	end

	it 'should be usable as the rhs argument to `=`' do
		assert_runs %|= foo BLOCK QUIT 1|
	end

	it 'should be usable as the sole argument to `:`' do
		assert_runs %|: BLOCK QUIT 1|
	end

	it 'should be usable as either argument to `;`' do
		assert_runs %|; 12 BLOCK QUIT 1|
		assert_runs %|; BLOCK QUIT 1 12|
	end

	it 'should be usable as the sole argument of CALL' do
		assert_result 12, %|CALL BLOCK 12|
		assert_result 7, %|; = bar BLOCK + 4 foo ; = foo 3 : CALL bar'|
	end

	it 'requires exactly one argument', when_testing: :argument_count do
		refute_runs %|BLOCK|
		assert_runs %|BLOCK + 1 2|
	end

	# TODO: is `BLOCK BLOCK` valid?
end
