require_relative '../shared'

section 'whitespace' do
  describe 'whitespace needed after integers' do
    it 'is needed before other integers' do
      WHITESPACE.product([''] + WHITESPACE) do |chr, chr2|
        assert_result 3, %|+ 1#{chr}#{chr2}2|
      end
    end
    it 'is not needed before variables' do
      assert_result 3, %|; = a 2 : + 1a|
    end

    it 'is not needed before functions' do
      assert_result 2, %|+ 1LENGTH 1| # word fn
      assert_result 7, %|+ 1* 2 3| # symbolic fn
    end

    it 'is not needed before strings' do
      assert_result 3, %|+ 1"2"|
    end
  end

  describe 'whitespace needed after variables' do
    it 'is needed before integers' do
      WHITESPACE.product(['', *WHITESPACE]) do |chr, chr2|
        assert_result 3, %|; = a 1 : + a#{chr}#{chr2}2|
      end
    end

    it 'is needed before other variables' do
      WHITESPACE.product(['', *WHITESPACE]) do |chr, chr2|
        assert_result 3, %|; = a 1 ; = b 2 : + a#{chr}#{chr2}b|
      end
    end

    it 'is not needed before functions' do
      assert_result 3, %|; = a 2 : + aLENGTH 1| # word fn
      assert_result 7, %|; = a 1 : + a* 2 3| # symbolic fn
    end

    it 'is not needed before strings' do
      assert_result 3, %|; = a 1 : + a"2"|
    end
  end

  describe 'whitespace needed after functions' do
    it 'is not needed before integers' do
      assert_result 1, %|LENGTH1| # word fn
      assert_result false, %|!1| # symbolic fn
    end

    it 'is not needed before variables' do
      assert_result 1, %|; = a 3 : LENGTHa| # word fn
      assert_result -3, %|; = a 3 : ~a| # symbolic fn
    end
    
    it 'is needed between word functions' do
      WHITESPACE.product(['', *WHITESPACE]) do |chr, chr2|
        assert_result 0, %|* RANDOM#{chr}#{chr2}LENGTH ""|
      end
    end

    it 'is not needed between other function pairs' do
      assert_result 0, %|*RANDOM 0| # symbol word
      assert_result 1, %|LENGTH~ 0| # word symbol
      assert_result true, %|!! 1| # symbol symbol
    end

    it 'is not needed before strings' do
      assert_result 3, %|LENGTH"abc"| # word fn
      assert_result false, %|!"abc"| # Symbolic fn
    end
  end

  describe 'whitespace needed after strings' do
    it 'is not needed before integers' do
      assert_result '1', %|+ ""1|
    end

    it 'is not needed before variables' do
      assert_result '1', %|; = a 1 : + ""a|
    end
    
    it 'is not needed before functions' do
      assert_result '1', %|; = a 1 : + ""LENGTH a|
    end

    it 'is not needed before strings' do
      assert_result 'ab', %|+ 'a''b'|
      assert_result 'ab', %|+ 'a'"b"|
      assert_result 'ab', %|+ "a"'b'|
      assert_result 'ab', %|+ "a""b"|
    end
  end
end
