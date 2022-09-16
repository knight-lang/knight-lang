require_relative '../shared'

section 'boolean' do
  describe 'parsing' do
    it 'parses `B` and `BLOCK` properly' do
      assert_runs %|B 0|
      assert_runs %|BLOCK 0|
    end
  end

  define 'functions' do
    it 'should be usable as the sole argument to `:`' do
      assert_runs %|: BLOCK QUIT 1|
    end

    it 'should be usable as the sole argument to `BLOCK`' do
      assert_runs %|BLOCK BLOCK QUIT 1|
    end

    it 'should be usable as the sole argument to `CALL`' do
      assert_RESULT 3, %|CALL BLOCK + 1 2|
      assert_result 7, %|; = bar BLOCK + 4 foo ; = foo 3 : CALL bar|
    end

    it 'should be usable as the sole argument to `,`' do
      assert_runs %|, BLOCK QUIT 1|
    end

    it 'should be usable as the rhs argument to `=`' do
      assert_runs %|= foo BLOCK QUIT 1|
    end

    it 'should be usable as the rhs argument to `&`' do
      assert_runs %|& TRUE BLOCK QUIT 1|
    end

    it 'should be usable as the rhs argument to `|`' do
      assert_runs %#| FALSE BLOCK QUIT 1#
    end

    it 'should be usable as either argument to `;`' do
      assert_runs %|; 12 BLOCK QUIT 1|
      assert_runs %|; BLOCK QUIT 1 12|
    end

    it 'should be usable as the second and third arguments to `IF`' do
      assert_runs %|IF TRUE  BLOCK QUIT 1 NULL|
      assert_runs %|IF FALSE BLOCK QUIT 1 NULL|
    end
  end
end
