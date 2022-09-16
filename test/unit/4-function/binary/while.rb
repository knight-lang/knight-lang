section 'WHILE' do
	it 'returns null' do
		assert_result :null, 'WHILE 0 0'
	end

	it 'will not eval the body if the condition is true' do
		assert_result 12, %|; WHILE FALSE (QUIT 1) : 12|
	end

	it 'will eval the body until the condition is false' do
		assert_result 45, <<~EOS
			; = i 0
			; = sum 0
			; WHILE (< i 10)
				; = sum + sum i
				: = i + i 1
			: sum
		EOS
	end

	it 'does not accept BLOCK values', when_testing: :strict_types do
		refute_runs %|; = a 0 : WHILE (BLOCK a) 1|
		refute_runs %|WHILE (BLOCK QUIT 0) 1|
	end

	it 'requires exactly two arguments', when_testing: :argument_count do
		refute_runs %|WHILE|
		refute_runs %|WHILE 0|
		assert_runs %|WHILE 0 1|
	end
end
