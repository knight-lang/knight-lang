describe '4. Function' do
	include Kn::Test::Spec

	describe '4.3.6 ^' do
		it 'raises positive numbers correctly' do
			assert_equal 1, eval('^ 1 1')
			assert_equal 1, eval('^ 1 100')
			assert_equal 16, eval('^ 2 4')
			assert_equal 125, eval('^ 5 3')
			assert_equal 3375, eval('^ 15 3')
			assert_equal 15129, eval('^ 123 2')
		end

		it 'returns 0 when the base is zero, unless the power is zero' do
			assert_equal 0, eval('^ 0 1')
			assert_equal 0, eval('^ 0 100')
			assert_equal 0, eval('^ 0 4')
			assert_equal 0, eval('^ 0 3')
		end

		it 'returns 1 when raising to the power of 0' do
			assert_equal 1, eval('^ 1 0')
			assert_equal 1, eval('^ 100 0')
			assert_equal 1, eval('^ 4 0')
			assert_equal 1, eval('^ 3 0')
			assert_equal 1, eval('^ (- 0 3) 0')
		end

		# Since we only have integral types, anything (normal) raised to a negative number is zero.
		it 'always returns zero when a > 1 number is raised to a negative power' do
			assert_equal 0, eval('^ 2 (- 0 2)')
			assert_equal 0, eval('^ 100 (- 0 2)')
			assert_equal 0, eval('^ 4 (- 0 2)')
			assert_equal 0, eval('^ 3 (- 0 2)')
			assert_equal 0, eval('^ (- 0 3) (- 0 2)')
		end

		it 'returns a negative number when a negative number is raised ot an odd power' do
			assert_equal -1, eval('^ (- 0 1) 1')
			assert_equal -8, eval('^ (- 0 2) 3')
			assert_equal 16, eval('^ (- 0 2) 4')
			assert_equal -32, eval('^ (- 0 2) 5')
			assert_equal 100, eval('^ (- 0 10) 2')
			assert_equal -1331, eval('^ (- 0 11) 3')
			assert_equal 20736, eval('^ (- 0 12) 4')
		end

		it 'handles one, zero, and negative one properly' do
			assert_equal 0, eval('^ 0 3')
			assert_equal 0, eval('^ 0 2')
			assert_equal 0, eval('^ 0 1')
			assert_equal 1, eval('^ 0 0')
			# 0 to a negative power is undefined.

			assert_equal 1, eval('^ 1 3')
			assert_equal 1, eval('^ 1 2')
			assert_equal 1, eval('^ 1 1')
			assert_equal 1, eval('^ 1 0')
			assert_equal 1, eval('^ 1 (- 0 1)')
			assert_equal 1, eval('^ 1 (- 0 2)')
			assert_equal 1, eval('^ 1 (- 0 3)')

			assert_equal -1, eval('^ (- 0 1) 3')
			assert_equal 1, eval('^ (- 0 1) 2')
			assert_equal -1, eval('^ (- 0 1) 1')
			assert_equal 1, eval('^ (- 0 1) 0')
			assert_equal -1, eval('^ (- 0 1) (- 0 1)')
			assert_equal 1, eval('^ (- 0 1) (- 0 2)')
			assert_equal -1, eval('^ (- 0 1) (- 0 3)')
		end

		it 'converts other values to integers' do
			assert_equal 225, eval('^ 15 "2"')
			assert_equal 1, eval('^ 91 FALSE')
			assert_equal 1, eval('^ 91 NULL')
			assert_equal 9, eval('^ 9 TRUE')
		end


		it 'evaluates arguments in order' do
			assert_equal 91125, eval('^ (= n 45) (- n 42)')
			assert_equal 15, eval('^ (= n 15) (- n 14)')
			assert_equal 0, eval('^ (= n 15) (- n 16)')
		end

		it 'does not allow 0 to be raised to a negative power', when_testing: :zero_division do
			assert_fails { eval('^ (- 0 1) 0') }
			assert_fails { eval('^ 100 0') }
			assert_fails { eval('^ 1 FALSE') }
			assert_fails { eval('^ 1 NULL') }
		end

		it 'only allows a number as the first operand', when_testing: :invalid_types do
			assert_fails { eval('^ TRUE 1') }
			assert_fails { eval('^ FALSE 1') }
			assert_fails { eval('^ NULL 1') }
			assert_fails { eval('^ "not-a-number" 1') }
			assert_fails { eval('^ "123" 1') } # ie a numeric string

			if testing? :strict_types
				assert_fails { eval('; = a 3 : ^ (BLOCK a) 1') }
				assert_fails { eval('^ (BLOCK QUIT 0) 1') }
			end
		end

		it 'requires exactly two arguments', when_testing: :argument_count do
			assert_fails { eval('^') }
			assert_fails { eval('^ 1') }
			assert_runs  { eval('^ 1 1') }
		end
	end
end