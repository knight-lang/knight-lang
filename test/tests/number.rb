require 'minitest'
require 'minitest/spec'
require_relative 'shared'

describe '2.1 Number' do
	include Kn::Test::Shared

	describe 'Contexts' do
		it '(boolean) is falsey when 0' do
			assert_equal false, to_boolean('0')
			assert_equal true, to_boolean('1')
			assert_equal true, to_boolean('(- 0 1)')
			assert_equal true, to_boolean('2')
			assert_equal true, to_boolean('100')
		end

		it '(numeric) converts to numbers normally' do
			assert_equal 0, to_number('0')
			assert_equal 1, to_number('1')
			assert_equal -1, to_number('(- 0 1)')
			assert_equal 2, to_number('2')
			assert_equal 100, to_number('100')
		end

		it '(string) converts to strings normally' do
			assert_equal '0', to_string('0')
			assert_equal '1', to_string('1')
			assert_equal '-1', to_string('(- 0 1)')
			assert_equal '2', to_string('2')
			assert_equal '100', to_string('100')
		end
	end

	describe 'Parsing' do
		it 'parses integer literals correctly' do
			assert_equal 0, evaluate('0')
			assert_equal 1234, evaluate('01234')
			assert_equal 11931821, evaluate('11931821')
		end

		it 'does not parse leading `-`s' do
			assert_fails { evaluate('-0') }
			assert_fails { evaluate('-9') }
		end

		# This is because it's `number(0)` `ident(x)` <other stuff>
		it 'interprets `0x...` and other bases as `0`.' do
			assert_equal 0, evaluate('0x1f')
			assert_equal 0, evaluate('0xag')
			assert_equal 0, evaluate('0b1101011')
			assert_equal 0, evaluate('0b1102011')
			assert_equal 0, evaluate('0o127')
			assert_equal 0, evaluate('0o129')
		end
	end

	describe 'operators' do
		describe '4.3.1 +' do
			it 'works with integers' do
				assert_equal 0, evaluate('+ 0 0')
				assert_equal 3, evaluate('+ 1 2')
				assert_equal 10, evaluate('+ 4 6')
				assert_equal 111, evaluate('+ 112 (- 0 1)')

				assert_equal 17, evaluate('+ 4 13')
				assert_equal -9, evaluate('+ 4 (- 0 13)')
				assert_equal 9, evaluate('+ (- 0 4) 13')
				assert_equal -17, evaluate('+ (- 0 4) (- 0 13)')
			end

			it 'converts other values to integers' do
				assert_equal 3, evaluate('+ 1 "2"')
				assert_equal 95, evaluate('+ 4 "91"')
				assert_equal 10, evaluate('+ 9 TRUE')
				assert_equal 9, evaluate('+ 9 FALSE')
				assert_equal 9, evaluate('+ 9 NULL')
			end
		end

		describe '4.3.2 -' do
			it 'works with integers' do
				assert_equal 0, evaluate('- 0 0')
				assert_equal -1, evaluate('- 1 2')
				assert_equal -2, evaluate('- 4 6')
				assert_equal 113, evaluate('- 112 (- 0 1)')

				assert_equal -9, evaluate('- 4 13')
				assert_equal 17, evaluate('- 4 (- 0 13)')
				assert_equal -17, evaluate('- (- 0 4) 13')
				assert_equal 9, evaluate('- (- 0 4) (- 0 13)')
			end

			it 'converts other values to integers' do
				assert_equal -1, evaluate('- 1 "2"')
				assert_equal 87, evaluate('- 91 "4"')
				assert_equal 8, evaluate('- 9 TRUE')
				assert_equal 9, evaluate('- 9 FALSE')
				assert_equal 9, evaluate('- 9 NULL')
			end
		end

		describe '4.3.3 *' do
			it 'works with integers' do
				assert_equal 0, evaluate('* 0 0')
				assert_equal 2, evaluate('* 1 2')
				assert_equal 24, evaluate('* 4 6')
				assert_equal -36, evaluate('* 12 (- 0 3)')

				assert_equal 52, evaluate('* 4 13')
				assert_equal -52, evaluate('* 4 (- 0 13)')
				assert_equal -52, evaluate('* (- 0 4) 13')
				assert_equal 52, evaluate('* (- 0 4) (- 0 13)')
			end

			it 'converts other values to integers' do
				assert_equal -2, evaluate('* 1 "-2"')
				assert_equal 364, evaluate('* 91 "4"')
				assert_equal 9, evaluate('* 9 TRUE')
				assert_equal 0, evaluate('* 9 FALSE')
				assert_equal 0, evaluate('* 9 NULL')
			end
		end

		describe '4.3.4 /' do
			it 'divides nonzero numbers normally' do
				assert_equal 1, evaluate('/ 1 1')
				assert_equal 5, evaluate('/ 10 2')
				assert_equal -5, evaluate('/ (- 0 10) 2')
				assert_equal -10, evaluate('/ 40 (- 0 4)')
				assert_equal 20, evaluate('/ (- 0 80) (- 0 4)')

				assert_equal 3, evaluate('/ 13 4')
				assert_equal -3, evaluate('/ 13 (- 0 4)')
				assert_equal -3, evaluate('/ (- 0 13) 4')
				assert_equal 3, evaluate('/ (- 0 13) (- 0 4)')
			end

			it 'rounds downwards' do
				assert_equal 0, evaluate('/ 4 5')
				assert_equal 2, evaluate('/ 10 4')
				assert_equal -1, evaluate('/ (- 0 5) 3')
				assert_equal -2, evaluate('/ (- 0 7) 3')
			end

			it 'does not divide by zero' do
				assert_fails { evaluate('/ 1 0') }
				assert_fails { evaluate('/ 100 0') }
				assert_fails { evaluate('/ 1 FALSE') }
				assert_fails { evaluate('/ 1 NULL') }
			end

			it 'converts other values to integers' do
				assert_equal 7, evaluate('/ 15 "2"')
				assert_equal 22, evaluate('/ 91 "4"')
				assert_equal 9, evaluate('/ 9 TRUE')
			end
		end

		describe '4.3.5 %' do
			# note that, as per the Knight spec, modulo where either number is negative is undefined.
			it 'modulos positive numbers normally' do
				assert_equal 0, evaluate('% 1 1')
				assert_equal 0, evaluate('% 4 4')
				assert_equal 0, evaluate('% 15 1')
				assert_equal 3, evaluate('% 123 10')
				assert_equal 0, evaluate('% 15 3')
			end

			it 'does modulo by zero' do
				assert_fails { evaluate('% 1 0') }
				assert_fails { evaluate('% 100 0') }
				assert_fails { evaluate('% 1 FALSE') }
				assert_fails { evaluate('% 1 NULL') }
			end

			it 'converts other values to integers' do
				assert_equal 1, evaluate('% 15 "2"')
				assert_equal 3, evaluate('% 91 "4"')
				assert_equal 0, evaluate('% 9 TRUE')
			end
		end

		describe '4.3.6 ^' do
			it 'raises positive numbers correctly' do
				assert_equal 1, evaluate('^ 1 1')
				assert_equal 1, evaluate('^ 1 100')
				assert_equal 16, evaluate('^ 2 4')
				assert_equal 125, evaluate('^ 5 3')
				assert_equal 3375, evaluate('^ 15 3')
				assert_equal 15129, evaluate('^ 123 2')
			end

			it 'returns 0 when the base is zero, unless the power is zero' do
				assert_equal 0, evaluate('^ 0 1')
				assert_equal 0, evaluate('^ 0 100')
				assert_equal 0, evaluate('^ 0 4')
				assert_equal 0, evaluate('^ 0 3')
			end

			it 'returns 1 when raising to the power of 0' do
				assert_equal 1, evaluate('^ 1 0')
				assert_equal 1, evaluate('^ 100 0')
				assert_equal 1, evaluate('^ 4 0')
				assert_equal 1, evaluate('^ 3 0')
				assert_equal 1, evaluate('^ (- 0 3) 0')
			end

			# Since we only have integral types, anything (normal) raised to a negative number is zero.
			it 'always returns zero when a > 1 number is raised to a negative power' do
				assert_equal 0, evaluate('^ 2 (- 0 2)')
				assert_equal 0, evaluate('^ 100 (- 0 2)')
				assert_equal 0, evaluate('^ 4 (- 0 2)')
				assert_equal 0, evaluate('^ 3 (- 0 2)')
				assert_equal 0, evaluate('^ (- 0 3) (- 0 2)')
			end

			it 'returns a negative number when a negative number is raised ot an odd power' do
				assert_equal -1, evaluate('^ (- 0 1) 1')
				assert_equal -8, evaluate('^ (- 0 2) 3')
				assert_equal 16, evaluate('^ (- 0 2) 4')
				assert_equal -32, evaluate('^ (- 0 2) 5')
				assert_equal 100, evaluate('^ (- 0 10) 2')
				assert_equal -1331, evaluate('^ (- 0 11) 3')
				assert_equal 20736, evaluate('^ (- 0 12) 4')
			end

			it 'handles one, zero, and negative one properly' do
				assert_equal 0, evaluate('^ 0 3')
				assert_equal 0, evaluate('^ 0 2')
				assert_equal 0, evaluate('^ 0 1')
				assert_equal 1, evaluate('^ 0 0')
				# 0 to a negative power is undefined.

				assert_equal 1, evaluate('^ 1 3')
				assert_equal 1, evaluate('^ 1 2')
				assert_equal 1, evaluate('^ 1 1')
				assert_equal 1, evaluate('^ 1 0')
				assert_equal 1, evaluate('^ 1 (- 0 1)')
				assert_equal 1, evaluate('^ 1 (- 0 2)')
				assert_equal 1, evaluate('^ 1 (- 0 3)')

				assert_equal -1, evaluate('^ (- 0 1) 3')
				assert_equal 1, evaluate('^ (- 0 1) 2')
				assert_equal -1, evaluate('^ (- 0 1) 1')
				assert_equal 1, evaluate('^ (- 0 1) 0')
				assert_equal -1, evaluate('^ (- 0 1) (- 0 1)')
				assert_equal 1, evaluate('^ (- 0 1) (- 0 2)')
				assert_equal -1, evaluate('^ (- 0 1) (- 0 3)')
			end

			it 'converts other values to integers' do
				assert_equal 225, evaluate('^ 15 "2"')
				assert_equal 1, evaluate('^ 91 FALSE')
				assert_equal 1, evaluate('^ 91 NULL')
				assert_equal 9, evaluate('^ 9 TRUE')
			end
		end

		describe '4.3.9 ?' do
			it 'is only equal to itself' do
				assert_equal true, evaluate('? 0 0')
				assert_equal true, evaluate('? (- 0 0) 0')
				assert_equal true, evaluate('? 1 1')
				assert_equal true, evaluate('? (- 0 1) (- 0 1)')
				assert_equal true, evaluate('? 912 912')
			end

			it 'is not equal to anything else' do
				assert_equal false, evaluate('? 0 1')
				assert_equal false, evaluate('? 1 0')
				assert_equal false, evaluate('? 4 5')
				assert_equal false, evaluate('? (- 0 4) 4')

				assert_equal false, evaluate('? 0 FALSE')
				assert_equal false, evaluate('? 0 NULL')
				assert_equal false, evaluate('? 0 ""')
				assert_equal false, evaluate('? 1 TRUE')
				assert_equal false, evaluate('? 1 "1"')
				assert_equal false, evaluate('? 1 "1a"')
			end
		end

		describe '4.3.7 <' do
			it 'performs numeric comparison' do
				assert_equal false, evaluate('< 1 1')
				assert_equal false, evaluate('< 0 0')
				assert_equal true, evaluate('< 12 100')
				assert_equal true, evaluate('< 1 2')
				assert_equal true, evaluate('< 91 491')

				assert_equal false, evaluate('< 100 12')
				assert_equal false, evaluate('< 2 1')
				assert_equal false, evaluate('< 491 91')

				assert_equal true, evaluate('< 4 13')
				assert_equal false, evaluate('< 4 (- 0 13)')
				assert_equal true, evaluate('< (- 0 4) 13')
				assert_equal false, evaluate('< (- 0 4) (- 0 13)')
			end

			it 'coerces the RHS to a number' do
				assert_equal true, evaluate('< 0 TRUE')
				assert_equal true, evaluate('< 0 "1"')
				assert_equal true, evaluate('< 0 "49"')

				assert_equal false, evaluate('< 0 FALSE')
				assert_equal false, evaluate('< 0 NULL')
				assert_equal false, evaluate('< 0 "0"')
				assert_equal false, evaluate('< 0 ""')
			end
		end

		describe '4.3.8 >' do
			it 'performs numeric comparison' do
				assert_equal false, evaluate('> 1 1')
				assert_equal false, evaluate('> 0 0')
				assert_equal false, evaluate('> 12 100')
				assert_equal false, evaluate('> 1 2')
				assert_equal false, evaluate('> 91 491')

				assert_equal true, evaluate('> 100 12')
				assert_equal true, evaluate('> 2 1')
				assert_equal true, evaluate('> 491 91')

				assert_equal false, evaluate('> 4 13')
				assert_equal true, evaluate('> 4 (- 0 13)')
				assert_equal false, evaluate('> (- 0 4) 13')
				assert_equal true, evaluate('> (- 0 4) (- 0 13)')
			end

			it 'coerces the RHS to a number' do
				assert_equal false, evaluate('> 0 TRUE')
				assert_equal false, evaluate('> 0 "1"')
				assert_equal false, evaluate('> 0 "49"')

				assert_equal true, evaluate('> 1 FALSE')
				assert_equal true, evaluate('> 1 NULL')
				assert_equal true, evaluate('> 1 "0"')
				assert_equal true, evaluate('> 01 ""')
			end
		end
	end
end
 