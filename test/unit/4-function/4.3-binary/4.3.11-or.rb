require_relative '../function-spec'

section '4.3.11', '|' do
	include Kn::Test::Spec

	it 'returns the lhs if its truthy' do
		assert_equal 1, evaluate('| 1 QUIT 1')
		assert_equal 2, evaluate('| 2 QUIT 1')
		assert_equal true, evaluate('| TRUE QUIT 1')
		assert_equal 'hi', evaluate('| "hi" QUIT 1')
		assert_equal '0', evaluate('| "0" QUIT 1')
		assert_equal 'NaN', evaluate('| "NaN" QUIT 1')
	end

	it 'executes the rhs only if the lhs is falsey' do
		assert_equal 1, evaluate('; | 0 (= a 1) a')
		assert_equal 2, evaluate('; | FALSE (= a 2) a')
		assert_equal 3, evaluate('; | NULL (= a 3) a')
		assert_equal 4, evaluate('; | "" (= a 4) a')
	end

	it 'works with BLOCK for the second argument' do
		assert_equal 3, evaluate('; = a 3 : CALL | 0 BLOCK a')
		assert_equal 5, evaluate('; = a 3 : CALL | 0 BLOCK + a 2')
	end

	it 'does not accept BLOCK values for the first arg', when_testing: :strict_types do
		assert_fails { evaluate('; = a 3 : | (BLOCK a) 1') }
		assert_fails { evaluate('| (BLOCK QUIT 0) 1') }
	end

	test_argument_count '|', '1', '2'
end
