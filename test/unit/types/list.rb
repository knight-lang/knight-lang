require_relative '../shared'

section 'list' do
  describe 'parsing' do
    it 'parses `@` as an empty list' do
      assert_result [], %|@|
    end

    # while not really parsing lists, `,` is in essence a list literal of length 1
    it 'parses `,` as a list of length one' do
      assert_result [true], %|,TRUE|
      assert_result [[]], %|,@|
      assert_result ["Hello"], %|,"hello"|
    end
  end

  describe 'bounds' do
    it 'supports lists of max size', when_testing: :container_bounds do
      assert_equal MAX_INT, %|LENGTH *,1 #{MAX_INT_S}|
    end
  end

  describe 'conversions' do
    describe 'integer' do
      it 'returns its length' do
        assert_result 0, %|+0 @|
        assert_result 1, %|+0 ,"hello"|
        assert_result 1, %|+0 ,,,@|
        assert_result 9, %|+0 *,3 9|
      end
    end

    describe 'string' do
      it 'returns an empty string for the empty list' do
        assert_result '', %|+'' @|
      end

      it 'converts its only element for length one lists' do
        assert_result '', %|+'' ,NULL|
        assert_result '123', %|+'' ,123|
        assert_result 'true', %|+'' ,TRUE|
        end

      it 'inserts a newline between subsequent elements' do
        assert_result "hello\ntrue\n123", %|+'' ++,'hello' ,TRUE ,123|
        assert_result (['x']*100).join("\n"), %|+'' *,x 100|
      end

      it 'does not handle nested lists specially' do
        assert_result "hello\ntrue\n123", %|+'' ++,,'hello' ,,TRUE ,,123|
        assert_result (["x", "y"]*100).join("\n"), %|+'' *(+,"x" ,"y") 100|
      end
    end

    describe 'boolean' do
      it 'returns false for an empty list' do
        assert_result false, %|!! @|
      end

      it 'returns true for zero-like lists' do
        assert_result true, %|!! ,@|
        assert_result true, %|!! ,0|
        assert_result true, %|!! ,FALSE|
        assert_result true, %|!! ,NULL|
        assert_result true, %|!! ,""|
        assert_result true, %|!! ,,@|
      end

      it 'returns true for normal lists' do
        assert_result true, %|!! ,"hello"|
        assert_result true, %|!! ++,1 ,2 ,3|
        assert_result true, %|!! *,3 9|
      end
    end

    describe 'list' do
      it 'returns itself' do
        assert_result [], %|+@ @|
        assert_result [[]], %|+@ ,@|
        assert_result ['hello'], %|+@ ,"hello"|
        assert_result [1, 2, 3], %|+@ ++,1 ,2 ,3|
        assert_result [3]*9, %|+@ *,3 9|
      end
    end
  end
end
