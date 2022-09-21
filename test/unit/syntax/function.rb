require_relative '../shared'
# note that most 

section 'functions' do
  it 'parses trailing word function letters' do
    assert_runs %|L 1|
    assert_runs %|RAND|
    assert_runs %|RANDOM|
    assert_runs %|RAND_INT|
    assert_runs %|RAND_OM_NUMBER|
    assert_runs %|R___|
  end

  it 'does not parse digits or lower-case letters' do
    assert_result 1, %|L1|
    assert_result 3, %|LENGTH123|
    assert_result 1, %|; = a 3 : LENa|
    assert_result 2, %|; = a 13 : L_a|
    assert_result 4, %|; = a 9514 : LENGTH_a|
    assert_result 0, %|; = a @ : LE_N_G__TH_a|
    assert_result 0, %|; = a @ : L#{[*'A'..'Z'].join}_a|
  end

  it 'does not parse trailing tokens for symbolic functions' do
    assert_result [], %|+@@|
    assert_result '3true', %|++ "" 3 TRUE|
  end
end
