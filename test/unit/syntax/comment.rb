require_relative '../shared'

section 'comment' do
  it 'can be at the start of a program' do
    assert_result 3, %|#hello\n3|
    assert_result 3, %|   #hello\n# world!\n3|
  end

  it 'can comment out code' do
    assert_result 3, %|# ; QUIT 1\n3|
  end

  it 'can be interspersed as whitespace' do
    assert_result 3, %|+ 1#hello\n2|
    assert_result 3, %|; = a 1 : + a#world\n2|
    assert_result 2, %|; = a 1 : + a#how\na|
    assert_result 3, %|LENGTH#are you?\nIF FALSE 0 123|
  end
end
