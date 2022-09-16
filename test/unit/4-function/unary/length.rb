section 'L' do
	it 'performs under normal conditions' do
		assert_result 3, %|LENGTH "foo"|
		assert_result 27, %|LENGTH "a man a plan a canal panama"|
		assert_result 21, %|LENGTH "and then I questioned"|
		assert_result 100, %|LENGTH '#{'x' * 100}'|
	end

	it 'returns 0 for empty strings' do
		assert_result 0, %|LENGTH ""|
	end

	it 'does not coerce its argument to a number and back' do
		assert_result 2, %|LENGTH "-0"|
		assert_result 5, %|LENGTH "49.12"|
	end

	it 'works with multiline strings.' do
		assert_result 10, %|LENGTH 'fooba\nrbaz'|
	end

	it 'converts its value to a string' do
		assert_result 1, %|LENGTH 0|
		assert_result 3, %|LENGTH 923|
		assert_result 4, %|LENGTH TRUE|
		assert_result 5, %|LENGTH FALSE|
		assert_result 4, %|LENGTH NULL|
	end

	it 'requires exactly one argument', when_testing: :argument_count do
		refute_runs %|LENGTH|
		assert_runs %|LENGTH "hi"|
	end

	it 'does not allow blocks as the first operand', when_testing: :strict_types do
		refute_runs %|; = a 0 : LENGTH BLOCK a|
		refute_runs %|LENGTH BLOCK QUIT 0|
	end
end
