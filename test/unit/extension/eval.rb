return
section 'EVAL' do
	it 'evaluates text as Knight code' do
		assert_result 12, %|EVAL "12"|
		assert_result 46, %|EVAL "+ 12 34"|
		assert_result 8, %|EVAL "; = a 3 : + a 5"|
	end

	it 'converts values to a string' do
		assert_result 23, %|; = true 23 : EVAL TRUE|
		assert_result 23, %|; = false 23 : EVAL FALSE|
		assert_result 23, %|; = null 23 : EVAL NULL|
		assert_result 19, %|EVAL 19|
	end

	it 'updates the global scope' do
		assert_result 591, %|; EVAL "= foo 591" foo|
	end

	it 'can return a `CALL`able object' do
		assert_result 7, %|; = a EVAL "BLOCK + b 4" ; = b 3 : CALL a|
	end

	it 'will cause errors to propagate' do
		refute_runs %|EVAL "/ 1 0"| if sanitized? :zero_division
		refute_runs %|EVAL "+ NULL 0"| if sanitized? :invalid_types
		refute_runs %|; = a 3 : EVAL "+ BLOCK a 0"| if sanitized? :strict_types
		refute_runs %|EVAL "+ 1"| if sanitized? :argument_count
		# TODO: test overflow
		refute_runs %|EVAL "* "a" ~1"| if sanitized? :invalid_values
		refute_runs %|EVAL "a"| if sanitized? :undefined_variables
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
