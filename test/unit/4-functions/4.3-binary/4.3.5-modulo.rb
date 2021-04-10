describe '4. Function' do
	include Kn::Test::Spec

	describe '4.3.5 %' do
		it 'modulos positive numbers normally' do
			assert_equal 0, eval('% 1 1')
			assert_equal 0, eval('% 4 4')
			assert_equal 0, eval('% 15 1')
			assert_equal 3, eval('% 123 10')
			assert_equal 0, eval('% 15 3')
		end

		it 'converts other values to integers' do
			assert_equal 1, eval('% 15 "2"')
			assert_equal 3, eval('% 91 "4"')
			assert_equal 0, eval('% 9 TRUE')
		end

		it 'evaluates arguments in order' do
			assert_equal 5, eval('% (= n 45) (- n 35)')
			assert_equal 7, eval('% (= n 17) (- n 7)')
			assert_equal 4, eval('% (= n 15) (- n 4)')
		end

		it 'does not modulo by zero', when_testing: :zero_division do
			assert_fails { eval('% 1 0') }
			assert_fails { eval('% 100 0') }
			assert_fails { eval('% 1 FALSE') }
			assert_fails { eval('% 1 NULL') }
		end

		# note that, as per the Knight spec, modulo where either number is negative is undefined.
		it 'does not allow for negative numbers anywhere', when_testing: :invalid_value do
			assert_fails { eval('% 1 (- 0 1)') }
			assert_fails { eval('% (- 0 1) 1') }
			assert_fails { eval('% (- 0 1) (- 0 1)') }
		end

		it 'only allows a number as the first operand', when_testing: :invalid_types do
			assert_fails { eval('% TRUE 1') }
			assert_fails { eval('% FALSE 1') }
			assert_fails { eval('% NULL 1') }
			assert_fails { eval('% "not-a-number" 1') }
			assert_fails { eval('% "123" 1') } # ie a numeric string

			if testing? :strict_types
				assert_fails { eval('; = a 3 : % (BLOCK a) 1') }
				assert_fails { eval('% (BLOCK QUIT 0) 1') }
			end
		end

		it 'requires exactly two arguments', when_testing: :argument_count do
			assert_fails { eval('%') }
			assert_fails { eval('% 1') }
			assert_runs  { eval('% 1 1') }
		end
	end
end