require_relative '../../shared'


section ',' do
  it 'converts normal arguments to a list of just that' do
    expect_result [0],  %|,0|
    expect_result [1],  %|,1|
    expect_result [1234],  %|,1234|
    expect_result [-1234],  %|,~1234|

    expect_result [""], %|,""|
    expect_result ["hello"], %|,"hello"|

    expect_result [true], %|,TRUE|
    expect_result [false], %|,FALSE|
    expect_result [:null], %|,NULL|
  end

  it 'also converts lists to just a list of that' do
    assert_result [[]], %|,@|
    assert_result [[4]], %|,,4|
    assert_result [[1,2,3]], %|,+@123|
  end

  it 'accepts blocks as the only operand' do
    assert_runs %|,BLOCK a|
  end

  it 'requires exactly one argument', when_testing: :argument_count do
    refute_runs %|,|
    assert_runs %|, 1|
  end
end
