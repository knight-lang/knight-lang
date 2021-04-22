require_relative '../function-spec'

section '4.3.12', ';' do
	include Kn::Test::Spec

	it 'executes arguments in order' do
		assert_equal 3, eval('; (= a 3) a')
	end

	it 'returns the second argument' do
		assert_equal 1, eval('; 0 1')
	end

	it 'also works with BLOCK return values' do
		assert_equal 3, eval('CALL ; = a 3 BLOCK a')
	end

	it 'accepts blocks as either argument' do
		assert_equal 3, eval('; (BLOCK QUIT 1) 3')
		assert_equal 4, eval('CALL ; 3 (BLOCK 4)')
	end

	#test_argument_count ';', '1', '2'
end
