describe '4. Function' do
	include Kn::Test::Spec

	describe '4.3.9 ?' do
		describe 'when the first arg is null' do
			it 'equals itself' do
				assert_equal true, eval('? NULL NULL')
			end

			it 'is not equal to other values' do
				assert_equal false, eval('? NULL FALSE')
				assert_equal false, eval('? NULL TRUE')
				assert_equal false, eval('? NULL 0')
				assert_equal false, eval('? NULL ""')
				assert_equal false, eval('? NULL "0"')
				assert_equal false, eval('? NULL "NULL"')
				assert_equal false, eval('? NULL "null"')
			end
		end

		describe 'when the first arg is a boolean' do
			it 'only is equal to itself' do
				assert_equal true, eval('? TRUE TRUE')
				assert_equal true, eval('? FALSE FALSE')
			end

			it 'is not equal to anything else' do
				assert_equal false, eval('? TRUE 1')
				assert_equal false, eval('? TRUE "1"')
				assert_equal false, eval('? TRUE "TRUE"')
				assert_equal false, eval('? TRUE "true"')

				assert_equal false, eval('? FALSE 0')
				assert_equal false, eval('? FALSE ""')
				assert_equal false, eval('? FALSE "0"')
				assert_equal false, eval('? FALSE "FALSE"')
				assert_equal false, eval('? FALSE "false"')
			end
		end

		describe 'when the first arg is a number' do
			it 'is only equal to itself' do
				assert_equal true, eval('? 0 0')
				assert_equal true, eval('? (- 0 0) 0')
				assert_equal true, eval('? 1 1')
				assert_equal true, eval('? (- 0 1) (- 0 1)')
				assert_equal true, eval('? 912 912')
				assert_equal true, eval('? 123 123')
			end

			it 'is not equal to anything else' do
				assert_equal false, eval('? 0 1')
				assert_equal false, eval('? 1 0')
				assert_equal false, eval('? 4 5')
				assert_equal false, eval('? (- 0 4) 4')

				assert_equal false, eval('? 0 FALSE')
				assert_equal false, eval('? 0 NULL')
				assert_equal false, eval('? 0 ""')
				assert_equal false, eval('? 1 TRUE')
				assert_equal false, eval('? 1 "1"')
				assert_equal false, eval('? 1 "1a"')
			end
		end

		describe 'when the first arg is a string' do
			it 'is only equal to itself' do
				assert_equal true, eval('? "" ""')
				assert_equal true, eval('? "a" "a"')
				assert_equal true, eval('? "0" "0"')
				assert_equal true, eval('? "1" "1"')
				assert_equal true, eval('? "foobar" "foobar"')
				assert_equal true, eval('? "this is a test" "this is a test"')
				assert_equal true, eval(%|? (+ "'" '"') (+ "'" '"')|)
			end

			it 'is not equal to other strings' do
				assert_equal false, eval('? "" " "')
				assert_equal false, eval('? " " ""')
				assert_equal false, eval('? "a" "A"')
				assert_equal false, eval('? "0" "00"')
				assert_equal false, eval('? "1.0" "1"')
				assert_equal false, eval('? "1" "1.0"')
				assert_equal false, eval('? "0" "0x0"')
				assert_equal false, eval('? "is this a test" "this is a test"')
			end

			it 'is not equal to equivalent types' do
				assert_equal false, eval('? "0" 0')
				assert_equal false, eval('? "1" 1')

				assert_equal false, eval('? "T" TRUE')
				assert_equal false, eval('? "TRUE" TRUE')
				assert_equal false, eval('? "True" TRUE')
				assert_equal false, eval('? "true" TRUE')

				assert_equal false, eval('? "F" FALSE')
				assert_equal false, eval('? "FALSE" FALSE')
				assert_equal false, eval('? "False" FALSE')
				assert_equal false, eval('? "false" FALSE')

				assert_equal false, eval('? "N" NULL')
				assert_equal false, eval('? "NULL" NULL')
				assert_equal false, eval('? "Null" NULL')
				assert_equal false, eval('? "null" NULL')
			end
		end

		it 'evaluates arguments in order' do
			assert_equal true, eval('? (= n 45) n')
			assert_equal true, eval('? (= n "mhm") n')
			assert_equal true, eval('? (= n TRUE) n')
			assert_equal true, eval('? (= n FALSE) n')
			assert_equal true, eval('? (= n NULL) n')
		end

		it 'only allows null, a boolean, number, or string as the first operand', when_testing: :strict_types do
			assert_fails { eval('; = a 3 : ? (BLOCK a) 3') }
			assert_fails { eval('? (BLOCK QUIT 0) 1') }
		end

		it 'requires exactly two arguments', when_testing: :argument_count do
			assert_fails { eval('?') }
			assert_fails { eval('? 1') }
			assert_fails { eval('? "1"') }
			assert_fails { eval('? TRUE') }
			assert_fails { eval('? FALSE') }
			assert_fails { eval('? NULL') }
			assert_runs  { eval('? 1 1') }
			assert_runs  { eval('? "1" "1"') }
			assert_runs  { eval('? TRUE TRUE') }
			assert_runs  { eval('? FALSE FALSE') }
			assert_runs  { eval('? NULL NULL') }
		end
	end
end
