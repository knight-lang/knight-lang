section '4.2.2', 'EVAL' do
	it 'evaluates text as Knight code' do
		assert_run_equal 12, %|EVAL "12"|
		assert_run_equal 46, %|EVAL "+ 12 34"|
		assert_run_equal 8, %|EVAL "; = a 3 : + a 5"|
	end

	it 'converts values to a string' do
		assert_run_equal 23, %|; = true 23 : EVAL TRUE|
		assert_run_equal 23, %|; = false 23 : EVAL FALSE|
		assert_run_equal 23, %|; = null 23 : EVAL NULL|
		assert_run_equal 19, %|EVAL 19|
	end

	it 'updates the global scope' do
		assert_run_equal 591, %|; EVAL "= foo 591" foo|
	end

	it 'can return a `CALL`able object' do
		assert_run_equal 7, %|; = a EVAL "BLOCK + b 4" ; = b 3 : CALL a|
	end

	it 'will cause errors to propagate' do
		refute_runs %|EVAL "/ 1 0"| if testing? :zero_division
		refute_runs %|EVAL "+ NULL 0"| if testing? :invalid_types
		refute_runs %|; = a 3 : EVAL "+ BLOCK a 0"| if testing? :strict_types
		refute_runs %|EVAL "+ 1"| if testing? :argument_count
		# TODO: test overflow
		refute_runs %|EVAL "* "a" (- 0 1)"| if testing? :invalid_values
		refute_runs %|EVAL "a"| if testing? :undefined_variables
	end

	it 'requires exactly one argument', when_testing: :argument_count do
		refute_runs %|EVAL|
		assert_runs %|EVAL "1"|
	end

	it 'does not allow blocks as the first operand', when_testing: :strict_types do
		refute_runs %|; = a "3" : EVAL BLOCK a|
		refute_runs %|EVAL BLOCK QUIT 0|
	end
end
