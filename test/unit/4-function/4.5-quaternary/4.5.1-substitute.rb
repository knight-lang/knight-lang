section '4.5.1', 'SUBSTITUTE' do
	it 'returns a substring of the original string' do
		assert_result 'a', %|GET "abcd" 0 1|
		assert_result 'bc', %|GET "abcd" 1 2|
		assert_result 'cd', %|GET "abcd" 2 2|
		assert_result '', %|GET "abcd" 3 0|
	end

	ALPHABET = 'abcdef'
	it 'works for all possible combinations of 6 characters' do
		[*0...ALPHABET.length].product([*0...ALPHABET.length]) do |wordlen, repllen|
			word = ALPHABET[0, wordlen]
			replacement = ALPHABET[0, repllen]
			(0..wordlen).each do |start|
				(0..wordlen - start).each do |len|
					w = word.dup
					w[start, len] = replacement
					assert_result w, "SUBSTITUTE #{word.inspect} #{start} #{len} #{replacement.inspect}"
				end
			end
		end
	end

	it 'converts its arguments to the correct types' do
		assert_result '1!34', %|SUBSTITUTE 1234 1 1 "!"|
		assert_result 'tr0', %|SUBSTITUTE TRUE 2 2 "0"|
		assert_result 'alse', %|SUBSTITUTE FALSE 0 1 ""|
		assert_result 'nIl', %|SUBSTITUTE NULL 1 2 "I"|
		assert_result 'falsearfoo', %|SUBSTITUTE "barfoo" NULL TRUE FALSE|
	end

	it 'does not accept BLOCK values anywhere', when_testing: :strict_types do
		refute_runs %|SUBSTITUTE (BLOCK QUIT 0) 0 0 0|
		refute_runs %|SUBSTITUTE 0 (BLOCK QUIT 0) 0 0|
		refute_runs %|SUBSTITUTE 0 0 (BLOCK QUIT 0) 0|
		refute_runs %|SUBSTITUTE 0 0 0 (BLOCK QUIT 0)|
		refute_runs %|; = a 3 : SUBSTITUTE (BLOCK a) 0 0 0|
		refute_runs %|; = a 3 : SUBSTITUTE 0 (BLOCK a) 0 0|
		refute_runs %|; = a 3 : SUBSTITUTE 0 0 (BLOCK a) 0|
		refute_runs %|; = a 3 : SUBSTITUTE 0 0 0 (BLOCK a)|
	end

	it 'requires exactly four arguments', when_testing: :argument_count do
		refute_runs %|SUBSTITUTE|
		refute_runs %|SUBSTITUTE 0|
		refute_runs %|SUBSTITUTE 0 0|
		refute_runs %|SUBSTITUTE 0 0 0|
		assert_runs %|SUBSTITUTE 0 0 0 0|
	end
end
