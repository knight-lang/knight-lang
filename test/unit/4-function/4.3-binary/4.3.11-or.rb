require_relative '../function-spec'

section '4.3.11', '|' do
	include Kn::Test::Spec
	# TODO

	test_argument_count '|', '1', '2'
end

# describe '4.3.11 |' do
# 	it 'returns the lhs if its truthy' do
# 		assert_equal 1, eval('| 1 QUIT 1')
# 		assert_equal 2, eval('| 2 QUIT 1')
# 		assert_equal true, eval('| TRUE QUIT 1')
# 		assert_equal 'hi', eval('| "hi" QUIT 1')
# 		assert_equal '0', eval('| "0" QUIT 1')
# 		assert_equal 'NaN', eval('| "NaN" QUIT 1')
# 	end

# 	it 'executes the rhs only if the lhs is falsey' do
# 		assert_equal 1, eval('; | 0 (= a 1) a')
# 		assert_equal 2, eval('; | FALSE (= a 2) a')
# 		assert_equal 3, eval('; | NULL (= a 3) a')
# 		assert_equal 4, eval('; | "" (= a 4) a')
# 	end
# end
