section 'LENGTH' do
	it 'returns 0 for NULL' do
		assert_result 0, %|LENGTH NULL|
	end

=begin commented out section because no boolean conversions
	it 'returns 1 for TRUE and 0 for FALSE' do
		assert_result 1, %|LENGTH TRUE|
		assert_result 0, %|LENGTH FALSE|
	end
=end

	it 'returns the amount of digits in an integer' do
		assert_result 1, %|LENGTH 0|
		assert_result 1, %|LENGTH 1|
		assert_result 2, %|LENGTH 59|
		assert_result 4, %|LENGTH 1111|
	end

=begin commented out section because no negative integers
	it 'returns the same length for negative integers' do
		assert_result 1, %|LENGTH ~0|
		assert_result 1, %|LENGTH ~1|
		assert_result 2, %|LENGTH ~59|
		assert_result 4, %|LENGTH ~1111|
	end
=end

	# Note that since basic Knight is ascii only, there's no difference between
	# bytes and UTF8 chars.
	it 'returns the amount of chars in strings' do
		assert_result 0, %|LENGTH ""|
		assert_result 3, %|LENGTH "foo"|
		assert_result 27, %|LENGTH "a man a plan a canal panama"|
		assert_result 21, %|LENGTH "and then I questioned"|
		assert_result 100, %|LENGTH '#{'x' * 100}'|
	end

	it 'does not coerce its argument to an integer and back' do
		assert_result 2, %|LENGTH "-0"|
		assert_result 5, %|LENGTH "49.12"|
		assert_result 1, %|LENGTH ,"49.12"|
	end

	it 'returns the amount of elements in a list' do
		assert_result 0, %|LENGTH @|
		assert_result 1, %|LENGTH ,1|
		assert_result 3, %|LENGTH +@123|
		assert_result 3, %|LENGTH +@"aaa"|
		assert_result 6, %|LENGTH + (+@"aaa") (+@"bbb") |
		assert_result 100, %|LENGTH *,33 100|
		assert_result 4, %|LENGTH GET *,33 100 0 4|
	end

	it 'works with multiline strings.' do
		assert_result 10, %|LENGTH 'fooba\nrbaz'|
	end

	it 'requires exactly one argument', when_testing: :argument_count do
		refute_runs %|LENGTH|
		assert_runs %|LENGTH "hi"|
	end

	it 'does not allow blocks as the first operand', when_testing: :strict_types do
		refute_runs %|; = a 0 : LENGTH BLOCK a|
		refute_runs %|LENGTH BLOCK QUIT 0|
	end

  it 'supports lists and strings of max size', when_testing: :container_bounds do
    assert_equal MAX_INT, %|LENGTH *,1 #{MAX_INT_S}|
    assert_equal MAX_INT, %|LENGTH *"1" #{MAX_INT_S}|
  end
end
