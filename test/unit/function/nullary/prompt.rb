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

	it 'should not strip trailing `\r`s' do
		assert_result "foo", %|PROMPT|, stdin: "foo\r\n"
		assert_result "foo\r\r\r", %|PROMPT|, stdin: "foo\r\r\r\r\n"
		assert_result "foo", %|PROMPT|, stdin: "foo\r\nhello"
		assert_result "foo\r\r\r", %|PROMPT|, stdin: "foo\r\r\r\r\nhello"
		assert_result "foo", %|PROMPT|, stdin: "foo\r"
		assert_result "foo\r\r\r", %|PROMPT|, stdin: "foo\r\r\r\r"
	end

	it 'does not strip `\r`s in the middle, or consider them end of line'do
		assert_result "foo\rhello", %|PROMPT|, stdin: "foo\rhello"
		assert_result "foo\rhello", %|PROMPT|, stdin: "foo\rhello\n"
		assert_result "foo\rhello", %|PROMPT|, stdin: "foo\rhello\r\n"
		assert_result "foo\r\r\r\rhello", %|PROMPT|, stdin: "foo\r\r\r\rhello"
		assert_result "foo\r\r\r\rhello", %|PROMPT|, stdin: "foo\r\r\r\rhello\n"
		assert_result "foo\r\r\r\rhello", %|PROMPT|, stdin: "foo\r\r\r\rhello\r\n"
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
