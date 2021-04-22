require 'minitest'
require 'minitest/spec'
require 'stringio'
require_relative '../shared'

describe '4. Function' do
	include Kn::Test::Shared

	describe '4.2.1 (:)' do
		it 'should return its argument unchanged, but evaluated' do
			assert_equal 0, eval(': 0')
			assert_equal 1, eval(': 1')
			assert_equal true, eval(': TRUE')
			assert_equal false, eval(': FALSE')
			assert_equal :null, eval(': NULL')
			assert_equal "", eval(': ""')
			assert_equal "a", eval(': "a"')
			assert_runs { eval(': BLOCK QUIT 1') }
			assert_runs { eval(': BLOCK a') }
		end
	end
end
