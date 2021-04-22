section '4.4.2', 'GET' do
	it 'returns a substring of the original string' do
		assert_result 'a', %|GET "abcd" 0 1|
		assert_result 'bc', %|GET "abcd" 1 2|
		assert_result 'cd', %|GET "abcd" 2 2|
		assert_result '', %|GET "abcd" 3 0|
	end

	it 'works for all possible combinations of 6 characters' do
		alphabet = 'abcdef'
		alphabet.length.times do |length|
			word = alphabet[0, length]
			(0..length).each do |start|
				(0..length - start).each do |len|
					assert_result word[start, len], "GET #{word.inspect} #{start} #{len}"
				end
			end
		end
	end

	it 'converts its arguments to the correct types' do
		assert_result '1', %|GET 1234 0 1|
		assert_result 't', %|GET TRUE 0 1|
		assert_result 'f', %|GET FALSE 0 1|
		assert_result 'n', %|GET NULL 0 1|
		assert_result 'f', %|GET "foobar" NULL TRUE|
	end

	it 'does not accept BLOCK values anywhere', when_testing: :strict_types do
		refute_runs %|GET (BLOCK QUIT 0) 0 0|
		refute_runs %|GET 0 (BLOCK QUIT 0) 0|
		refute_runs %|GET 0 0 (BLOCK QUIT 0)|
		refute_runs %|; = a 3 : GET (BLOCK a) 0 0|
		refute_runs %|; = a 3 : GET 0 (BLOCK a) 0|
		refute_runs %|; = a 3 : GET 0 0 (BLOCK a)|
	end

	it 'requires exactly three arguments', when_testing: :argument_count do
		refute_runs %|GET|
		refute_runs %|GET 0|
		refute_runs %|GET 0 0|
		assert_runs %|GET 0 0 0|
	end
end
