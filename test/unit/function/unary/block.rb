require_relative '../shared'

section 'BLOCK' do
	it 'should not eval its argument' do
		assert_runs %|BLOCK variable|
		assert_runs %|BLOCK QUIT 1|
		assert_runs %|BLOCK + a 4|
	end

	it 'requires exactly one argument', when_testing: :argument_count do
		refute_runs %|BLOCK|
		assert_runs %|BLOCK 1|
	end
end
