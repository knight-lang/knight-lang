require_relative '../function-spec'

section '4.3.12', ';' do
	include Kn::Test::Spec

	# TODO
	test_argument_count ';', '1', '2'
end

# describe '4.3.12 ;' do
# 	it "executes the first argument, then the second, then returns the second's value" do
# 		assert_equal 1, eval('; 0 1')
# 		assert_equal 3, eval('; = a 3 : a')
# 	end
# end
