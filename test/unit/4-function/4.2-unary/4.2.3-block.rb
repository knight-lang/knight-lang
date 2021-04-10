require_relative '../function-spec'

section '4.2.3', 'BLOCK' do
	include Kn::Test::Spec

	it 'should not evaluate its argument' do
		assert_runs { 'BLOCK variable' }
		assert_runs { 'BLOCK QUIT 1' }
		assert_runs { 'BLOCK + a 4' }
	end

	it 'should be usable as the rhs argument to `=`' do
		assert_runs { '= foo BLOCK QUIT 1' }
	end

	it 'should be usable as the sole argument to `:`' do
		assert_runs { ': BLOCK QUIT 1' }
	end

	it 'should be usable as either argument to `;`' do
		assert_runs { '; 12 BLOCK QUIT 1' }
		assert_runs { '; BLOCK QUIT 1 12' }
	end

	it 'should be usable as the sole argument of CALL' do
		assert_equal 12, eval('CALL BLOCK 12')
		assert_equal 3, eval('; = bar BLOCK + 4 foo ; = foo 3 : CALL bar')
	end

	test_argument_count 'BLOCK', '1'

	# TODO: is `BLOCK BLOCK` valid?
end
