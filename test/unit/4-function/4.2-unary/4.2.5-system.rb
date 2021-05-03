section '4.2.5', '`' do
	it 'should return the stdout of the subshell' do
		assert_result "line1\nline2\nline3", %q|` "printf 'line1\nline2\nline3'"|
		assert_result "and then there was -1\n", %q|` 'echo "and then there was -1"'|
	end

	it 'should return an empty string with no output' do
		assert_result '', %|` "exit 0"|
	end

	it "should ensure that the child process's stdin is inherited" do
		# todo
	end

	it 'should convert its argument to a string' do
		assert_result '', %|` TRUE|

		# `false` has a nonzero exit status, which the standard doesn't require us to handle.
		refute_runs %|` FALSE| if sanitized? :io_errors

		# numbers and NULL aren't likely to be valid programs, so we won't test em.
	end

	it 'should inherit stdin' do
		# todo
	end

	it 'aborts on a non-zero exit status', when_testing: :io_errors do
		refute_runs %|` exit 1|
	end

	it 'requires exactly one argument', when_testing: :argument_count do
		refute_runs %|`|
		assert_runs %|` "exit 0"|
	end

	it 'does not allow blocks as the first operand', when_testing: :strict_types do
		refute_runs %|; = a "exit 0" : ` BLOCK a|
		refute_runs %|` BLOCK QUIT 0|
	end
end
