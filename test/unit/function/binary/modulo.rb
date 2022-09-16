require_relative '../shared'

section '%' do
	it 'modulos positive numbers normally' do
		assert_result 0, %|% 1 1|
		assert_result 0, %|% 4 4|
		assert_result 0, %|% 15 1|
		assert_result 3, %|% 123 10|
		assert_result 0, %|% 15 3|
	end

	it 'converts other values to integers' do
		assert_result 1, %|% 15 "2"|
		assert_result 3, %|% 91 "4"|
		assert_result 0, %|% 9 TRUE|
	end

	it 'evaluates arguments in order' do
		assert_result 5, %|% (= n 45) (- n 35)|
		assert_result 7, %|% (= n 17) (- n 7)|
		assert_result 4, %|% (= n 15) (- n 4)|
	end

	it 'does not modulo by zero', when_testing: :zero_division do
		refute_runs %|% 1 0|
		refute_runs %|% 100 0|
		refute_runs %|% 1 FALSE|
		refute_runs %|% 1 NULL|
	end

	# note that, as per the Knight spec, modulo where either number is negative is undefined.
	it 'does not allow for negative numbers anywhere', when_testing: :invalid_values do
		refute_runs %|% 1 ~1|
		refute_runs %|% ~1 1|
		refute_runs %|% ~1 ~1|
	end

	it 'only allows a number as the first operand', when_testing: :invalid_types do
		refute_runs %|% TRUE 1|
		refute_runs %|% FALSE 1|
		refute_runs %|% NULL 1|
		refute_runs %|% "not-a-number" 1|
		refute_runs %|% "123" 1| # ie a numeric string
	end

	it 'does not allow a function or variable as any operand', when_testing: :strict_types do
		refute_runs %|; = a 3 : % (BLOCK a) 1|
		refute_runs %|; = a 3 : % 1 (BLOCK a)|
		refute_runs %|% (BLOCK QUIT 0) 1|
		refute_runs %|% 1 (BLOCK QUIT 0)|
	end

	it 'requires exactly two arguments', when_testing: :argument_count do
		refute_runs %|%|
		refute_runs %|% 1|
		assert_runs %|% 1 1|
	end
end
