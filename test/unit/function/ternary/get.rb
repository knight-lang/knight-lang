section 'GET' do
	describe 'when the first argument is a string' do
		it 'returns a substring of the original string' do
			assert_result 'a', %|GET "abcd" 0 1|
			assert_result 'bc', %|GET "abcd" 1 2|
			assert_result 'cd', %|GET "abcd" 2 2|
			assert_result '', %|GET "abcd" 3 0|
			assert_result '', %|GET '' 0 0|
		end

		it 'works for all possible combinations of 6 characters' do
			alphabet = 'abcdef'
			alphabet.length.times do |length|
				word = alphabet[0, length]
				(0..length).each do |start|
					(0...length - start).each do |len|
						assert_result word[start, len], "GET #{word.inspect} #{start} #{len}"
					end
				end
			end
		end

		it 'converts its arguments to the correct types' do
			assert_result 'f', %|GET "foobar" NULL TRUE|
		end
	end

	describe 'when the first argument is a list' do
		it 'returns a substring of the original list' do
			assert_result ['a'], %|GET +@"abcd" 0 1|
			assert_result ['b', 'c'], %|GET +@"abcd" 1 2|
			assert_result [3, 4], %|GET +@1234 2 2|
			assert_result [], %|GET +@1234 3 0|
			assert_result [], %|GET @ 0 0|
		end

		it 'works for all possible combinations of 6 characters' do
			alphabet = 'abcdef'
			alphabet.length.times do |length|
				word = alphabet[0, length]
				(0..length).each do |start|
					(0...length - start).each do |len|
						assert_result word[start, len].chars, "GET +@#{word.inspect} #{start} #{len}"
					end
				end
			end
		end

		it 'converts its arguments to the correct types' do
			assert_result ['f'], %|GET +@"foobar" NULL TRUE|
		end
	end
	it 'does not accept BLOCK values anywhere', when_testing: :strict_types do
		refute_runs %|GET (BLOCK QUIT 0) 0 0|
		refute_runs %|GET '0' (BLOCK QUIT 0) 0|
		refute_runs %|GET '0' 0 (BLOCK QUIT 0)|
		refute_runs %|; = a 3 : GET (BLOCK a) 0 0|
		refute_runs %|; = a 3 : GET '0' (BLOCK a) 0|
		refute_runs %|; = a 3 : GET '0' 0 (BLOCK a)|
	end

	it 'requires exactly three arguments', when_testing: :argument_count do
		refute_runs %|GET|
		refute_runs %|GET 'a'|
		refute_runs %|GET 'a' 0|
		assert_runs %|GET 'a' 0 0|
	end
end
