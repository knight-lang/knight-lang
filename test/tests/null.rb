require 'minitest'
require 'minitest/spec'
require_relative 'shared'

describe '2.4.1 Null' do
	include Kn::Test::Shared

	describe '2.4.1 Contexts' do
		it '(boolean) is falsey' do
			assert_equal false, to_boolean('NULL')
		end

		it '(numeric) is zero' do
			assert_equal 0, to_number('NULL')
		end

		it '(string) is "null"' do
			assert_equal 'null', to_string('NULL')
		end
	end

	describe 'Parsing' do
		it 'parses a simple `N` properly' do
			assert_equal :null, eval('N')
		end

		it 'does not parse `null`' do
			if checks? :undefined_variables
				# when its not in scope, it fails.
				assert_fails { eval('null') }
			end

			# when it is in scope, its evaluates to what its assigned.
			assert_equal 12, eval('; = null 12 : null')
		end

		it 'strips trailing keywords properly' do
			assert_equal 12, eval(';N12')
			assert_equal 12, eval(';NU12')
			assert_equal 12, eval(';NUL12')
			assert_equal 12, eval(';NULL12')
		end
	end

	describe 'operators' do
		describe '4.3.9 ?' do
			it 'equals itself' do
				assert_equal true, eval('? NULL NULL')
			end

			it 'is not equal to other values' do
				assert_equal false, eval('? NULL FALSE')
				assert_equal false, eval('? NULL TRUE')
				assert_equal false, eval('? NULL 0')
				assert_equal false, eval('? NULL ""')
				assert_equal false, eval('? NULL "0"')
				assert_equal false, eval('? NULL "NULL"')
				assert_equal false, eval('? NULL "null"')
			end
		end

		if checks? :invalid_operations
			describe '<' do
				it 'cannot be compared' do
					assert_fails { eval('< NULL 1') }
				end
			end

			describe '>' do
				it 'cannot be compared' do
					assert_fails { eval('> NULL 1') }
				end
			end
		end
	end
end
