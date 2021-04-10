describe '4.2.5 `' do
	include Kn::Test::Spec

	it 'should return the stdout of the subshell' do
		assert_equal "and then there was -1\n", eval(%q|` 'echo "and then there was -1"'|)
		assert_equal "line1\nline2\nline3", eval(%q|` "printf 'line1\nline2\nline3'"|)
	end

	it 'should return an empty string with no output' do
		assert_equal '', eval('` "exit 0"')
	end

	it 'should convert its argument to a string' do
		assert_equal '', eval('` TRUE')

		# `false` has a nonzero exit status, which the standard doesn't require us to handle.
		assert_fails { eval('` FALSE') } if testing? :io_errors

		# numbers and NULL aren't likely to be valid programs, so we shouldn't test em.
	end

	it 'aborts on a non-zero exit status', when_testing: :io_errors do
		assert_fails { eval('` exit 1') } 
	end

	it 'requires exactly one argument', when_testing: :argument_count do
		assert_fails { eval('`') }
		assert_runs  { eval('` "exit 0"') }
	end

	it 'does not allow blocks as the first operand', when_testing: :strict_types do
		assert_fails { eval('; = a "exit 0" : ` BLOCK a') }
		assert_fails { eval('` BLOCK QUIT 0') }
	end
end
