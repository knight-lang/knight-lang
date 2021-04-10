describe '4.1.3 NULL' do
	include Kn::Test::Spec

	it 'is null' do
		assert_equal :null, eval('NULL')
	end
end
