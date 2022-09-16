require_relative '../shared'

section 'boolean' do
  describe 'parsing' do
    it 'parses `F` and `FALSE` as false' do
      assert_result false, %|F|
      assert_result false, %|FALSE|
    end

    it 'parses `T` and `TRUE` as true' do
      assert_result true, %|T|
      assert_result true, %|TRUE|
    end
  end

  describe 'conversions' do
    describe 'integer' do
      it 'converts false to zero' do
        assert_result 0, %|+ 0 FALSE|
      end

      it 'converts true to one' do
        assert_result 1, %|+ 0 TRUE|
      end
    end

    describe 'string' do
      it 'converts false to the string `false`' do
        assert_result 'false', %|+ '' FALSE|
      end

      it 'converts true to the string `true`' do
        assert_result 'true', %|+ '' TRUE|
      end
    end

    describe 'boolean' do
      it 'simply returns itself' do
        assert_result false, %|!!FALSE|
        assert_result true, %|!!TRUE|
      end
    end

    describe 'list' do
      it 'converts false to an empty list' do
        assert_result [], %|+ @ FALSE|
      end

      it 'converts true to a list of just true' do
        assert_result [true], %|+ @ TRUE|
      end
    end
  end
end
