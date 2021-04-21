require_relative '../function-spec'

section '4.2.8', 'L' do
	include Kn::Test::Spec

	it 'performs under normal conditions' do
		assert_equal 3, evaluate('LENGTH "foo"')
		assert_equal 27, evaluate('LENGTH "a man a plan a canal panama"')
		assert_equal 21, evaluate('LENGTH "and then I questioned"')
		assert_equal 100, evaluate("LENGTH '#{'x' * 100}'")
	end

	it 'returns 0 for empty strings' do
		assert_equal 0, evaluate('LENGTH ""')
	end

	it 'does not coerce its argument to a number and back' do
		assert_equal 2, evaluate('LENGTH "-0"')
		assert_equal 5, evaluate('LENGTH "49.12"')
	end

	it 'works with multiline strings.' do
		assert_equal 10, evaluate("LENGTH 'fooba\nrbaz'")
	end

	it 'converts its value to a string' do
		assert_equal 1, evaluate('LENGTH 0')
		assert_equal 3, evaluate('LENGTH 923')
		assert_equal 4, evaluate('LENGTH TRUE')
		assert_equal 5, evaluate('LENGTH FALSE')
		assert_equal 4, evaluate('LENGTH NULL')
	end

	test_argument_count 'LENGTH', '"hi"'
end
