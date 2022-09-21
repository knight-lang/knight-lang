require_relative '../../shared'

section 'SET' do
	describe 'when the first argument is a string' do
		it 'returns a substring of the original string' do
			assert_result 'a', %|GET "abcd" 0 1|
			assert_result 'bc', %|GET "abcd" 1 2|
			assert_result 'cd', %|GET "abcd" 2 2|
			assert_result '', %|GET "abcd" 3 0|
		end

		it 'works for all possible combinations of 6 characters' do
			alphabet = 'abcdef'
			[*0...alphabet.length].product([*0...alphabet.length]) do |wordlen, repllen|
				word = alphabet[0, wordlen]
				replacement = alphabet[0, repllen]
				(0..wordlen).each do |start|
					(0...wordlen - start).each do |len|
						w = word.dup
						w[start, len] = replacement
						assert_result w, "SET #{word.inspect} #{start} #{len} #{replacement.inspect}"
					end
				end
			end
		end

		it 'converts its arguments to the correct types' do
			assert_result '1!34', %|SET 1234 1 1 "!"|
			assert_result 'tr0', %|SET TRUE 2 2 "0"|
			assert_result 'alse', %|SET FALSE 0 1 ""|
			assert_result 'nIl', %|SET NULL 1 2 "I"|
			assert_result 'falsearfoo', %|SET "barfoo" NULL TRUE FALSE|
		end
	end

	describe 'when the first argument is a list' do
		it 'returns a substring of the original list' do
			assert_result 'a', %|GET +@abcd" 0 1|
			assert_result 'bc', %|GET +@"abcd" 1 2|
			assert_result 'cd', %|GET +@1234 2 2|
			assert_result '', %|GET +@1234 3 0|
		end

		it 'works for all possible combinations of 6 characters' do
			alphabet = 'abcdef'
			[*0...alphabet.length].product([*0...alphabet.length]) do |wordlen, repllen|
				word = alphabet[0, wordlen]
				replacement = alphabet[0, repllen]
				(0..wordlen).each do |start|
					(0...wordlen - start).each do |len|
						w = word.dup
						w[start, len] = replacement
						assert_result w, "SET #{word.inspect} #{start} #{len} #{replacement.inspect}"
					end
				end
			end
		end

		it 'converts its arguments to the correct types' do
			assert_result '1!34', %|SET 1234 1 1 "!"|
			assert_result 'tr0', %|SET TRUE 2 2 "0"|
			assert_result 'alse', %|SET FALSE 0 1 ""|
			assert_result 'nIl', %|SET NULL 1 2 "I"|
			assert_result 'falsearfoo', %|SET "barfoo" NULL TRUE FALSE|
		end
	end

	it 'does not accept BLOCK values anywhere', when_testing: :strict_types do
		refute_runs %|SET (BLOCK QUIT 0) 0 0 0|
		refute_runs %|SET '0' (BLOCK QUIT 0) 0 0|
		refute_runs %|SET '0' 0 (BLOCK QUIT 0) 0|
		refute_runs %|SET '0' 0 0 (BLOCK QUIT 0)|
		refute_runs %|; = a 3 : SET (BLOCK a) 0 0 0|
		refute_runs %|; = a 3 : SET '0' (BLOCK a) 0 0|
		refute_runs %|; = a 3 : SET '0' 0 (BLOCK a) 0|
		refute_runs %|; = a 3 : SET '0' 0 0 (BLOCK a)|
	end

	it 'requires exactly four arguments', when_testing: :argument_count do
		refute_runs %|SET|
		refute_runs %|SET '0'|
		refute_runs %|SET '0' 0|
		refute_runs %|SET '0' 0 0|
		assert_runs %|SET '0' 0 0 0|
	end
end
