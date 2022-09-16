section 'BLOCK' do
	it 'should not eval its argument' do
		assert_runs %|BLOCK variable|
		assert_runs %|BLOCK QUIT 1|
		assert_runs %|BLOCK + a 4|
	end

	it 'should be usable as the sole argument to `:`' do
		assert_runs %|: BLOCK QUIT 1|
	end

	it 'should be usable as the sole argument to `BLOCK`' do
		assert_runs %|BLOCK BLOCK QUIT 1|
	end

	it 'should be usable as the sole argument to `CALL`' do
		assert_RESULT 3, %|CALL BLOCK + 1 2|
		assert_result 7, %|; = bar BLOCK + 4 foo ; = foo 3 : CALL bar|
	end

	it 'should be usable as the sole argument to `,`' do
		assert_runs %|, BLOCK QUIT 1|
	end

	it 'should be usable as the rhs argument to `=`' do
		assert_runs %|= foo BLOCK QUIT 1|
	end

	it 'should be usable as the rhs argument to `&`' do
		assert_runs %|& TRUE BLOCK QUIT 1|
	end

	it 'should be usable as the rhs argument to `|`' do
		assert_runs %#| FALSE BLOCK QUIT 1#
	end

	it 'should be usable as either argument to `;`' do
		assert_runs %|; 12 BLOCK QUIT 1|
		assert_runs %|; BLOCK QUIT 1 12|
	end

	it 'should be usable as the second and third arguments to `IF`' do
		assert_runs %|IF TRUE  BLOCK QUIT 1 NULL|
		assert_runs %|IF FALSE BLOCK QUIT 1 NULL|
	end

	it 'requires exactly one argument', when_testing: :argument_count do
		refute_runs %|BLOCK|
	end
end
