require_relative '../shared'

section '?' do
	describe 'when the first arg is null' do
		it 'equals itself' do
			assert_result true, %|? NULL NULL|
		end

		it 'is not equal to other values' do
			assert_result false, %|? NULL FALSE|
			assert_result false, %|? NULL TRUE|
			assert_result false, %|? NULL 0|
			assert_result false, %|? NULL ""|
			assert_result false, %|? NULL "0"|
			assert_result false, %|? NULL "NULL"|
			assert_result false, %|? NULL "null"|
		end
	end

	describe 'when the first arg is a boolean' do
		it 'only is equal to itself' do
			assert_result true, %|? TRUE TRUE|
			assert_result true, %|? FALSE FALSE|
		end

		it 'is not equal to anything else' do
			assert_result false, %|? TRUE 1|
			assert_result false, %|? TRUE "1"|
			assert_result false, %|? TRUE "TRUE"|
			assert_result false, %|? TRUE "true"|

			assert_result false, %|? FALSE 0|
			assert_result false, %|? FALSE ""|
			assert_result false, %|? FALSE "0"|
			assert_result false, %|? FALSE "FALSE"|
			assert_result false, %|? FALSE "false"|
		end
	end

	describe 'when the first arg is a number' do
		it 'is only equal to itself' do
			assert_result true, %|? 0 0|
			assert_result true, %|? ~0 0|
			assert_result true, %|? 1 1|
			assert_result true, %|? ~1 ~1|
			assert_result true, %|? 912 912|
			assert_result true, %|? 123 123|
		end

		it 'is not equal to anything else' do
			assert_result false, %|? 0 1|
			assert_result false, %|? 1 0|
			assert_result false, %|? 4 5|
			assert_result false, %|? ~4 4|

			assert_result false, %|? 0 FALSE|
			assert_result false, %|? 0 NULL|
			assert_result false, %|? 0 ""|
			assert_result false, %|? 1 TRUE|
			assert_result false, %|? 1 "1"|
			assert_result false, %|? 1 "1a"|
		end
	end

	describe 'when the first arg is a string' do
		it 'is only equal to itself' do
			assert_result true, %|? "" ""|
			assert_result true, %|? "a" "a"|
			assert_result true, %|? "0" "0"|
			assert_result true, %|? "1" "1"|
			assert_result true, %|? "foobar" "foobar"|
			assert_result true, %|? "this is a test" "this is a test"|
			assert_result true, %|? (+ "'" '"') (+ "'" '"')|
		end

		it 'is not equal to other strings' do
			assert_result false, %|? "" " "|
			assert_result false, %|? " " ""|
			assert_result false, %|? "a" "A"|
			assert_result false, %|? "0" "00"|
			assert_result false, %|? "1.0" "1"|
			assert_result false, %|? "1" "1.0"|
			assert_result false, %|? "0" "0x0"|
			assert_result false, %|? "is this a test" "this is a test"|
		end

		it 'is not equal to equivalent types' do
			assert_result false, %|? "0" 0|
			assert_result false, %|? "1" 1|

			assert_result false, %|? "T" TRUE|
			assert_result false, %|? "TRUE" TRUE|
			assert_result false, %|? "True" TRUE|
			assert_result false, %|? "true" TRUE|

			assert_result false, %|? "F" FALSE|
			assert_result false, %|? "FALSE" FALSE|
			assert_result false, %|? "False" FALSE|
			assert_result false, %|? "false" FALSE|

			assert_result false, %|? "N" NULL|
			assert_result false, %|? "NULL" NULL|
			assert_result false, %|? "Null" NULL|
			assert_result false, %|? "null" NULL|
		end
	end

	it 'evaluates arguments in order' do
		assert_result true, %|? (= n 45) n|
		assert_result true, %|? (= n "mhm") n|
		assert_result true, %|? (= n TRUE) n|
		assert_result true, %|? (= n FALSE) n|
		assert_result true, %|? (= n NULL) n|
	end

	it 'does not allow a function or variable as any operand', when_testing: :strict_types do
		refute_runs %|; = a 3 : ? (BLOCK a) 1|
		refute_runs %|; = a 3 : ? 1 (BLOCK a)|
		refute_runs %|? (BLOCK QUIT 0) 1|
		refute_runs %|? 1 (BLOCK QUIT 0)|
	end

	it 'requires exactly two arguments', when_testing: :argument_count do
		refute_runs %|?|
		refute_runs %|? 1|
		assert_runs %|? 1 1|
	end
end
