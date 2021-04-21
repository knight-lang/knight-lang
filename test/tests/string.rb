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
			assert_equal '', evaluate(%|""|)
			assert_equal '', evaluate(%|''|)
		end

		it 'parses normal single and double quoted strings' do
			assert_equal '0', evaluate(%|"0"|)
			assert_equal '1', evaluate(%|'1'|)
			assert_equal 'Epicurus', evaluate(%|"Epicurus"|)
			assert_equal 'Epicurus', evaluate(%|'Epicurus'|)
			assert_equal 'to be or not to be, that is FF', evaluate(%|"to be or not to be, that is FF"|)
			assert_equal 'to be or not to be, that is FF', evaluate(%|'to be or not to be, that is FF'|)
		end

		it 'allows quotes of the other type' do
			assert_equal %|"|, evaluate(%|'"'|)
			assert_equal %|a"b|, evaluate(%|'a"b'|)
			assert_equal %|Then I said: "why not?"|, evaluate(%|'Then I said: "why not?"'|)

			assert_equal %|'|, evaluate(%|"'"|)
			assert_equal %|c'd|, evaluate(%|"c'd"|)
			assert_equal %|And they said I'd get where I'm going|, evaluate(%|"And they said I'd get where I'm going"|)
		end

		it 'parses newlines' do
			assert_equal %|\n|, evaluate(%|'\n'|)
			assert_equal %|\n|, evaluate(%|"\n"|)

			assert_equal %|foo\nbar|, evaluate(%|'foo\nbar'|)
			assert_equal %|foo\nbar|, evaluate(%|"foo\nbar"|)

			assert_equal %|foo\r\nbar|, evaluate(%|'foo\r\nbar'|)
			assert_equal %|foo\r\nbar|, evaluate(%|"foo\r\nbar"|)
		end

		it 'ignores escapes entirely' do
			# 
			%w(' ").each do |quote|
				%w(\0 \x03 \x0a \n \r \t \f \v \" \' \").each do |escape|
					next if escape == '\\' + quote # skip `\'` when `'` and `\"` when `"`.

					assert_equal escape, evaluate("#{quote}#{escape}#{quote}")
				end
			end

			# make sure they all are ignored together together
			assert_equal %q|\0\x03\x0a\n\r\n\t\f\v\"\\|, evaluate(%q|'\0\x03\x0a\n\r\n\t\f\v\"\\'|)
			assert_equal %q|\0\x03\x0a\n\r\n\t\f\v\'\\|, evaluate(%q|"\0\x03\x0a\n\r\n\t\f\v\'\\"|)
		end
	end

	describe 'operators' do
		describe '4.3.1 +' do
			it 'concatenates' do
				assert_equal "1121a3", evaluate('+ "112" "1a3"')
				assert_equal "Plato Aristotle", evaluate('+ "Plato" " Aristotle"')
				assert_equal "Because why not?", evaluate('++ "Because " "why" " not?"')
			end

			it 'coerces to a string' do
				assert_equal 'truth is true', evaluate('+ "truth is " TRUE')
				assert_equal 'falsehood is false', evaluate('+ "falsehood is " FALLSE')
				assert_equal 'it is null and void', evaluate('++ "it is " NULL " and void"')
				assert_equal 'twelve is 12', evaluate('+ "twelve is " 12')
			end
		end

		describe '4.3.3 *' do
			it 'duplicates itself with positive integers' do
				assert_equal '', evaluate('* "" 12')
				assert_equal 'foo', evaluate('* "foo" 1')
				assert_equal 'a1a1a1a1', evaluate('* "a1" 4')
				assert_equal 'haihaihaihaihaihaihaihai', evaluate('* "hai" 8')
			end

			it 'returns an empty string when zero' do
				assert_equal '', evaluate('* "hi" 0')
				assert_equal '', evaluate('* "what up?" 0')
			end

			it 'coerces the RHS to a number' do
				assert_equal 'foofoofoo', evaluate('* "foo" "3"')
				assert_equal 'foo', evaluate('* "foo" TRUE')
				assert_equal '', evaluate('* "foo" NULL')
				assert_equal '', evaluate('* "foo" FALSE')
			end
		end

		describe '4.3.9 ?' do
			it 'is only equal to itself' do
				assert_equal true, evaluate('? "" ""')
				assert_equal true, evaluate('? "a" "a"')
				assert_equal true, evaluate('? "0" "0"')
				assert_equal true, evaluate('? "1" "1"')
				assert_equal true, evaluate('? "foobar" "foobar"')
				assert_equal true, evaluate('? "this is a test" "this is a test"')
				assert_equal true, evaluate(%|? (+ "'" '"') (+ "'" '"')|)
			end

			it 'is not equal to other strings' do
				assert_equal false, evaluate('? "" " "')
				assert_equal false, evaluate('? " " ""')
				assert_equal false, evaluate('? "a" "A"')
				assert_equal false, evaluate('? "0" "00"')
				assert_equal false, evaluate('? "1.0" "1"')
				assert_equal false, evaluate('? "1" "1.0"')
				assert_equal false, evaluate('? "0" "0x0"')
				assert_equal false, evaluate('? "is this a test" "this is a test"')
			end

			it 'is not equal to equivalent types' do
				assert_equal false, evaluate('? "0" 0')
				assert_equal false, evaluate('? "1" 1')

				assert_equal false, evaluate('? "T" TRUE')
				assert_equal false, evaluate('? "TRUE" TRUE')
				assert_equal false, evaluate('? "True" TRUE')
				assert_equal false, evaluate('? "true" TRUE')

				assert_equal false, evaluate('? "F" FALSE')
				assert_equal false, evaluate('? "FALSE" FALSE')
				assert_equal false, evaluate('? "False" FALSE')
				assert_equal false, evaluate('? "false" FALSE')

				assert_equal false, evaluate('? "N" NULL')
				assert_equal false, evaluate('? "NULL" NULL')
				assert_equal false, evaluate('? "Null" NULL')
				assert_equal false, evaluate('? "null" NULL')
			end
		end

		describe '4.3.7 <' do
			it 'performs lexicographical comparison' do
				assert_equal true,  evaluate('< "a" "aa"')
				assert_equal false, evaluate('< "b" "aa"')

				assert_equal false, evaluate('< "aa" "a"')
				assert_equal true,  evaluate('< "aa" "b"')

				assert_equal true,  evaluate('< "A" "AA"')
				assert_equal false, evaluate('< "B" "AA"')

				assert_equal false, evaluate('< "AA" "A"')
				assert_equal true,  evaluate('< "AA" "B"')

				# ensure it obeys ascii
				assert_equal false, evaluate('< "a" "A"')
				assert_equal true,  evaluate('< "A" "a"')
				assert_equal false, evaluate('< "z" "Z"')
				assert_equal true,  evaluate('< "Z" "z"')

				assert_equal true, evaluate('< "/" 0')
				assert_equal true, evaluate('< "8" 9')

			end

			it 'performs it even with numbers' do
				assert_equal true, evaluate('< "0" "00"')
				assert_equal true, evaluate('< "1" "12"')
				assert_equal true, evaluate('< "100" "12"')
				assert_equal false, evaluate('< "00" "0"')
				assert_equal false, evaluate('< "12" "1"')
				assert_equal false, evaluate('< "12" "100"')

				assert_equal true, evaluate('< "  0" "  00"')
				assert_equal true, evaluate('< "  1" "  12"')
				assert_equal true, evaluate('< "  100" "  12"')
			end

			it 'coerces the RHS to a number' do
				assert_equal true, evaluate('< "0" 1')
				assert_equal true, evaluate('< "1" 12')
				assert_equal true, evaluate('< "100" 12')
				assert_equal false, evaluate('< "00" 0')
				assert_equal false, evaluate('< "12" 100')
				assert_equal false, evaluate('< "12" 100')

				assert_equal true, evaluate('< "trud" TRUE')
				assert_equal false, evaluate('< "true" TRUE')
				assert_equal false, evaluate('< "truf" TRUE')

				assert_equal true, evaluate('< "falsd" FALSE')
				assert_equal false, evaluate('< "false" FALSE')
				assert_equal false, evaluate('< "faslf" FALSE')

				assert_equal true, evaluate('< "nulk" NULL')
				assert_equal false, evaluate('< "null" NULL')
				assert_equal false, evaluate('< "nulm" NULL')
			end
		end

		describe '4.3.8 >' do
			it 'performs lexicographical comparison' do
				assert_equal false, evaluate('> "a" "aa"')
				assert_equal true,  evaluate('> "b" "aa"')

				assert_equal true,  evaluate('> "aa" "a"')
				assert_equal false, evaluate('> "aa" "b"')

				assert_equal false, evaluate('> "A" "AA"')
				assert_equal true,  evaluate('> "B" "AA"')

				assert_equal true,  evaluate('> "AA" "A"')
				assert_equal false, evaluate('> "AA" "B"')

				# ensure it obeys ascii
				assert_equal true,  evaluate('> "a" "A"')
				assert_equal false, evaluate('> "A" "a"')
				assert_equal true,  evaluate('> "z" "Z"')
				assert_equal false, evaluate('> "Z" "z"')

				assert_equal true, evaluate('> ":" 9')
				assert_equal true, evaluate('> "1" 0')

			end

			it 'performs it even with numbers' do
				assert_equal false, evaluate('> "0" "00"')
				assert_equal false, evaluate('> "1" "12"')
				assert_equal false, evaluate('> "100" "12"')
				assert_equal true, evaluate('> "00" "0"')
				assert_equal true, evaluate('> "12" "1"')
				assert_equal true, evaluate('> "12" "100"')

				assert_equal false, evaluate('> "  0" "  00"')
				assert_equal false, evaluate('> "  1" "  12"')
				assert_equal false, evaluate('> "  100" "  12"')
			end

			it 'coerces the RHS to a number' do
				assert_equal false, evaluate('> "0" 1')
				assert_equal false, evaluate('> "1" 12')
				assert_equal false, evaluate('> "100" 12')
				assert_equal true, evaluate('> "00" 0')
				assert_equal true, evaluate('> "12" 100')
				assert_equal true, evaluate('> "12" 100')

				assert_equal false, evaluate('> "trud" TRUE')
				assert_equal false,  evaluate('> "true" TRUE')
				assert_equal true,  evaluate('> "truf" TRUE')

				assert_equal false, evaluate('> "falsd" FALSE')
				assert_equal false,  evaluate('> "false" FALSE')
				assert_equal true,  evaluate('> "faslf" FALSE')

				assert_equal false, evaluate('> "nulk" NULL')
				assert_equal false,  evaluate('> "null" NULL')
				assert_equal true,  evaluate('> "nulm" NULL')
			end
		end
	end
end
