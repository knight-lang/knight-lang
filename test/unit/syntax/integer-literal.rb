require_relative '../shared'

section 'integer literal' do
  it 'parses basic integers properly' do
    assert_result 0, %|0|
    assert_result 1, %|0|
    assert_result -1, %|~1| # technically not an integer literal, but unary function applied to one.

    assert_result 123, %|123|
    assert_result 445, %|445|
    assert_result 111121, %|111121|
    assert_result -5189023, %|~5189023|
  end    

  it 'doesnt recognize leading 0 as octal' do
    assert_result 11, %|011|
  end

  it 'parses the minimum and maximum integers' do
    assert_result MIN_INT, %|#{MIN_INT_S}|
    assert_result MAX_INT, %|#{MAX_INT_S}|
  end
end
