require_relative '../shared'

# TODO: have checks for non-ascii values.
section 'ASCII' do
	it 'converts integers properly' do
		KNIGHT_ENCODING.each do |char|
			assert_result char, %|ASCII #{char.ord}|
		end
	end

	it 'converts strings properly' do
		assert_result '"'.ord, %|ASCII '"'|

		(KNIGHT_ENCODING - ['"']).each do |char|
			assert_result char.ord, %|ASCII "#{char}"|
		end
	end

	it 'converts multicharacter strings properly' do
		assert_result 'H'.ord, %|ASCII "HELLO"|
		assert_result 'n'.ord, %|ASCII "neighbor"|
	end

	it 'only allows an integer or string as the first operand', when_testing: :invalid_types do
		refute_runs %|ASCII TRUE|
		refute_runs %|ASCII FALSE|
		refute_runs %|ASCII NULL|
		refute_runs %|ASCII @|
	end

	it 'does not allow a block', when_testing: :strict_types do
		refute_runs %|; = a 3 : ASCII (BLOCK a)|
		refute_runs %|; = a (BLOCK QUIT 0) : ASCII a|
	end

	it 'requires exactly one argument', when_testing: :argument_count do
		refute_runs %|ASCII|
		assert_runs %|ASCII 'a'|
	end
end
