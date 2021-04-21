require_relative '../function-spec'

section '4.3.12', ';' do
	include Kn::Test::Spec

	it 'executes arguments in order' do
		assert_equal 3, evaluate('; (= a 3) a')
	end

	it 'returns the second argument' do
		assert_equal 1, evaluate('; 0 1')
	end

	it 'also works with BLOCK return values' do
		assert_equal 3, evaluate('CALL ; = a 3 BLOCK a')
	end

	it 'accepts blocks as either argument' do
		assert_equal 3, evaluate('; (BLOCK QUIT 1) 3')
		assert_equal 4, evaluate('CALL ; 3 (BLOCK 4)')
	end

	test_argument_count ';', '1', '2'
end
