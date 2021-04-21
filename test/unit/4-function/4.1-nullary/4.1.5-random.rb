require_relative '../function-spec'
require_relative '../../../autorun' if $0 == __FILE__

section '4.1.5', 'RANDOM' do
	include Kn::Test::Spec

	it 'should not return negative numbers' do
		# we run it 100 times so as to catch any possibly negative values.
		refute evaluate ' | > 0 RANDOM ' * 100 + 'FALSE'
	end

	it 'should return a random value each time it is called' do
		assert_equal false, evaluate('? RANDOM RANDOM')
	end
end
