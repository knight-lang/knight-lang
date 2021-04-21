require_relative '../function-spec'
require_relative '../../../autorun' if $0 == __FILE__

section '4.2.1', ':' do
	it 'simply returns its argument' do
		assert_equal 4, evaluate(': 4')
		assert_equal "hi", evaluate(': "hi"')
		assert_equal true, evaluate(': TRUE')
		assert_equal false, evaluate(': FALSE')
		assert_equal :null, evaluate(': NULL')
	end

	it 'also works with BLOCK return values' do
		assert_equal 3, evaluate('; = a 3 CALL : BLOCK a ')
		assert_equal 5, evaluate('; = a 3 CALL : BLOCK + a 2')
	end

	test_argument_count ':', '1'
end
