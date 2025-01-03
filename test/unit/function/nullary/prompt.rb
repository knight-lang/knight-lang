section 'PROMPT' do
	it 'should read a line from stdin, and strip `\n`' do
		assert_result "foo", %|PROMPT|, stdin: "foo\n"
		assert_result "foo", %|PROMPT|, stdin: "foo\nbar"
		assert_result "foo", %|PROMPT|, stdin: "foo\nbar\nbaz"
	end

	it 'should strip `\r\n`s as well' do
		assert_result "foo", %|PROMPT|, stdin: "foo\r\n"
		assert_result "foo", %|PROMPT|, stdin: "foo\r\nbar"
		assert_result "bar", %|; PROMPT PROMPT|, stdin: "foo\nbar\r\n"
	end

	it 'should not strip a `\n` if the final line doesnt have one' do
		assert_result "foo", %|PROMPT|, stdin: "foo"
		assert_result "bar", %|; PROMPT PROMPT|, stdin: "foo\nbar"
	end

	it 'should not consider `\r` as a newline' do
		assert_result "foo\rbar", %|PROMPT|, stdin: "foo\rbar"
		assert_result "foo\rbar", %|PROMPT|, stdin: "foo\rbar\nbaz"
	end

	it 'should only strip the last `\r` within `\r\n` sequences' do
		assert_result "foo",     %|PROMPT|, stdin: "foo"
		assert_result "foo",     %|PROMPT|, stdin: "foo\nbar"
		assert_result "foo",     %|PROMPT|, stdin: "foo\r\nbar"
		assert_result "foo\r",   %|PROMPT|, stdin: "foo\r\r\nbar"
		assert_result "foo\r\r", %|PROMPT|, stdin: "foo\r\r\r\nbar"
	end

	it 'should not consider `\r` in the middle of a line as a newline' do
		assert_result "foo\rbar",   %|PROMPT|, stdin: "foo\rbar"
		assert_result "foo\rbar",   %|PROMPT|, stdin: "foo\rbar\nbaz"
		assert_result "foo\rbar",   %|PROMPT|, stdin: "foo\rbar\r\nbaz"
		assert_result "foo\rbar\r", %|PROMPT|, stdin: "foo\rbar\r\r\nbaz"
	end

	it 'should strip a final `\r` if it exists' do
		assert_result "foo",   %|PROMPT|, stdin: "foo\r"
		assert_result "foo\r", %|PROMPT|, stdin: "foo\r\r"
	end

	it 'should be able to read multiple lines' do
		assert_result "foo:bar:baz", %|++++ PROMPT ":" PROMPT ":" PROMPT|, stdin: "foo\nbar\r\nbaz\n"
	end

	it 'should return an empty string for empty lines' do
		assert_result "", %|+ PROMPT PROMPT|, stdin: "\n\r\nx"
	end

	it 'should return NULL at EOF' do
		assert_result :null, %|PROMPT|, stdin: ""
		assert_result :null, %|; PROMPT PROMPT|, stdin: "foobar\r\n"
		assert_result :null, %|; PROMPT PROMPT|, stdin: "foobar\n"
	end
end
