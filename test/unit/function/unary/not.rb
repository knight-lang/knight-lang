require_relative '../shared'

section '!' do
	it 'inverts its argument' do
		assert_result true,  %|! FALSE|
		assert_result false, %|! TRUE|
	end

	it 'converts its argument to a boolean' do
		assert_result true,  %|! ""|
		assert_result false, %|! "0"|
		assert_result false, %|! "1"|

		assert_result true,  %|! NULL|

		assert_result true,  %|! 0|
		assert_result false, %|! 1|
	end

	it 'requires exactly one argument', when_testing: :argument_count do
		refute_runs %|!|
		assert_runs %|! TRUE|
	end

	it 'does not allow blocks as the first operand', when_testing: :strict_types do
		refute_runs %|; = a 0 : ! BLOCK a|
		refute_runs %|! BLOCK QUIT 0|
	end
end
