section 'RANDOM' do
	# Due to how random integers work, these tests can't be 100% accurate
	it 'should not return negative integers' do
		# we run it 100 times so as to catch any possibly negative values.
		assert_result false, '| > 0 RANDOM '*100 + 'FALSE'
	end

	# NOTE: This could possibly fail in valid implementations, as `RANDOM` _can_ return the same value
	# multiple times. If this happens, just rerun the tester. If it happens multiple times in a row,
	# that probably means there's a problem with your implementation.
	it 'should return a random value each time it is called' do
		assert_result false, %|? RANDOM RANDOM|
	end
end
