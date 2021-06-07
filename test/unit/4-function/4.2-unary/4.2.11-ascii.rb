section '4.2.11', 'ASCII' do
	# TODO: have checks for non-ascii values.
	it 'converts numbers properly' do
		[?\t, ?\n, ?\r, *?\s..?~].each do |char|
			assert_result char, %|ASCII #{char.ord}|
		end
	end

	it 'converts strings properly' do
		[?\t, ?\n, ?\r, *?\s..?~].each do |char|
			next if char == ?"
			assert_result char.ord, %|ASCII "#{char}"|
		end

		assert_result ?".ord, %|ASCII '"'|
	end

	it 'converts multicharacter strings properly' do
		assert_result 72, %|ASCII "HELLO"|
		assert_result 110, %|ASCII "neighbor"|
	end

	it 'only allows a number or string as the first operand', when_testing: :invalid_types do
		refute_runs %|ASCII TRUE|
		refute_runs %|ASCII FALSE|
		refute_runs %|ASCII NULL|
	end

	it 'does not allow a function or variable', when_testing: :strict_types do
		refute_runs %|; = a 3 : ASCII (BLOCK a)|
		refute_runs %|; = a (BLOCK QUIT 0) : ASCII a|
	end

	it 'requires exactly one arguments', when_testing: :argument_count do
		refute_runs %|ASCII|
	end
end
