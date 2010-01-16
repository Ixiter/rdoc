require 'rubygems'
require 'minitest/autorun'
require 'rdoc'
require 'rdoc/text'

class TestRDocText < MiniTest::Unit::TestCase

  include RDoc::Text

  def test_expand_tabs
    assert_equal("hello\n  dave",
                 expand_tabs("hello\n  dave"), 'spaces')

    assert_equal("hello\n        dave",
                 expand_tabs("hello\n\tdave"), 'tab')

    assert_equal("hello\n        dave",
                 expand_tabs("hello\n \tdave"), '1 space tab')

    assert_equal("hello\n        dave",
                 expand_tabs("hello\n  \tdave"), '2 space tab')

    assert_equal("hello\n        dave",
                 expand_tabs("hello\n   \tdave"), '3 space tab')

    assert_equal("hello\n        dave",
                 expand_tabs("hello\n    \tdave"), '4 space tab')

    assert_equal("hello\n        dave",
                 expand_tabs("hello\n     \tdave"), '5 space tab')

    assert_equal("hello\n        dave",
                 expand_tabs("hello\n      \tdave"), '6 space tab')

    assert_equal("hello\n        dave",
                 expand_tabs("hello\n       \tdave"), '7 space tab')

    assert_equal("hello\n                dave",
                 expand_tabs("hello\n         \tdave"), '8 space tab')

    assert_equal('.               .',
                 expand_tabs(".\t\t."), 'dot tab tab dot')
  end

  def test_flush_left
    text = <<-TEXT
  
  we don't worry too much.
 
  The comments associated with
    TEXT

    expected = <<-EXPECTED

we don't worry too much.

The comments associated with
    EXPECTED

    assert_equal expected, flush_left(text)
  end

  def test_normalize_comment
    text = <<-TEXT
##
# we don't worry too much.
#
# The comments associated with
    TEXT

    expected = <<-EXPECTED

we don't worry too much.

The comments associated with
    EXPECTED

    assert_equal expected, normalize_comment(text)
  end

  def test_strip_hashes
    text = <<-TEXT
##
# we don't worry too much.
#
# The comments associated with
    TEXT

    expected = <<-EXPECTED
  
  we don't worry too much.
 
  The comments associated with
    EXPECTED

    assert_equal expected, strip_hashes(text)
  end

end
