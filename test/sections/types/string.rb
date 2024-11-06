section 'string' do
  describe 'bounds' do
    it 'supports strings of max size', when_testing: :container_bounds do
      assert_equal MAX_INT, %|LENGTH *"a" #{MAX_INT_S}|
    end
  end

  describe 'conversions' do
    describe 'integer' do
      it 'parses normal integer strings correctly' do
        assert_result 0, %|+0 "0"|
        assert_result 1, %|+0 "1"|
        assert_result 123, %|+0 "123"|
        assert_result 123, %|+0 "+123"|
        assert_result -123, %|+0 "-123"|
      end

      it 'returns zero if there is a space after the + or -' do
        assert_result 0, %|+0 "+ 123"|
        assert_result 0, %|+0 "- 123"|
      end

      it 'returns zero for the empty string' do
        assert_result 0, %|+0 ''|
      end
    
      it 'converts non-numeric strings to zero'   do
        assert_result 0, %|+0 "hello"|
        assert_result 0, %|+0 "zero"|
        assert_result 0, %|+0 "x123"|
      end

      it 'returns zero if there is a leading `~`' do
        assert_result 0, %|+0 "~123"|
      end

      it 'strips leading whitespace' do
        assert_result  456, %|+0 "    \n\r  456"|
        assert_result  456, %|+0 "    \n\r +456"|
        assert_result -456, %|+0 "    \n\r -456"|
        assert_result    0, %|+0 "    \n\r+ 456"| # space after yields zero
        assert_result    0, %|+0 "    \n\r- 456"|
      end

      it 'stops after the first digit' do
        assert_result 12, %|+0 " \n 12a"|
        assert_result 12, %|+0 "12a34"|
        assert_result 12, %|+0 "\n \r\t\n \r   12a34"|
      end

      it 'does not parse escapes' do
        assert_result 111, %|+0 "00111"|
        assert_result 0, %|+0 "0x3f"|
        assert_result 0, %|+0 "0b11"|
        assert_result 0, %|+0 "0o17"|
        assert_result 0, %|+0 "0d13"|
      end

      it 'does not parse floats' do
        assert_result 12, %|+0 "12e34"|
        assert_result 12, %|+0 "12.34"|

        %w[nan inf infinity].each do |float_constant|
          assert_result 0, %|+0 "#{float_constant}"|
          assert_result 0, %|+0 "#{float_constant.capitalize}"|
          assert_result 0, %|+0 "#{float_constant.upcase}"|
          assert_result 0, %|+0 "-#{float_constant}"|
          assert_result 0, %|+0 "-#{float_constant.capitalize}"|
          assert_result 0, %|+0 "-#{float_constant.upcase}"|
        end
      end
    end

    describe 'string' do
      it 'simply returns itself' do
        assert_result '', %|+'' ''|
        assert_result '', %|+'' ""|
        assert_result '"', %|+'' '"'|
        assert_result "'", %|+'' "'"|
        assert_result 'hello world', %|+'' "hello world"|
        assert_result '0', %|+'' "0"|
        assert_result ' 1234', %|+'' " 1234"|
        assert_result ('x' * 1000), %|+'' "#{"x" * 1000}"|
      end
    end

    describe 'boolean' do
      it 'returns false for empty string' do
        assert_result false, %|!! ''|
      end

      it 'returns true for zero-like strings' do
        assert_result true, %|!! '0'|
        assert_result true, %|!! ' 0'|
        assert_result true, %|!! '0.0'|
        assert_result true, %|!! '0 but false'|
      end

      it 'returns true for normal strings' do
        assert_result true, %|!! '"'|
        assert_result true, %|!! "'"|
        assert_result true, %|!! "hello world"|
        assert_result true, %|!! "0"|
        assert_result true, %|!! " 1234"|
        assert_result true, %|!! "#{"x" * 1000}"|
      end
    end

    describe 'list' do
      it 'converts empty string to an empty list' do
        assert_result [], %|+ @ ''|
      end

      it 'returns a list of length-one strings' do
        assert_result ['"'], %|+@ '"'|
        assert_result ["'"], %|+@ "'"|
        assert_result 'hello world'.chars, %|+@ "hello world"|
        assert_result ['0'], %|+@ "0"|
        assert_result ' 1234'.chars, %|+@ " 1234"|
        assert_result ('x' * 1000).chars, %|+@ "#{"x" * 1000}"|
      end
    end
  end
end
