require 'minitest'
require 'minitest/spec'
require_relative 'shared'

describe '2.3 Boolean' do
	include Kn::Test::Shared

	describe '2.3.1 Contexts' do
		it '(boolean) is true when TRUE and false when FALSE' do
			assert_equal true, to_boolean('TRUE')
			assert_equal false, to_boolean('FALSE')
		end

		it '(numeric) is 1 when TRUE and 0 when FALSE' do
			assert_equal 1, to_number('TRUE')
			assert_equal 0, to_number('FALSE')
		end

		it '(string) is "true" when TRUE and "false" when FALSE' do
			assert_equal 'true', to_string('TRUE')
			assert_equal 'false', to_string('FALSE')
		end
	end

	describe 'parsing' do
		it 'parses a simple `T` or `F` properly' do
			assert_equal true, evaluate('T')
			assert_equal false, evaluate('F')
		end

		it 'does not parse `true` or `false`' do
			# when its not in scope, it fails.
			assert_fails { evaluate('true') }
			assert_fails { evaluate('false') }

			# when it is in scope, its evaluates to what its assigned.
			assert_equal 12, evaluate('; = true 12 : true')
			assert_equal 12, evaluate('; = false 12 : false')
		end

		it 'strips trailing keywords properly' do
			assert_equal 12, evaluate(';T12')
			assert_equal 12, evaluate(';TR12')
			assert_equal 12, evaluate(';TRU12')
			assert_equal 12, evaluate(';TRUE12')
			assert_equal 12, evaluate(';F12')
			assert_equal 12, evaluate(';FA12')
			assert_equal 12, evaluate(';FAL12')
			assert_equal 12, evaluate(';FALS12')
			assert_equal 12, evaluate(';FALSE12')
		end
	end

	describe 'operators' do
		describe '4.3.9 ?' do
			it 'only is equal to itself' do
				assert_equal true, evaluate('? TRUE TRUE')
				assert_equal true, evaluate('? FALSE FALSE')
			end

			it 'is not equal to anything else' do
				assert_equal false, evaluate('? TRUE 1')
				assert_equal false, evaluate('? TRUE "1"')
				assert_equal false, evaluate('? TRUE "TRUE"')
				assert_equal false, evaluate('? TRUE "true"')

				assert_equal false, evaluate('? FALSE 0')
				assert_equal false, evaluate('? FALSE ""')
				assert_equal false, evaluate('? FALSE "0"')
				assert_equal false, evaluate('? FALSE "FALSE"')
				assert_equal false, evaluate('? FALSE "false"')
			end
		end

		describe '4.3.7 <' do
			it 'is only true when FALSE and the rhs is truthy' do
				assert_equal true, evaluate('< FALSE TRUE')
				assert_equal true, evaluate('< FALSE 1')
				assert_equal true, evaluate('< FALSE "1"')
			end

			it 'is false all other times' do
				assert_equal false, evaluate('< FALSE FALSE')
				assert_equal false, evaluate('< FALSE 0')
				assert_equal false, evaluate('< FALSE ""')
				assert_equal false, evaluate('< FALSE NULL')
				assert_equal true, evaluate('< FALSE (- 0 1)')

				assert_equal false, evaluate('< TRUE TRUE')
				assert_equal false, evaluate('< TRUE FALSE')
				assert_equal false, evaluate('< TRUE 1')
				assert_equal false, evaluate('< TRUE "1"')
				assert_equal false, evaluate('< TRUE 0')
				assert_equal false, evaluate('< TRUE ""')
				assert_equal false, evaluate('< TRUE NULL')
			end
		end

		describe '4.3.8 >' do
			it 'is only true when TRUTHY and the rhs is falsey' do
				assert_equal true, evaluate('> TRUE FALSE')
				assert_equal true, evaluate('> TRUE 0')
				assert_equal true, evaluate('> TRUE ""')
				assert_equal true, evaluate('> TRUE NULL')
			end

			it 'is false all other times' do
				assert_equal false, evaluate('> TRUE TRUE')
				assert_equal false, evaluate('> TRUE 1')
				assert_equal false, evaluate('> TRUE "1"')

				assert_equal false, evaluate('> FALSE (- 0 1)')
				assert_equal false, evaluate('> FALSE TRUE')
				assert_equal false, evaluate('> FALSE FALSE')
				assert_equal false, evaluate('> FALSE 1')
				assert_equal false, evaluate('> FALSE "1"')
				assert_equal false, evaluate('> FALSE 0')
				assert_equal false, evaluate('> FALSE ""')
				assert_equal false, evaluate('> FALSE NULL')
			end
		end
	end
end
