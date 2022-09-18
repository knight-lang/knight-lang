require_relative '../shared'

section 'integer' do
  describe 'conversions' do
    describe 'integer' do
      it 'simply returns itself' do
        assert_result 0, %|+0 0|
        assert_result 1, %|+0 1|
        assert_result -1, %|+0 ~1|

        assert_result 123, %|+0 123|
        assert_result 445, %|+0 445|
        assert_result 111121, %|+0 111121|
        assert_result -5189023, %|+0 ~5189023|
      end

      it 'can convert the minimum and maximum integers' do
        assert_result MIN_INT, %|+0 #{MIN_INT_S}|
        assert_result MAX_INT, %|+0 #{MAX_INT_S}|
      end
    end

    describe 'string' do
      it 'converts to basic integers properly' do
        assert_result '0', %|+'' 0|
        assert_result '1', %|+'' 1|
        assert_result '-1', %|+'' ~1|

        assert_result '123', %|+'' 123|
        assert_result '445', %|+'' 445|
        assert_result '111121', %|+'' 111121|
        assert_result '-5189023', %|+'' ~5189023|
      end

      it 'converts the minimum and maximum integers' do
        assert_result "#{MIN_INT}", %|+'' #{MIN_INT_S}|
        assert_result "#{MAX_INT}", %|+'' #{MAX_INT_S}|
      end
    end

    describe 'boolean' do
      it 'returns false for zero' do
        assert_result false, %|!! 0|
      end

      it 'returns true for anything else' do
        assert_result true, %|!! 1|
        assert_result true, %|!! ~1|

        assert_result true, %|!! 123|
        assert_result true, %|!! 445|
        assert_result true, %|!! 111121|
        assert_result true, %|!! ~5189023|
      end

      it 'returns true for the minimum and maximum integers'do
        assert_result true, %|!! #{MIN_INT_S}|
        assert_result true, %|!! #{MAX_INT_S}|
      end
    end

    describe 'list' do
      it 'converts zero to a list of zero' do
        assert_result [0], %|+@ 0|
      end

      it 'converts basic integers to their digits' do
        assert_result [1], %|+@ 1|
        assert_result [1, 2, 3], %|+@ 123|
        assert_result [4, 4, 5], %|+@ 445|
        assert_result [1, 1, 1, 1, 2, 1], %|+@ 111121|
      end

      it 'has negative digits for negative numbers' do
        assert_result [-1], %|+@ ~1|
        assert_result [-5, -1, -8, -9, 0, -2, -3], %|+@ ~5189023|
      end

      it 'can convert the minimum and maximum integers' do
        assert_result [-2, -1, -4, -7, -4, -8, -3, -6, -4, -8], %|+@ #{MIN_INT_S}|
        assert_result [2, 1, 4, 7, 4, 8, 3, 6, 4, 7], %|+@ #{MAX_INT_S}|
      end
    end
  end
end
