require_relative '../shared'

# see also `syntax/variable.rb`
section 'variable' do
  it 'can be assigned to' do
    assert_result 3, %|; = a 3 : a|
  end

  it 'can be reassigned' do
    assert_result 4, %|; = a 3 ; = a 4 : a|
  end

  it 'can be reassigned using itself' do
    assert_result 4, %|; = a 3 ; = a + a 1 : a|
  end

  it 'can have multiple variables' do
    assert_result 7, %|; = a 3 ; = b 4 : + a b|
  end

  it 'has all variables as global within blocks' do
    assert_result [5,2,6,4,7,8], <<~KNIGHT
      ; = a 1
      ; = b 2
      ; = blk BLOCK
        ; = a 5
        ; = c 6
        ; = e 7
        ; = f 8
        : ++++,a,b,c,d,e
      ; = c 3
      ; = d 4
      : +CALL blk ,f
    KNIGHT
  end
end
