require_relative '../shared'

section '<' do
	describe 'when the first arg is a boolean' do
		it 'is only true when FALSE and the rhs is truthy' do
			assert_result true, %|< FALSE TRUE|
			assert_result true, %|< FALSE 1|
			assert_result true, %|< FALSE "1"|
			assert_result true, %|< FALSE ~1|
		end

		it 'is false all other times' do
			assert_result false, %|< FALSE FALSE|
			assert_result false, %|< FALSE 0|
			assert_result false, %|< FALSE ""|
			assert_result false, %|< FALSE NULL|

			assert_result false, %|< TRUE TRUE|
			assert_result false, %|< TRUE FALSE|
			assert_result false, %|< TRUE 1|
			assert_result false, %|< TRUE "1"|
			assert_result false, %|< TRUE 2|
			assert_result false, %|< TRUE ~2|
			assert_result false, %|< TRUE 0|
			assert_result false, %|< TRUE ""|
			assert_result false, %|< TRUE NULL|
		end
	end

	describe 'when the first arg is a string' do
		it 'performs lexicographical comparison' do
			assert_result true,  %|< "a" "aa"|
			assert_result false, %|< "b" "aa"|

			assert_result false, %|< "aa" "a"|
			assert_result true,  %|< "aa" "b"|

			assert_result true,  %|< "A" "AA"|
			assert_result false, %|< "B" "AA"|

			assert_result false, %|< "AA" "A"|
			assert_result true,  %|< "AA" "B"|

			# ensure it obeys ascii
			assert_result false, %|< "a" "A"|
			assert_result true,  %|< "A" "a"|
			assert_result false, %|< "z" "Z"|
			assert_result true,  %|< "Z" "z"|

			assert_result true, %|< "/" 0|
			assert_result true, %|< "8" 9|
		end

		it 'performs it even with numbers' do
			assert_result true, %|< "0" "00"|
			assert_result true, %|< "1" "12"|
			assert_result true, %|< "100" "12"|
			assert_result false, %|< "00" "0"|
			assert_result false, %|< "12" "1"|
			assert_result false, %|< "12" "100"|

			assert_result true, %|< "  0" "  00"|
			assert_result true, %|< "  1" "  12"|
			assert_result true, %|< "  100" "  12"|
		end

		it 'coerces the RHS to a string' do
			assert_result true, %|< "0" 1|
			assert_result true, %|< "1" 12|
			assert_result true, %|< "100" 12|
			assert_result false, %|< "00" 0|
			assert_result false, %|< "12" 100|
			assert_result false, %|< "12" 100|

			assert_result true, %|< "trud" TRUE|
			assert_result false, %|< "true" TRUE|
			assert_result false, %|< "truf" TRUE|

			assert_result true, %|< "falsd" FALSE|
			assert_result false, %|< "false" FALSE|
			assert_result false, %|< "faslf" FALSE|

			assert_result true, %|< "nulk" NULL|
			assert_result false, %|< "null" NULL|
			assert_result false, %|< "nulm" NULL|
		end
	end

	describe 'when the first arg is a number' do
		it 'performs numeric comparison' do
			assert_result false, %|< 1 1|
			assert_result false, %|< 0 0|
			assert_result true, %|< 12 100|
			assert_result true, %|< 1 2|
			assert_result true, %|< 91 491|

			assert_result false, %|< 100 12|
			assert_result false, %|< 2 1|
			assert_result false, %|< 491 91|

			assert_result true, %|< 4 13|
			assert_result false, %|< 4 ~13|
			assert_result true, %|< ~4 13|
			assert_result false, %|< ~4 ~13|
		end

		it 'coerces the RHS to a number' do
			assert_result true, %|< 0 TRUE|
			assert_result true, %|< 0 "1"|
			assert_result true, %|< 0 "49"|
			assert_result true, %|< ~2 "-1"|

			assert_result false, %|< 0 FALSE|
			assert_result false, %|< 0 NULL|
			assert_result false, %|< 0 "0"|
			assert_result false, %|< 0 "-1"|
			assert_result false, %|< 0 ""|
		end
	end

	it 'evaluates arguments in order' do
		assert_result true,  %|< (= n 45) 46|
		assert_result false, %|< (= n 45) 44|

		assert_result true,  %|< (= n "mhm") (+ n "m")|
		assert_result false, %|< (+ (= n "mhm") "m") n|

		assert_result false, %|< (= n TRUE) !n|
		assert_result true,  %|< (= n FALSE) !n|
	end

	it 'only allows a number, boolean, or string as the first operand', when_testing: :invalid_types do
		refute_runs %|< NULL 1|
	end

	it 'does not allow a function or variable as any operand', when_testing: :strict_types do
		refute_runs %|; = a 3 : < (BLOCK a) 1|
		refute_runs %|; = a 3 : < 1 (BLOCK a)|
		refute_runs %|< (BLOCK QUIT 0) 1|
		refute_runs %|< 1 (BLOCK QUIT 0)|
	end

	it 'requires exactly two arguments', when_testing: :argument_count do
		refute_runs %|<|
		refute_runs %|< 1|
		assert_runs %|< 1 1|
	end
end
