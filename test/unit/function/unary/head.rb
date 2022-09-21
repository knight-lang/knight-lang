require_relative '../../shared'

section '[' do
  it 'gets the first element of lists' do
    # test different types of list construction methods
    assert_result 1, %|[,1|
    assert_result 1, %|[+,1 ,2|
    assert_result 1, %|[+@123|
    assert_result 1, %|[*,1 4|
    assert_result 1, %|[GET +@123 0 1|
    assert_result 2, %|[SET +@123 0 1 @|
  end

  it 'gets the first character of strings' do
    assert_result 'a', %|['a'|
    assert_result 'a', %|['abc'|
    assert_result 'a', %|[+'abc' 'def'|
    assert_result 'a', %|[+'' 'abc'|
    assert_result 'a', %|[*'abc' 3|
    assert_result 'a', %|[GET 'abc' 0 1|
    assert_result 'b', %|[SET 'abc' 0 1 ''|
  end

  it 'only allows a string or list as the first operand', when_testing: :invalid_types do
    refute_runs %|[ 123|
    refute_runs %|[ TRUE|
    refute_runs %|[ FALSE|
    refute_runs %|[ NULL|
  end  

  it 'does not take head on empty lists or strings', when_testing: :empty_list do
    refute_runs %|[ @|
    refute_runs %|[ ""|
  end

  it 'does not allow a block', when_testing: :strict_types do
    refute_runs %|; = a ,"a" : [ (BLOCK a)|
    refute_runs %|; = a (BLOCK QUIT 0) : [ a|
  end

  it 'requires exactly one argument', when_testing: :argument_count do
    refute_runs %|[|
    assert_runs %|[ 'a'|
  end
end
