section '~' do
  it 'negates its argument' do
    assert_result -1,  %|~ 1|
    assert_result -10,  %|~ 10|
    assert_result 12,  %|~ ~12|
    assert_result 123,  %|~ (- 0 123)|
    assert_result 0, %|~0|
  end

  it 'converts its argument to a number' do
    assert_result -2, %|~ "2"|
    assert_result -45, %|~ "45"|
    assert_result -1, %|~ TRUE|
    assert_result 0, %|~ FALSE|
    assert_result 0, %|~ NULL|
  end

  it 'requires exactly one argument', when_testing: :argument_count do
    refute_runs %|~|
    assert_runs %|~ 1|
  end

  it 'does not allow blocks as the first operand', when_testing: :strict_types do
    refute_runs %|; = a 0 : ~ BLOCK a|
    refute_runs %|~ BLOCK QUIT 0|
  end
end
