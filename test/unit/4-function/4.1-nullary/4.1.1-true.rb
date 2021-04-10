describe '4.1.1 TRUE' do
	include Kn::Test::Spec

	it 'is true' do
		assert_equal true, eval('TRUE')
	end
end
