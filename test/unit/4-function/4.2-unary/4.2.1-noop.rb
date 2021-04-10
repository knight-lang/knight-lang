require_relative '../function-spec'

section '4.2.1', ':' do
	it 'simply returns its argument' do
		assert_equal 4, eval(': 4')
		assert_equal "hi", eval(': "hi"')
		assert_equal true, eval(': TRUE')
		assert_equal false, eval(': FALSE')
		assert_equal :null, eval(': NULL')
	end

	it 'also works with BLOCK return values' do
		assert_equal 3, eval('; = a 3 CALL : BLOCK a ')
		assert_equal 5, eval('; = a 3 CALL : BLOCK + a 2')
	end

	test_argument_count ':', '1'
end
