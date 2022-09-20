require_relative '../shared'

section 'RANDOM' do
	# Due to how random integers work, these tests can't be 100% accurate
	it 'should not return negative integers' do
		# we run it 100 times so as to catch any possibly negative values.
		assert_result false, ' | > 0 RANDOM '*100 + 'FALSE'
	end

	it 'should return a random value each time it is called' do
		assert_result false, '%|? RANDOM RANDOM|'
	end
end
