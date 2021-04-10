require_relative '../function-spec'

section '4.3.10', '&' do
	include Kn::Test::Spec
	# TODO

	test_argument_count '&', '1', '2'
end

# it 'returns the lhs if its falsey' do
# 	assert_equal 0, eval('& 0 QUIT 1')
# 	assert_equal false, eval('& FALSE QUIT 1')
# 	assert_equal :null, eval('& NULL QUIT 1')
# 	assert_equal '', eval('& "" QUIT 1')
# end

# it 'executes the rhs only if the lhs is truthy' do
# 	assert_equal 1, eval('; & 1 (= a 1) a')
# 	assert_equal 2, eval('; & TRUE (= a 2) a')
# 	assert_equal 3, eval('; & "hi" (= a 3) a')
# 	assert_equal 4, eval('; & "0" (= a 4) a')
# 	assert_equal 5, eval('; & "NaN" (= a 5) a')
# end

# it 'returns the lhs if its falsey' do end
# it 'executes the rhs only if the lhs is truthy' do end
