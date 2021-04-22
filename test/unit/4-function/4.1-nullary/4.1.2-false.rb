require_relative '../function-spec'
require_relative '../../../autorun' if $0 == __FILE__

section '4.1.2', 'FALSE' do
	include Kn::Test::Spec

	it 'is false' do
		assert_equal false, eval('FALSE')
	end
end
