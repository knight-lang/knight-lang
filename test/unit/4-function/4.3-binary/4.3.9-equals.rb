require_relative '../function-spec'

section '4.3.9', '?' do
	include Kn::Test::Spec

	describe 'when the first arg is null' do
		it 'equals itself' do
			assert_equal true, evaluate('? NULL NULL')
		end

		it 'is not equal to other values' do
			assert_equal false, evaluate('? NULL FALSE')
			assert_equal false, evaluate('? NULL TRUE')
			assert_equal false, evaluate('? NULL 0')
			assert_equal false, evaluate('? NULL ""')
			assert_equal false, evaluate('? NULL "0"')
			assert_equal false, evaluate('? NULL "NULL"')
			assert_equal false, evaluate('? NULL "null"')
		end
	end

	describe 'when the first arg is a boolean' do
		it 'only is equal to itself' do
			assert_equal true, evaluate('? TRUE TRUE')
			assert_equal true, evaluate('? FALSE FALSE')
		end

		it 'is not equal to anything else' do
			assert_equal false, evaluate('? TRUE 1')
			assert_equal false, evaluate('? TRUE "1"')
			assert_equal false, evaluate('? TRUE "TRUE"')
			assert_equal false, evaluate('? TRUE "true"')

			assert_equal false, evaluate('? FALSE 0')
			assert_equal false, evaluate('? FALSE ""')
			assert_equal false, evaluate('? FALSE "0"')
			assert_equal false, evaluate('? FALSE "FALSE"')
			assert_equal false, evaluate('? FALSE "false"')
		end
	end

	describe 'when the first arg is a number' do
		it 'is only equal to itself' do
			assert_equal true, evaluate('? 0 0')
			assert_equal true, evaluate('? (- 0 0) 0')
			assert_equal true, evaluate('? 1 1')
			assert_equal true, evaluate('? (- 0 1) (- 0 1)')
			assert_equal true, evaluate('? 912 912')
			assert_equal true, evaluate('? 123 123')
		end

		it 'is not equal to anything else' do
			assert_equal false, evaluate('? 0 1')
			assert_equal false, evaluate('? 1 0')
			assert_equal false, evaluate('? 4 5')
			assert_equal false, evaluate('? (- 0 4) 4')

			assert_equal false, evaluate('? 0 FALSE')
			assert_equal false, evaluate('? 0 NULL')
			assert_equal false, evaluate('? 0 ""')
			assert_equal false, evaluate('? 1 TRUE')
			assert_equal false, evaluate('? 1 "1"')
			assert_equal false, evaluate('? 1 "1a"')
		end
	end

	describe 'when the first arg is a string' do
		it 'is only equal to itself' do
			assert_equal true, evaluate('? "" ""')
			assert_equal true, evaluate('? "a" "a"')
			assert_equal true, evaluate('? "0" "0"')
			assert_equal true, evaluate('? "1" "1"')
			assert_equal true, evaluate('? "foobar" "foobar"')
			assert_equal true, evaluate('? "this is a test" "this is a test"')
			assert_equal true, evaluate(%|? (+ "'" '"') (+ "'" '"')|)
		end

		it 'is not equal to other strings' do
			assert_equal false, evaluate('? "" " "')
			assert_equal false, evaluate('? " " ""')
			assert_equal false, evaluate('? "a" "A"')
			assert_equal false, evaluate('? "0" "00"')
			assert_equal false, evaluate('? "1.0" "1"')
			assert_equal false, evaluate('? "1" "1.0"')
			assert_equal false, evaluate('? "0" "0x0"')
			assert_equal false, evaluate('? "is this a test" "this is a test"')
		end

		it 'is not equal to equivalent types' do
			assert_equal false, evaluate('? "0" 0')
			assert_equal false, evaluate('? "1" 1')

			assert_equal false, evaluate('? "T" TRUE')
			assert_equal false, evaluate('? "TRUE" TRUE')
			assert_equal false, evaluate('? "True" TRUE')
			assert_equal false, evaluate('? "true" TRUE')

			assert_equal false, evaluate('? "F" FALSE')
			assert_equal false, evaluate('? "FALSE" FALSE')
			assert_equal false, evaluate('? "False" FALSE')
			assert_equal false, evaluate('? "false" FALSE')

			assert_equal false, evaluate('? "N" NULL')
			assert_equal false, evaluate('? "NULL" NULL')
			assert_equal false, evaluate('? "Null" NULL')
			assert_equal false, evaluate('? "null" NULL')
		end
	end

	it 'evaluates arguments in order' do
		assert_equal true, evaluate('? (= n 45) n')
		assert_equal true, evaluate('? (= n "mhm") n')
		assert_equal true, evaluate('? (= n TRUE) n')
		assert_equal true, evaluate('? (= n FALSE) n')
		assert_equal true, evaluate('? (= n NULL) n')
	end

	it 'only allows null, a boolean, number, or string as the first operand', when_testing: :strict_types do
		assert_fails { evaluate('; = a 3 : ? (BLOCK a) 3') }
		assert_fails { evaluate('? (BLOCK QUIT 0) 1') }
	end

	test_argument_count '?', '1', '2'
end
