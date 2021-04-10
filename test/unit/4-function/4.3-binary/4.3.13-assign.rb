require_relative '../function-spec'

section '4.3.13', '=' do
	include Kn::Test::Spec

	# TODO
	test_argument_count '=', '1', '2'
end

# describe '4.3.13 =' do
# 	it 'assigns to variables' do
# 		assert_equal 12, eval('; = a 12 : a')
# 	end

# 	it 'returns its given value' do
# 		assert_equal 12, eval('= a 12')
# 	end
# end
