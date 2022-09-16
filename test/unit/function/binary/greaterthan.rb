require_relative '../shared'

section '>' do
	describe 'when the first arg is a boolean' do
		it 'is only true when TRUTHY and the rhs is falsey' do
			assert_result true, %|> TRUE FALSE|
			assert_result true, %|> TRUE 0|
			assert_result true, %|> TRUE ""|
			assert_result true, %|> TRUE NULL|
		end

		it 'is false all other times' do
			assert_result false, %|> TRUE TRUE|
			assert_result false, %|> TRUE 1|
			assert_result false, %|> TRUE "1"|

			assert_result false, %|> FALSE ~1|
			assert_result false, %|> FALSE TRUE|
			assert_result false, %|> FALSE FALSE|
			assert_result false, %|> FALSE 1|
			assert_result false, %|> FALSE "1"|
			assert_result false, %|> FALSE 0|
			assert_result false, %|> FALSE ""|
			assert_result false, %|> FALSE NULL|
		end
	end

	describe 'when the first arg is a string' do
		it 'performs lexicographical comparison' do
			assert_result false, %|> "a" "aa"|
			assert_result true,  %|> "b" "aa"|

			assert_result true,  %|> "aa" "a"|
			assert_result false, %|> "aa" "b"|

			assert_result false, %|> "A" "AA"|
			assert_result true,  %|> "B" "AA"|

			assert_result true,  %|> "AA" "A"|
			assert_result false, %|> "AA" "B"|

			# ensure it obeys ascii
			assert_result true,  %|> "a" "A"|
			assert_result false, %|> "A" "a"|
			assert_result true,  %|> "z" "Z"|
			assert_result false, %|> "Z" "z"|

			assert_result true, %|> ":" 9|
			assert_result true, %|> "1" 0|
		end

		it 'performs it even with numbers' do
			assert_result false, %|> "0" "00"|
			assert_result false, %|> "1" "12"|
			assert_result false, %|> "100" "12"|
			assert_result true, %|> "00" "0"|
			assert_result true, %|> "12" "1"|
			assert_result true, %|> "12" "100"|

			assert_result false, %|> "  0" "  00"|
			assert_result false, %|> "  1" "  12"|
			assert_result false, %|> "  100" "  12"|
		end

		it 'coerces the RHS to a number' do
			assert_result false, %|> "0" 1|
			assert_result false, %|> "1" 12|
			assert_result false, %|> "100" 12|
			assert_result true, %|> "00" 0|
			assert_result true, %|> "12" 100|
			assert_result true, %|> "12" 100|

			assert_result false, %|> "trud" TRUE|
			assert_result false, %|> "true" TRUE|
			assert_result true,  %|> "truf" TRUE|

			assert_result false, %|> "falsd" FALSE|
			assert_result false, %|> "false" FALSE|
			assert_result true,  %|> "faslf" FALSE|

			assert_result false, %|> "nulk" NULL|
			assert_result false, %|> "null" NULL|
			assert_result true,  %|> "nulm" NULL|
		end
	end

	describe 'when the first arg is a number' do
		it 'performs numeric comparison' do
			assert_result false, %|> 1 1|
			assert_result false, %|> 0 0|
			assert_result false, %|> 12 100|
			assert_result false, %|> 1 2|
			assert_result false, %|> 91 491|

			assert_result true, %|> 100 12|
			assert_result true, %|> 2 1|
			assert_result true, %|> 491 91|

			assert_result false, %|> 4 13|
			assert_result true,  %|> 4 ~13|
			assert_result false, %|> ~4 13|
			assert_result true,  %|> ~4 ~13|
		end

		it 'coerces the RHS to a number' do
			assert_result false, %|> 0 TRUE|
			assert_result false, %|> 0 "1"|
			assert_result false, %|> 0 "49"|
			assert_result false, %|> ~2 "-1"|

			assert_result true, %|> 1 FALSE|
			assert_result true, %|> 1 NULL|
			assert_result true, %|> 1 "0"|
			assert_result true, %|> 01 ""|
			assert_result true, %|> 0 "-1"|
			assert_result true, %|> ~1 "-2"|
		end
	end

	it 'evaluates arguments in order' do
		assert_result true,  %|> (= n 45) 44|
		assert_result false, %|> (= n 45) 46|

		assert_result false, %|> (= n "mhm") (+ n "m")|
		assert_result true,  %|> (+ (= n "mhm") "m") n|

		assert_result true,  %|> (= n TRUE) !n|
		assert_result false, %|> (= n FALSE) !n|
	end

	it 'only allows a number, boolean, or string as the first operand', when_testing: :invalid_types do
		refute_runs %|> NULL 1|
	end

	it 'does not allow a function or variable as any operand', when_testing: :strict_types do
		refute_runs %|; = a 3 : > (BLOCK a) 1|
		refute_runs %|; = a 3 : > 1 (BLOCK a)|
		refute_runs %|> (BLOCK QUIT 0) 1|
		refute_runs %|> 1 (BLOCK QUIT 0)|
	end

	it 'requires exactly two arguments', when_testing: :argument_count do
		refute_runs %|>|
		refute_runs %|> 1|
		assert_runs %|> 1 1|
	end
end
