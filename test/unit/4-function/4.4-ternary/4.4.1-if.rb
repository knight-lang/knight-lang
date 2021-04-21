require_relative '../function-spec'

section '4.4.1', 'IF' do
	include Kn::Test::Spec

	it 'only executes and returns the second argument if the condition is truthy' do
		assert_equal 12, evaluate('IF 1 12 (QUIT 1)')
	end

	it 'only executes and returns the third argument if the condition is falsey' do
		assert_equal 12, evaluate('IF NULL (QUIT 1) 12')
	end

	it 'executes the condition before the result' do
		assert_equal 12, evaluate('IF (= a 3) (+ a 9) (QUIT 1)')
	end

	it 'does not accept BLOCK values as the condition', when_testing: :strict_types do
		assert_fails { evaluate('IF (BLOCK QUIT 0) 0 0') }
		assert_fails { evaluate('; = a 3 : IF (BLOCK a) 0 0') }
	end

	test_argument_count 'IF', '1', '2', '3'
end
