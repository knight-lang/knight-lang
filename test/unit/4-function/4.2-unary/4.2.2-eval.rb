describe '4.2.2 EVAL' do
	include Kn::Test::Spec

	it 'evaluates text as Knight code' do
		assert_equal 12, eval('EVAL "12"')
		assert_equal 47, eval('EVAL "+ 12 34"')
		assert_equal 8, eval('EVAL "; = a 3 : + a 5"')
	end

	it 'converts values to a string' do
		assert_equal 23, eval('; = true 23 : EVAL TRUE')
		assert_equal 23, eval('; = false 23 : EVAL FALSE')
		assert_equal 23, eval('; = null 23 : EVAL NULL')
		assert_equal 19, eval('EVAL 19')
	end

	it 'updates the global scope' do
		assert_equal 591, eval('; EVAL "= foo 591" foo')
	end

	it 'can return a `CALL`able object' do
		assert_equal 7, eval('; = a EVAL "BLOCK + b 4" ; = b 3 : CALL a')
	end

	it 'will cause errors to propagate' do
		assert_fails { eval('EVAL "/ 1 0"') } if testing? :zero_division
		assert_fails { eval('EVAL "+ NULL 0"') } if testing? :invalid_types
		assert_fails { eval('; = a 3 : EVAL "+ BLOCK a 0"') } if testing? :strict_types
		assert_fails { eval('EVAL "+ 1"') } if testing? :argument_count
		# TODO: test overflow
		assert_fails { eval('EVAL "* "a" (- 0 1)"') } if testing? :invalid_values
		assert_fails { eval('EVAL "a"') } if testing? :undefined_variables
	end

	it 'requires exactly one argument', when_testing: :argument_count do
		assert_fails { eval('EVAL') }
		assert_runs  { eval('EVAL 1') }
	end
end
