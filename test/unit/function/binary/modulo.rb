require_relative '../../shared'

fail
#TODO: ensure that modulo actually conforms to the `a = (a/b)*b + a%b` requirements

section '%' do
	it 'modulos positive bases normally' do
		assert_result 0, %|% 1 1|
		assert_result 0, %|% 4 4|
		assert_result 0, %|% 15 1|
		assert_result 3, %|% 123 10|
		assert_result 0, %|% 15 3|
		assert_result 2, %|% 14 3|
		assert_result -2, %|% ~14 3|
		assert_result -1, %|% ~4 3|
	end

	it 'converts other values to integers' do
		assert_result 1, %|% 15 "2"|
		assert_result 3, %|% 91 "4"|
		assert_result 0, %|% 9 TRUE|
		assert_result 4, %|% 9 +@12345|
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
		refute_runs %|% 1 @|
	end

	# note that, as per the Knight spec, modulo where either integer is negative is undefined.
	it 'does not allow for negative integers for the second operand', when_testing: :invalid_values do
		refute_runs %|% 1 ~1|
		refute_runs %|% 5 ~123|
		refute_runs %|% 99 ~123|
	end

	it 'only allows an integer as the first operand', when_testing: :invalid_types do
		refute_runs %|% TRUE 1|
		refute_runs %|% FALSE 1|
		refute_runs %|% NULL 1|
		refute_runs %|% "not-a-integer" 1|
		refute_runs %|% "123" 1| # ie a numeric string
		refute_runs %|% +@123 1|
	end

	it 'does not allow a block as any operand', when_testing: :strict_types do
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
