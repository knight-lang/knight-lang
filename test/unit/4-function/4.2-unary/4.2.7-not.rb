require_relative '../function-spec'

section '4.2.7', '!' do
	include Kn::Test::Spec

	it 'negates its argument' do
		assert_equal true,  eval('! FALSE')
		assert_equal false, eval('! TRUE')
	end

	it 'converts its argument to a boolean' do
		assert_equal true,  eval('! ""')
		assert_equal false, eval('! "0"')
		assert_equal false, eval('! "1"')

		assert_equal true,  eval('! NULL')

		assert_equal true,  eval('! 0')
		assert_equal false, eval('! 1')
	end

	#test_argument_count '!', 'TRUE'

	it 'does not allow blocks as the first operand', when_testing: :strict_types do
		assert_fails { eval('; = a 0 : ! BLOCK a') }
		assert_fails { eval('! BLOCK QUIT 0') }
	end
end
