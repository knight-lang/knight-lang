require_relative '../function-spec'

section '4.5.1', 'SUBSTITUTE' do
	include Kn::Test::Spec
	# TODO

	test_argument_count 'SUBS', '"HI"', '0', '1', '"BA"'
end
