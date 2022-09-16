require_relative '../shared'

# Note that `DUMP`'s normal cases are tested by running unit tests, so no need to actually check here.
section 'DUMP' do
	it 'requires exactly one argument', when_testing: :argument_count do
		refute_runs %|DUMP|
		assert_runs %|DUMP "1"|
	end
end
