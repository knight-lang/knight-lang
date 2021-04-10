require_relative '../shared'

section '4.2.8', :LENGTH do
	it 'performs under normal conditions' do
		assert_equal 3, eval('LENGTH "foo"')
		assert_equal 27, eval('LENGTH "a man a plan a canal panama"')
		assert_equal 21, eval('LENGTH "and then I questioned"')
		assert_equal 100, eval("LENGTH '#{'x' * 100}'")
	end

	it 'returns 0 for empty strings' do
		assert_equal 0, eval('LENGTH ""')
	end

	it 'does not coerce its argument to a number and back' do
		assert_equal 2, eval('LENGTH "-0"')
		assert_equal 5, eval('LENGTH "49.12"')
	end

	it 'works with multiline strings.' do
		assert_equal 10, eval("LENGTH 'fooba\nrbaz'")
	end

	it 'converts its value to a string' do
		assert_equal 1, eval('LENGTH 0')
		assert_equal 3, eval('LENGTH 923')
		assert_equal 4, eval('LENGTH TRUE')
		assert_equal 5, eval('LENGTH FALSE')
		assert_equal 4, eval('LENGTH NULL')
	end
end