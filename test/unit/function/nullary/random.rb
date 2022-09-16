require_relative '../shared'

section 'RANDOM' do
	it 'should not return negative numbers' do
		# we run it 100 times so as to catch any possibly negative values.
		assert_result false, ' | > 0 RANDOM '*100 + 'FALSE'
	end

	it 'should return a random value each time it is called' do
		assert_result false, %|? RANDOM RANDOM|
	end
end
