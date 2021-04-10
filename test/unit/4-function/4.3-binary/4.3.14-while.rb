require_relative '../function-spec'

section '4.3.14', 'WHILE' do
	include Kn::Test::Spec
	# TODO
	test_argument_count 'W', '0', '2'
end

# describe '4.3.14 WHILE' do
# 	it 'returns null' do
# 		assert_equal :null, eval('WHILE 0 0')
# 	end

# 	it 'will not evaluate the body if the condition is true' do
# 		assert_equal 12, eval('; WHILE FALSE (QUIT 1) : 12')
# 	end

# 	it 'will evaluate the body until the condition is false' do
# 		assert_equal 10, eval('; = i 0 ; WHILE (< i 10) (= i + i 1) : i')
# 	end
# end
