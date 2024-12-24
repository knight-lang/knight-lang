section 'SET' do
	describe 'when the first argument is a string' do
		it 'can remove substrings' do
			assert_result 'bcd', %|SET "abcd" 0 1 ""|
			assert_result 'ad', %|SET "abcd" 1 2 ""|
			assert_result 'ab', %|SET "abcd" 2 2 ""|
			assert_result 'd', %|SET "abcd" 0 3 ""|
			assert_result '', %|SET "abc" 0 3 ""|
		end

		it 'can insert substrings' do
			assert_result '1abcd', %|SET "abcd" 0 0 "1"|
			assert_result 'abcd12', %|SET "abcd" 4 0 "12"|
			assert_result 'a12', %|SET "a" 1 0 "12"|
			assert_result '12', %|SET "" 0 0 "12"|
		end

		it 'can replace substrings' do
			assert_result 'a123d', %|SET "abcd" 1 2 "123"|
			assert_result 'ab4445', %|SET "abcd" 2 2 "4445"|
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
			assert_result '1false34', %|SET '1234' TRUE ,1 FALSE|
			assert_result "h1\n2\n3lo world", %|SET 'hello world' TRUE '2' +@123|
		end
	end

	describe 'when the first argument is a list' do
		it 'can remove sublists' do
			assert_result ['b', 'c', 'd'], %|SET +@"abcd" 0 1 @|
			assert_result ['a', 'd'], %|SET +@"abcd" 1 2 @|
			assert_result ['a', 'b'], %|SET +@"abcd" 2 2 @|
			assert_result ['d'], %|SET +@"abcd" 0 3 @|
			assert_result [], %|SET +@"abc" 0 3 @|
		end

		it 'can insert sublists' do
			assert_result [true, 'a', 'b', 'c', 'd'], %|SET +@"abcd" 0 0 ,TRUE|
			assert_result ['a', 'b', 'c', 'd', 1, 2], %|SET +@"abcd" 4 0 +@12|
			assert_result ['a', 1, 2], %|SET +@"a" 1 0 +@12|
			assert_result [1, 2], %|SET @ 0 0 +@12|
		end

		it 'can replace sublists' do
			assert_result ['a', 1, 2, 3, 'd'], %|SET +@"abcd" 1 2 +@123|
			assert_result ['a', 'b', 4, 4, 4, 5], %|SET +@"abcd" 2 2 +@4445|
		end

		it 'works for all possible combinations of 6 characters' do
			next
			alphabet = 'abcdef'.chars
			numbers = [1, 2, 3, 4, 5, 6]
			[*0...alphabet.length].product([*0...alphabet.length]) do |wordlen, repllen|
				word = "+@'#{alphabet[0, wordlen].join}'"
				replacement = "+@#{numbers[0, repllen].join}"
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
			assert_result [true, 'a', 'b', 'c', 'd'], %|SET +@"abcd" 0 0 TRUE|
			assert_result [1, 3, 4], %|SET +@1234 TRUE '1' FALSE|
			assert_result ['h', 1, 2, 3, 'l', 'o', ' ', 'w', 'o', 'r', 'l', 'd'], %|SET +@'hello world' TRUE '2' 123|
			assert_result ['y', 'o', 2, 3, 4], %|SET +@1234 NULL ,3 'yo'|
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
