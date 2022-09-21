require_relative '../../shared'

section 'IF' do
	it 'executes and returns only the correct value' do
		assert_result 12, %|IF TRUE 12 (QUIT 1)|
		assert_result 12, %|IF FALSE (QUIT 1) 12|
	end

	it 'executes the condition before the result' do
		assert_result 12, %|IF (= a 3) (+ a 9) (QUIT 1)|
	end

	it 'converts values to a boolean' do
		assert_result 12, %|IF 123 12 (QUIT 1)|
		assert_result 12, %|IF 0 (QUIT 1) 12 |
		assert_result 12, %|IF "123" 12 (QUIT 1)|
		assert_result 12, %|IF "0" 12 (QUIT 1)|
		assert_result 12, %|IF "" (QUIT 1) 12|
		assert_result 12, %|IF NULL (QUIT 1) 12|
		assert_result 12, %|IF @ (QUIT 1) 12|
		assert_result 12, %|IF +@0 12 (QUIT 1)|
	end

	it 'accepts blocks as either the second or third argument' do
		assert_runs %|IF TRUE (BLOCK QUIT 1) (QUIT 1)|
		assert_runs %|IF FALSE (QUIT 1) (BLOCK QUIT 1)|
	end

	it 'does not accept BLOCK values as the condition', when_testing: :strict_types do
		refute_runs %|IF (BLOCK QUIT 0) 0 0|
		refute_runs %|; = a 3 : IF (BLOCK a) 0 0|
	end

	it 'requires exactly three arguments', when_testing: :argument_count do
		refute_runs %|IF|
		refute_runs %|IF TRUE|
		refute_runs %|IF TRUE 1|
		assert_runs %|IF TRUE 1 2|
	end
end
