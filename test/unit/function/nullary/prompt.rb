require_relative '../../shared'

section 'PROMPT' do
	it 'should read a line from stdin' do
		assert_result "foo", %|PROMPT|, stdin: "foo"
		assert_result "foo", %|PROMPT|, stdin: "foo\nbar"
		assert_result "foo", %|PROMPT|, stdin: "foo\nbar\nbaz"
	end

	it 'should strip trailing `\r` and `\r\n`' do
		assert_result "foo", %|PROMPT|, stdin: "foo\n"
		assert_result "foo", %|PROMPT|, stdin: "foo\nbar"
		assert_result "foo", %|PROMPT|, stdin: "foo\r\nbar"
	end

	it 'should not strip a lone trailing `\r`' do
		assert_result "foo\r", %|PROMPT|, stdin: "foo\r"
	end

	it 'should be able to read multiple lines' do
		assert_result "foo:bar:baz", %|++++ PROMPT ":" PROMPT ":" PROMPT|, stdin: "foo\nbar\r\nbaz\n"
	end

	it 'should return an empty string for empty lines' do
		assert_result "", %|+ PROMPT PROMPT|, stdin: "\n\r\nx"
	end

	it 'should return NULL at EOF' do
		assert_result :null, %|PROMPT|, stdin: ""
	end
end
