section 'OUTPUT' do
	before do
		def assert_stdout(expected, expr)
			assert_equal expected, tester.execute(expr)
		end
	end

	it 'just prints a newline with no string' do
		assert_stdout "\n", %|OUTPUT ""|
	end

	it 'prints normally' do
		assert_stdout "1\n", %|OUTPUT "1"|
		assert_stdout "hello world\n", %|OUTPUT "hello world"|
	end

	it 'prints newlines correctly' do
		assert_stdout "foobar\nbaz\n", %|OUTPUT "foobar\nbaz"|
		assert_stdout "foobar\nbaz\n\n", %|OUTPUT "foobar\nbaz\n"|
	end

	it 'wont print a newline with a trailing `\`' do
		assert_stdout "", %|OUTPUT "\\"|
		assert_stdout "hello", %|OUTPUT "hello\\"|
		assert_stdout "world\n", %|OUTPUT "world\n\\"|
	end

	it 'converts values to a string' do
		assert_stdout "123\n", %|OUTPUT 123|
		assert_stdout "-123\n", %|OUTPUT ~123|
		assert_stdout "true\n", %|OUTPUT TRUE|
		assert_stdout "false\n", %|OUTPUT FALSE|
		assert_stdout "\n", %|OUTPUT NULL|
		assert_stdout "\n", %|OUTPUT @|
		assert_stdout "1\n2\n3\n", %|OUTPUT +@123|
	end

	it 'does not allow blocks or variables as the first operand', when_testing: :strict_types do
		refute_runs %|; = a "3" : OUTPUT BLOCK a|
		refute_runs %|OUTPUT BLOCK QUIT 0|
	end

	it 'requires exactly one argument', when_testing: :argument_count do
		refute_runs %|OUTPUT|
		assert_runs { tester.execute %|OUTPUT "1"| }
	end
end
