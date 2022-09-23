require_relative '../../shared'

section 'QUIT' do
	before do
		def exitstatus(expr)
			# exit codes shouldn't print anything.
			assert_silent do
				tester.execute expr, raise_on_failure: false
			end

			$?.exitstatus
		end
	end

	it 'must quit the process with the given return value' do
		assert_equal 0, exitstatus(%|QUIT 0|)
		assert_equal 1, exitstatus(%|QUIT 1|)
		assert_equal 2, exitstatus(%|QUIT 2|)
		assert_equal 10, exitstatus(%|QUIT 10|)
		assert_equal 49, exitstatus(%|QUIT 49|)
		assert_equal 123, exitstatus(%|QUIT 123|)
		assert_equal 126, exitstatus(%|QUIT 126|)
		assert_equal 127, exitstatus(%|QUIT 127|)
	end

	it 'must convert to an integer' do
		assert_equal 12, exitstatus(%|QUIT "12"|)

		# these are slightly counterintuitive, as `QUIT TRUE` will exit with 1, indicating failure.
		assert_equal 1, exitstatus(%|QUIT TRUE|)
		assert_equal 0, exitstatus(%|QUIT FALSE|)
		assert_equal 0, exitstatus(%|QUIT NULL|)
		assert_equal 0, exitstatus(%|QUIT @|)
		assert_equal 1, exitstatus(%|QUIT ,123|)
	end

	it 'requires exactly one argument', when_testing: :argument_count do
		refute_runs %|QUIT|
		assert_runs %|QUIT 0|
	end

	it 'does not allow blocks as the first operand', when_testing: :strict_types do
		refute_runs %|; = a 0 : QUIT BLOCK a|
		refute_runs %|QUIT BLOCK QUIT 0|
	end
end
