require_relative '../shared'

section 'string literal' do
  it 'parses empty strings properly' do
    assert_result '', %|''|
    assert_result '', %|""|
  end

  it 'parses quotes of the other type' do
    assert_result '"', %|'"'|
    assert_result "'", %|"'"|
    assert_result "hello 'world'", %|"hello 'world'"|
    assert_result 'hello "world"', %|'hello "world"'|
  end

  it 'parses normal strings' do
    assert_result 'hello world', %|"hello world"|
    assert_result '0', %|"0"|
    assert_result ' 1234', %|" 1234"|
    assert_result ('x' * 1000), %|"#{"x" * 1000}"|
  end

  it 'accepts newlines, tabs, formfeeds, and carrige returns' do
    assert_result "\n", %|"\n"|
    assert_result "\n", %|'\n'|
    assert_result "hello\nworld", %|"hello\nworld"|
    assert_result "hello\rworld\n", %|"hello\rworld\n"|
    assert_result "hello\r\nworld\n", %|"hello\r\nworld\n"|
    assert_result " \r\n\t\r", %|' \r\n\t\r'|
  end

  it 'does not interpret escape sequences' do
    assert_result '\n', %q|'\n'|
    assert_result '\\', %q|'\\'|
    assert_result 'hello\\', %q|'hello\\'|
    assert_result '\r\n\f\0x45', %q|'\r\n\f\\0x45'|
  end
end
