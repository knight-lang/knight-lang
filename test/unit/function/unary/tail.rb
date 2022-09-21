require_relative '../../shared'

section ']' do
  it 'gets everything but first element of lists' do
    # test different types of list construction methods
    assert_result [], %|],1|
    assert_result [2], %|]+,1 ,2|
    assert_result [2,3], %|]+@123|
    assert_result [1,1,1], %|]*,1 4|
    assert_result [], %|]GET +@123 0 1|
    assert_result [3], %|]SET +@123 0 1 @|
  end

  it 'gets everything but first character of strings' do
    assert_result '', %|]'a'|
    assert_result 'bc', %|]'abc'|
    assert_result 'bcdef', %|]+'abc' 'def'|
    assert_result 'bc', %|]+'' 'abc'|
    assert_result 'bcabcabc', %|]*'abc' 3|
    assert_result '', %|]GET 'abc' 0 1|
    assert_result 'c', %|]SET 'abc' 0 1 ''|
  end

  it 'only allows a string or list as the first operand', when_testing: :invalid_types do
    refute_runs %|] 123|
    refute_runs %|] TRUE|
    refute_runs %|] FALSE|
    refute_runs %|] NULL|
  end  

  it 'does not take head on empty lists or strings', when_testing: :empty_list do
    refute_runs %|] @|
    refute_runs %|] ""|
  end

  it 'does not allow a block', when_testing: :strict_types do
    refute_runs %|; = a ,"a" : ] (BLOCK a)|
    refute_runs %|; = a (BLOCK QUIT 0) : ] a|
  end

  it 'requires exactly one argument', when_testing: :argument_count do
    refute_runs %|]|
    assert_runs %|] 'a'|
  end
end
