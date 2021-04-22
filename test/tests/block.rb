require 'minitest'
require 'minitest/spec'
require_relative 'shared'

describe 'Block' do
	include Kn::Test::Shared

	describe 'conversions' do
		# Blocks cannot be converted to anything
	end

	describe 'parsing' do
		it 'takes any argument type' do
			assert_runs { execute 'BLOCK 1' }
			assert_runs { execute 'BLOCK "a"' }
			assert_runs { execute 'BLOCK TRUE' }
			assert_runs { execute 'BLOCK FALSE' }
			assert_runs { execute 'BLOCK NULL' }
			assert_runs { execute 'BLOCK B 3' }
			assert_runs { execute 'BLOCK ident' }
		end

		it 'requires an argument' do
			return pass if $all_ub
			assert_fails { execute 'BLOCK' }
			assert_fails { execute 'BLOCK BLOCK' }
		end

		it 'strips trailing keywords properly' do
			assert_runs { execute 'B1' }
			assert_runs { execute 'BL!1' }
			assert_runs { execute 'BLO!1' }
			assert_runs { execute 'BLO RANDOM' }
			assert_runs { execute 'BLO RANDOM' }
			assert_runs { execute 'BLO RANDOM' }
			assert_runs { execute 'BLOa' }
			assert_runs { execute 'BLa' }
			assert_runs { execute 'Ba' }
		end
	end

	it 'wont execute its body until called' do
		assert_runs { execute 'BLOCK QUIT 1' }
		assert_runs { execute 'BLOCK missing' }
		assert_runs { execute 'BLOCK eval "nope"' }
	end

	# note that `BLOCK` simply returns its argument, unevaluated. But in the case of 
	# literals, this is the same as the literal itself, so we must provide a function istead.
	describe 'operators' do
		describe 'CALL' do
			it 'executes its body' do
				assert_equal 12, eval('CALL BLOCK + 5 7')
				assert_equal 18, eval('; = foo BLOCK + bar 5 ; = bar 13 : CALL foo')
			end


			it 'can be called with any type' do
				# we call these because they may be implemented as a function.
				assert_equal 1, eval('CALL BLOCK 1')
				assert_equal 'foo', eval('CALL BLOCK "foo"')
				assert_equal true, eval('CALL BLOCK TRUE')
				assert_equal false, eval('CALL BLOCK FALSE')
				assert_equal :null, eval('CALL BLOCK NULL')
				assert_equal 1, eval('; = ident 1 : CALL BLOCK ident')
				assert_equal 3, eval('CALL BLOCK + 1 2')
			end
		end
=begin
		describe '?' do
			it 'is only equivalent to _the exact instance_' do
				assert_equal true, eval('; = x B R : ? x x')
			end

			it 'is not equal to anything else' do
				assert_equal false, eval('? B (! TRUE) B (! TRUE)')
				assert_equal false, eval('? B (! TRUE) FALSE')
			end
		end
=end
	end
end
