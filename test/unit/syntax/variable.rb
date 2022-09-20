require_relative '../shared'

section 'variable' do
  it 'parses basic variables properly' do
    assert_equal 3, %|= a 3|
    assert_equal 3, %|= abcd 3|
    assert_equal 3, %|= #{('a'..'z').join} 3|
  end

  it 'parses variables with underscores' do
    assert_equal 3, %|= _ 3|
    assert_equal 3, %|= _________ 3|
    assert_equal 3, %|= _________hello 3|
    assert_equal 3, %|= hello___________world 3|
    assert_equal 3, %|= _h_e_l_l_o__w_o_r_l_d_ 3|
  end

  it 'parses variables with digits' do
    assert_equal 3, %|= a0 3|
    assert_equal 3, %|= a123 3|
    assert_equal 3, %|= aaa123 3|
    assert_equal 3, %|= a0aa0a 3|
    assert_equal 3, %|= a00a0aaaaaa0a 3|
  end

  it 'parses variables with digits and underscores' do
    assert_equal 3, %|= _0 3|
    assert_equal 3, %|= a_0 3|
    assert_equal 3, %|= a0_ 3|
    assert_equal 3, %|= a__1_2_3345_a 3|
    assert_equal 3, %|= _1ab_1_2_3345_ 3|
  end

  it 'does not use upper case letters' do
    assert_equal true, %|= abcTRUE|
  end
end
