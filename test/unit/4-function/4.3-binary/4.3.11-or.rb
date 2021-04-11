require_relative '../function-spec'

section '4.3.11', '|' do
	include Kn::Test::Spec

	it 'returns the lhs if its truthy' do
		assert_equal 1, eval('| 1 QUIT 1')
		assert_equal 2, eval('| 2 QUIT 1')
		assert_equal true, eval('| TRUE QUIT 1')
		assert_equal 'hi', eval('| "hi" QUIT 1')
		assert_equal '0', eval('| "0" QUIT 1')
		assert_equal 'NaN', eval('| "NaN" QUIT 1')
	end

	it 'executes the rhs only if the lhs is falsey' do
		assert_equal 1, eval('; | 0 (= a 1) a')
		assert_equal 2, eval('; | FALSE (= a 2) a')
		assert_equal 3, eval('; | NULL (= a 3) a')
		assert_equal 4, eval('; | "" (= a 4) a')
	end

	it 'works with BLOCK for the second argument' do
		assert_equal 3, eval('; = a 3 : CALL | 0 BLOCK a')
		assert_equal 5, eval('; = a 3 : CALL | 0 BLOCK + a 2')
	end

	it 'does not accept BLOCK values for the first arg', when_testing: :strict_types do
		assert_fails { eval('; = a 3 : | (BLOCK a) 1') }
		assert_fails { eval('| (BLOCK QUIT 0) 1') }
	end

	test_argument_count '|', '1', '2'
end
