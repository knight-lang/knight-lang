# Note that `DUMP`'s normal cases are tested by running unit tests.
section '4.2.9', 'DUMP' do
	it 'requires exactly one argument', when_testing: :argument_count do
		refute_runs %|DUMP|
		assert_runs %|DUMP "1"|
	end
end
