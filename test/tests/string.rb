require 'minitest'
require 'minitest/spec'
require_relative 'shared'

describe 'String' do
	include Kn::Test::Shared

	describe 'conversions' do
		it 'is falsey when empty' do
			assert_equal false, to_boolean('""')
			assert_equal true, to_boolean('"0"')
			assert_equal true, to_boolean('"1"')
			assert_equal true, to_boolean('"false"')
			assert_equal true, to_boolean('"FALSE"')
			assert_equal true, to_boolean('"hello friend"')
		end

		describe 'integer conversion' do
			it 'strips leading whitespace, and only takes digit characters' do
				assert_equal 0, to_number('""')
				assert_equal 0, to_number('"    "')
				assert_equal 0, to_number('"    x"')
				assert_equal 12, to_number('"    12x34"')
				assert_equal 14, to_number("\"    14\n56\"")
				assert_equal 0, to_number('"    0"')
				assert_equal 0, to_number('"  0000"')
				assert_equal 2349, to_number('"  002349"')
			end

			it 'accepts leading negative and positive signs' do
				assert_equal -34, to_number('"-34"')
				assert_equal -1123, to_number('"  -1123invalid"')
				assert_equal 34, to_number('"+34"')
				assert_equal 1123, to_number('"  +1123invalid"')
			end

			it 'does not interpret `0x...` and other bases' do
				assert_equal 0, to_number('"0x12"')
				assert_equal 0, to_number('" 0x12"')
				assert_equal 0, to_number('"0xag"')
				assert_equal 0, to_number('" 0xag"')

				assert_equal 0, to_number('"0b1101011"')
				assert_equal 0, to_number('" 0b1101011"')
				assert_equal 0, to_number('"0b1102011"')
				assert_equal 0, to_number('" 0b1102011"')

				assert_equal 0, to_number('"0o127"')
				assert_equal 0, to_number('" 0o127"')
				assert_equal 0, to_number('"0o129"')
				assert_equal 0, to_number('" 0o129"')

				assert_equal 127, to_number('"0127"')
				assert_equal 127, to_number('" 0127"')
				assert_equal 129, to_number('"0129"')
				assert_equal 129, to_number('" 0129"')
			end

			it 'ignores decimal and scientific notation' do
				assert_equal 12, to_number('"12.34"')
				assert_equal -12, to_number('"-12.34"')
				assert_equal 12, to_number('"12e4"')
				assert_equal 12, to_number('"12E4"')
			end
		end

		# note that strings are only allowed to contain printable characters.
		describe 'string conversion' do
			it 'is returns its contents, without escaping, when converting to a string' do
				assert_equal "a\nb", to_string("'a\nb'")
				assert_equal '12\x34', to_string('"12\x34"')
				assert_equal '12\\',  to_string('"12\"') # trailing `\` is retained.
				assert_equal '12\\\\',  to_string('"12\\\\"') # '12\\' == '12\\'
			end

			it 'does not convert `\r\n` to `\n`' do
				assert_equal "12\r\na\r\nb", to_string("'12\r\na\r\nb'")
			end

			it 'retains quotes' do
				assert_equal %|'"|, to_string(%|+ "'" '"'|)
				assert_equal %q|\'\"|, to_string(%q|+ "\'" '\"'|)
			end

			it 'converts normal stuff' do # sanity check
				assert_equal "ello, world", to_string('"ello, world"')
				assert_equal "ello\t\n\r\f\vworld", to_string(%("ello\t\n\r\f\vworld"))
				assert_equal "a man a plan a canal panama", to_string("'a man a plan a canal panama'")
			end
		end

	end

	describe 'parsing' do
		it 'parses empty strings' do
			assert_equal '', eval(%|""|)
			assert_equal '', eval(%|''|)
		end

		it 'parses normal single and double quoted strings' do
			assert_equal '0', eval(%|"0"|)
			assert_equal '1', eval(%|'1'|)
			assert_equal 'Epicurus', eval(%|"Epicurus"|)
			assert_equal 'Epicurus', eval(%|'Epicurus'|)
			assert_equal 'to be or not to be, that is FF', eval(%|"to be or not to be, that is FF"|)
			assert_equal 'to be or not to be, that is FF', eval(%|'to be or not to be, that is FF'|)
		end

		it 'allows quotes of the other type' do
			assert_equal %|"|, eval(%|'"'|)
			assert_equal %|a"b|, eval(%|'a"b'|)
			assert_equal %|Then I said: "why not?"|, eval(%|'Then I said: "why not?"'|)

			assert_equal %|'|, eval(%|"'"|)
			assert_equal %|c'd|, eval(%|"c'd"|)
			assert_equal %|And they said I'd get where I'm going|, eval(%|"And they said I'd get where I'm going"|)
		end

		it 'parses newlines' do
			assert_equal %|\n|, eval(%|'\n'|)
			assert_equal %|\n|, eval(%|"\n"|)

			assert_equal %|foo\nbar|, eval(%|'foo\nbar'|)
			assert_equal %|foo\nbar|, eval(%|"foo\nbar"|)

			assert_equal %|foo\r\nbar|, eval(%|'foo\r\nbar'|)
			assert_equal %|foo\r\nbar|, eval(%|"foo\r\nbar"|)
		end

		it 'ignores escapes entirely' do
			# 
			%w(' ").each do |quote|
				%w(\0 \x03 \x0a \n \r \t \f \v \" \' \").each do |escape|
					next if escape == '\\' + quote # skip `\'` when `'` and `\"` when `"`.

					assert_equal escape, eval("#{quote}#{escape}#{quote}")
				end
			end

			# make sure they all are ignored together together
			assert_equal %q|\0\x03\x0a\n\r\n\t\f\v\"\\|, eval(%q|'\0\x03\x0a\n\r\n\t\f\v\"\\'|)
			assert_equal %q|\0\x03\x0a\n\r\n\t\f\v\'\\|, eval(%q|"\0\x03\x0a\n\r\n\t\f\v\'\\"|)
		end
	end

	describe 'operators' do
		describe '4.3.1 +' do
			it 'concatenates' do
				assert_equal "1121a3", eval('+ "112" "1a3"')
				assert_equal "Plato Aristotle", eval('+ "Plato" " Aristotle"')
				assert_equal "Because why not?", eval('++ "Because " "why" " not?"')
			end

			it 'coerces to a string' do
				assert_equal 'truth is true', eval('+ "truth is " TRUE')
				assert_equal 'falsehood is false', eval('+ "falsehood is " FALLSE')
				assert_equal 'it is null and void', eval('++ "it is " NULL " and void"')
				assert_equal 'twelve is 12', eval('+ "twelve is " 12')
			end
		end

		describe '4.3.3 *' do
			it 'duplicates itself with positive integers' do
				assert_equal '', eval('* "" 12')
				assert_equal 'foo', eval('* "foo" 1')
				assert_equal 'a1a1a1a1', eval('* "a1" 4')
				assert_equal 'haihaihaihaihaihaihaihai', eval('* "hai" 8')
			end

			it 'returns an empty string when zero' do
				assert_equal '', eval('* "hi" 0')
				assert_equal '', eval('* "what up?" 0')
			end

			it 'coerces the RHS to a number' do
				assert_equal 'foofoofoo', eval('* "foo" "3"')
				assert_equal 'foo', eval('* "foo" TRUE')
				assert_equal '', eval('* "foo" NULL')
				assert_equal '', eval('* "foo" FALSE')
			end
		end

		describe '4.3.9 ?' do
			it 'is only equal to itself' do
				assert_equal true, eval('? "" ""')
				assert_equal true, eval('? "a" "a"')
				assert_equal true, eval('? "0" "0"')
				assert_equal true, eval('? "1" "1"')
				assert_equal true, eval('? "foobar" "foobar"')
				assert_equal true, eval('? "this is a test" "this is a test"')
				assert_equal true, eval(%|? (+ "'" '"') (+ "'" '"')|)
			end

			it 'is not equal to other strings' do
				assert_equal false, eval('? "" " "')
				assert_equal false, eval('? " " ""')
				assert_equal false, eval('? "a" "A"')
				assert_equal false, eval('? "0" "00"')
				assert_equal false, eval('? "1.0" "1"')
				assert_equal false, eval('? "1" "1.0"')
				assert_equal false, eval('? "0" "0x0"')
				assert_equal false, eval('? "is this a test" "this is a test"')
			end

			it 'is not equal to equivalent types' do
				assert_equal false, eval('? "0" 0')
				assert_equal false, eval('? "1" 1')

				assert_equal false, eval('? "T" TRUE')
				assert_equal false, eval('? "TRUE" TRUE')
				assert_equal false, eval('? "True" TRUE')
				assert_equal false, eval('? "true" TRUE')

				assert_equal false, eval('? "F" FALSE')
				assert_equal false, eval('? "FALSE" FALSE')
				assert_equal false, eval('? "False" FALSE')
				assert_equal false, eval('? "false" FALSE')

				assert_equal false, eval('? "N" NULL')
				assert_equal false, eval('? "NULL" NULL')
				assert_equal false, eval('? "Null" NULL')
				assert_equal false, eval('? "null" NULL')
			end
		end

		describe '4.3.7 <' do
			it 'performs lexicographical comparison' do
				assert_equal true,  eval('< "a" "aa"')
				assert_equal false, eval('< "b" "aa"')

				assert_equal false, eval('< "aa" "a"')
				assert_equal true,  eval('< "aa" "b"')

				assert_equal true,  eval('< "A" "AA"')
				assert_equal false, eval('< "B" "AA"')

				assert_equal false, eval('< "AA" "A"')
				assert_equal true,  eval('< "AA" "B"')

				# ensure it obeys ascii
				assert_equal false, eval('< "a" "A"')
				assert_equal true,  eval('< "A" "a"')
				assert_equal false, eval('< "z" "Z"')
				assert_equal true,  eval('< "Z" "z"')

				assert_equal true, eval('< "/" 0')
				assert_equal true, eval('< "8" 9')

			end

			it 'performs it even with numbers' do
				assert_equal true, eval('< "0" "00"')
				assert_equal true, eval('< "1" "12"')
				assert_equal true, eval('< "100" "12"')
				assert_equal false, eval('< "00" "0"')
				assert_equal false, eval('< "12" "1"')
				assert_equal false, eval('< "12" "100"')

				assert_equal true, eval('< "  0" "  00"')
				assert_equal true, eval('< "  1" "  12"')
				assert_equal true, eval('< "  100" "  12"')
			end

			it 'coerces the RHS to a number' do
				assert_equal true, eval('< "0" 1')
				assert_equal true, eval('< "1" 12')
				assert_equal true, eval('< "100" 12')
				assert_equal false, eval('< "00" 0')
				assert_equal false, eval('< "12" 100')
				assert_equal false, eval('< "12" 100')

				assert_equal true, eval('< "trud" TRUE')
				assert_equal false, eval('< "true" TRUE')
				assert_equal false, eval('< "truf" TRUE')

				assert_equal true, eval('< "falsd" FALSE')
				assert_equal false, eval('< "false" FALSE')
				assert_equal false, eval('< "faslf" FALSE')

				assert_equal true, eval('< "nulk" NULL')
				assert_equal false, eval('< "null" NULL')
				assert_equal false, eval('< "nulm" NULL')
			end
		end

		describe '4.3.8 >' do
			it 'performs lexicographical comparison' do
				assert_equal false, eval('> "a" "aa"')
				assert_equal true,  eval('> "b" "aa"')

				assert_equal true,  eval('> "aa" "a"')
				assert_equal false, eval('> "aa" "b"')

				assert_equal false, eval('> "A" "AA"')
				assert_equal true,  eval('> "B" "AA"')

				assert_equal true,  eval('> "AA" "A"')
				assert_equal false, eval('> "AA" "B"')

				# ensure it obeys ascii
				assert_equal true,  eval('> "a" "A"')
				assert_equal false, eval('> "A" "a"')
				assert_equal true,  eval('> "z" "Z"')
				assert_equal false, eval('> "Z" "z"')

				assert_equal true, eval('> ":" 9')
				assert_equal true, eval('> "1" 0')

			end

			it 'performs it even with numbers' do
				assert_equal false, eval('> "0" "00"')
				assert_equal false, eval('> "1" "12"')
				assert_equal false, eval('> "100" "12"')
				assert_equal true, eval('> "00" "0"')
				assert_equal true, eval('> "12" "1"')
				assert_equal true, eval('> "12" "100"')

				assert_equal false, eval('> "  0" "  00"')
				assert_equal false, eval('> "  1" "  12"')
				assert_equal false, eval('> "  100" "  12"')
			end

			it 'coerces the RHS to a number' do
				assert_equal false, eval('> "0" 1')
				assert_equal false, eval('> "1" 12')
				assert_equal false, eval('> "100" 12')
				assert_equal true, eval('> "00" 0')
				assert_equal true, eval('> "12" 100')
				assert_equal true, eval('> "12" 100')

				assert_equal false, eval('> "trud" TRUE')
				assert_equal false,  eval('> "true" TRUE')
				assert_equal true,  eval('> "truf" TRUE')

				assert_equal false, eval('> "falsd" FALSE')
				assert_equal false,  eval('> "false" FALSE')
				assert_equal true,  eval('> "faslf" FALSE')

				assert_equal false, eval('> "nulk" NULL')
				assert_equal false,  eval('> "null" NULL')
				assert_equal true,  eval('> "nulm" NULL')
			end
		end
	end
end
