require_relative '../function-spec'

section '4.4.2', 'GET' do
	include Kn::Test::Spec
	# TODO

	test_argument_count 'IF', '"HI"', '0', '1'
end
