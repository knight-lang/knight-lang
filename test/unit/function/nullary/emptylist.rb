require_relative '../../shared'

# See also the `types/list.rb` file
section '@' do
  it 'is an empty list' do
    assert_result [], %|@|
  end
end
