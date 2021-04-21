require_relative '../function-spec'

section '4.2.7', '!' do
	include Kn::Test::Spec

	it 'negates its argument' do
		assert_equal true,  evaluate('! FALSE')
		assert_equal false, evaluate('! TRUE')
	end

	it 'converts its argument to a boolean' do
		assert_equal true,  evaluate('! ""')
		assert_equal false, evaluate('! "0"')
		assert_equal false, evaluate('! "1"')

		assert_equal true,  evaluate('! NULL')

		assert_equal true,  evaluate('! 0')
		assert_equal false, evaluate('! 1')
	end

	test_argument_count '!', 'TRUE'

	it 'does not allow blocks as the first operand', when_testing: :strict_types do
		assert_fails { evaluate('; = a 0 : ! BLOCK a') }
		assert_fails { evaluate('! BLOCK QUIT 0') }
	end
end