require_relative '../function-spec'

section '4.2.4', 'CALL' do
	include Kn::Test::Spec

	it 'should evaluate something returned by `BLOCK`' do
		assert_equal 12, evaluate('CALL BLOCK 12')
		assert_equal "12", evaluate('CALL BLOCK "12"')

		assert_equal true, evaluate('CALL BLOCK TRUE')
		assert_equal false, evaluate('CALL BLOCK FALSE')
		assert_equal :null, evaluate('CALL BLOCK NULL')

		assert_equal "twelve", evaluate('; = foo BLOCK bar ; = bar "twelve" : CALL foo')
		assert_equal 15, evaluate('; = foo BLOCK * x 5 ; = x 3 : CALL foo')
	end

	it 'should _only_ evaluate BLOCK return values', when_testing: :strict_compliance do
		assert_fails { evaluate('CALL 1') }
		assert_fails { evaluate('CALL "1"') }
		assert_fails { evaluate('CALL TRUE') }
		assert_fails { evaluate('CALL FALSE') }
		assert_fails { evaluate('CALL NULL') }
	end

	test_argument_count 'CALL', 'BLOCK 1'
end
