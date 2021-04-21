require_relative '../function-spec'

section '4.2.2', 'evaluate' do
	include Kn::Test::Spec

	it 'evaluates text as Knight code' do
		assert_equal 12, evaluate('evaluate "12"')
		assert_equal 46, evaluate('evaluate "+ 12 34"')
		assert_equal 8, evaluate('evaluate "; = a 3 : + a 5"')
	end

	it 'converts values to a string' do
		assert_equal 23, evaluate('; = true 23 : evaluate TRUE')
		assert_equal 23, evaluate('; = false 23 : evaluate FALSE')
		assert_equal 23, evaluate('; = null 23 : evaluate NULL')
		assert_equal 19, evaluate('evaluate 19')
	end

	it 'updates the global scope' do
		assert_equal 591, evaluate('; evaluate "= foo 591" foo')
	end

	it 'can return a `CALL`able object' do
		assert_equal 7, evaluate('; = a evaluate "BLOCK + b 4" ; = b 3 : CALL a')
	end

	it 'will cause errors to propagate' do
		assert_fails { evaluate('evaluate "/ 1 0"') } if testing? :zero_division
		assert_fails { evaluate('evaluate "+ NULL 0"') } if testing? :invalid_types
		assert_fails { evaluate('; = a 3 : evaluate "+ BLOCK a 0"') } if testing? :strict_types
		assert_fails { evaluate('evaluate "+ 1"') } if testing? :argument_count
		# TODO: test overflow
		assert_fails { evaluate('evaluate "* "a" (- 0 1)"') } if testing? :invalid_values
		assert_fails { evaluate('evaluate "a"') } if testing? :undefined_variables
	end

	test_argument_count 'evaluate', '"1"'

	it 'does not allow blocks as the first operand', when_testing: :strict_types do
		assert_fails { evaluate('; = a "3" : evaluate BLOCK a') }
		assert_fails { evaluate('evaluate BLOCK QUIT 0') }
	end
end
