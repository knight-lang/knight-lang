require_relative '../../../spec'

section '4.1.5', 'RANDOM' do
	include Kn::Test::Spec

	it 'should not return negative numbers' do
		# we run it 100 times so as to catch any possibly negative values.
		refute eval ' | > 0 RANDOM ' * 100 + 'FALSE'
	end

	it 'should return a random value each time it is called' do
		assert_equal false, eval('? RANDOM RANDOM')
	end
end
