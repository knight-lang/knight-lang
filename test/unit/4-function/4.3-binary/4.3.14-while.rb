require_relative '../function-spec'

section '4.3.14', 'WHILE' do
	include Kn::Test::Spec

	it 'returns null' do
		assert_equal :null, eval('WHILE 0 0')
	end

	it 'will not eval the body if the condition is true' do
		assert_equal 12, eval('; WHILE FALSE (QUIT 1) : 12')
	end

	it 'will eval the body until the condition is false' do
		assert_equal 55, eval(<<-EOS)
			; = i 0
			; = sum 0
			; WHILE (< i 10)
				; = sum + sum i
				: = i + i 1
			: sum
		EOS
	end

	it 'does not accept BLOCK values', when_testing: :strict_types do
		assert_fails { eval('; = a 0 : WHILE (BLOCK a) 1') }
		assert_fails { eval('; = a 0 : WHILE 1 (BLOCK a)') }
		assert_fails { eval('WHILE (BLOCK QUIT 0) 1') }
		assert_fails { eval('WHILE 1 (BLOCK QUIT 0)') }
	end

	#test_argument_count 'W', '0', '2'
end