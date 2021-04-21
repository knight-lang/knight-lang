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
			assert_equal :null, evaluate('N')
		end

		it 'does not parse `null`' do
			if checks? :undefined_variables
				# when its not in scope, it fails.
				assert_fails { evaluate('null') }
			end

			# when it is in scope, its evaluates to what its assigned.
			assert_equal 12, evaluate('; = null 12 : null')
		end

		it 'strips trailing keywords properly' do
			assert_equal 12, evaluate(';N12')
			assert_equal 12, evaluate(';NU12')
			assert_equal 12, evaluate(';NUL12')
			assert_equal 12, evaluate(';NULL12')
		end
	end

	describe 'operators' do
		describe '4.3.9 ?' do
			it 'equals itself' do
				assert_equal true, evaluate('? NULL NULL')
			end

			it 'is not equal to other values' do
				assert_equal false, evaluate('? NULL FALSE')
				assert_equal false, evaluate('? NULL TRUE')
				assert_equal false, evaluate('? NULL 0')
				assert_equal false, evaluate('? NULL ""')
				assert_equal false, evaluate('? NULL "0"')
				assert_equal false, evaluate('? NULL "NULL"')
				assert_equal false, evaluate('? NULL "null"')
			end
		end

		if checks? :invalid_operations
			describe '<' do
				it 'cannot be compared' do
					assert_fails { evaluate('< NULL 1') }
				end
			end

			describe '>' do
				it 'cannot be compared' do
					assert_fails { evaluate('> NULL 1') }
				end
			end
		end
	end
end
