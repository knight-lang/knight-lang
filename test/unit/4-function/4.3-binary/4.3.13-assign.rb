require_relative '../function-spec'

section '4.3.13', '=' do
	include Kn::Test::Spec

	# See `unit/3-variable` for more unit tests with variables specifically

	it 'assigns to variables' do
		assert_equal 12, eval('; = a 12 : a')
	end

	it 'returns its given value' do
		assert_equal 12, eval('= a 12')
	end

	it 'only accepts a variable as the first argument', when_testing: :invalid_types do
		assert_fails { eval('= 1 1') }
		assert_fails { eval('= "foo" 1') }
		assert_fails { eval('= TRUE 1') }
		assert_fails { eval('= FALSE 1') }
		assert_fails { eval('= NULL 1') }

		if testing? :strict_types
			assert_fails { eval('; = a 3 : = (BLOCK a) 1') }
			assert_fails { eval('= (BLOCK QUIT 0) 1') }
		end
	end

	# it 'accepts numbers as either argument' do
	# 	assert_equal 3, eval('; (BLOCK QUIT 1) 3')
	# 	assert_equal 4, eval('CALL ; 3 (BLOCK 4)')
	# end

	#test_argument_count '=', 'a', '2'
end
