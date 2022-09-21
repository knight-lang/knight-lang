require_relative '../shared'

section 'null' do
  describe 'parsing' do
    it 'parses `N` and `NULL` as null' do
      assert_result :null, %|N|
      assert_result :null, %|NULL|
    end
  end

  describe 'conversions' do
    describe 'integer' do
      it 'converts to zero' do
        assert_result 0, %|+ 0 NULL|
      end
    end

    describe 'string' do
      it 'converts to an empty string' do
        assert_result '', %|+ '' NULL|
        assert_result 'x', %|+ 'x' NULL|
      end
    end

    describe 'boolean' do
      it 'converts to false' do
        assert_result false, %|!!NULL|
      end
    end

    describe 'list' do
      it 'converts to an empty list' do
        assert_result [], %|+ @ NULL|
      end
    end
  end
end
