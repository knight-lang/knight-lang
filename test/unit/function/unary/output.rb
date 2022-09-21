require_relative '../../shared'

section 'OUTPUT' do
	before do
		def assert_output(expected, expr)
			assert_equal expected, exec(expr)
		end
	end

	it 'just prints a newline with no string' do
		assert_output "\n", %|OUTPUT ""|
	end

	it 'prints normally' do
		assert_output "1\n", %|OUTPUT "1"|
		assert_output "hello world\n", %|OUTPUT "hello world"|
	end

	it 'prints newlines correctly' do
		assert_output "foobar\nbaz\n", %|OUTPUT "foobar\nbaz"|
		assert_output "foobar\nbaz\n\n", %|OUTPUT "foobar\nbaz\n"|
	end

	it 'wont print a newline with a trailing `\`' do
		assert_output "", %|OUTPUT "\\"|
		assert_output "hello", %|OUTPUT "hello\\"|
		assert_output "world\n", %|OUTPUT "world\n\\"|
	end

	it 'converts values to a string' do
		assert_output "123\n", %|OUTPUT 123|
		assert_output "-123\n", %|OUTPUT ~123|
		assert_output "true\n", %|OUTPUT TRUE|
		assert_output "false\n", %|OUTPUT FALSE|
		assert_output "\n", %|OUTPUT NULL|
		assert_output "\n", %|OUTPUT @|
		assert_output "1\n2\n3\n", %|OUTPUT +@123|
	end

	it 'does not allow blocks or variables as the first operand', when_testing: :strict_types do
		refute_runs %|; = a "3" : OUTPUT BLOCK a|
		refute_runs %|OUTPUT BLOCK QUIT 0|
	end

	it 'requires exactly one argument', when_testing: :argument_count do
		refute_runs %|OUTPUT|
		assert_runs { exec %|OUTPUT "1"| }
	end
end
