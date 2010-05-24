require 'pathname'
$LOAD_PATH.unshift Pathname.new(__FILE__).dirname.expand_path
require 'test_helper'

require 'ponder/irc'
require 'ostruct'
include Ponder::IRC

module Ponder
  module IRC
    def raw(message)
      $output << "#{message}\r\n"
      return "#{message}\r\n"
    end
  end
end

class TestIRC < Test::Unit::TestCase
  def setup
    @config = ::OpenStruct.new({:nick    => 'Ponder',
                              :realname  => 'Ponder Stibbons',
                              :password  => 'secret',
                              :reconnect => true
                             })
    $output = []
  end
  
  def test_message
    assert_equal("PRIVMSG recipient :foo\r\n", Ponder::IRC.message('recipient', 'foo')) # `message` is already defined, so we need to use Ponder::IRC
  end
  
  def test_register
    register
    
    assert_equal(["NICK Ponder\r\n", "USER Ponder 0 * :Ponder Stibbons\r\n", "PASS secret\r\n"], $output)
  end
  
  def test_register_without_password
    @config.password = nil
    register
    
    assert_equal(["NICK Ponder\r\n", "USER Ponder 0 * :Ponder Stibbons\r\n"], $output)
  end
  
  def test_notice
    assert_equal("NOTICE Ponder :You are cool!\r\n", notice('Ponder', 'You are cool!'))
  end
  
  def test_mode
    assert_equal("MODE Ponder +ao\r\n", mode('Ponder', '+ao'))
  end
  
  def test_kick_without_reason
    assert_equal("KICK #channel Nanny_Ogg\r\n", kick('#channel', 'Nanny_Ogg'))
  end
  
  def test_kick_with_reason
    assert_equal("KICK #channel Nanny_Ogg :Go away!\r\n", kick('#channel', 'Nanny_Ogg', 'Go away!'))
  end
  
  def test_action
    assert_equal("PRIVMSG #channel :\001ACTION HEX is working!\001\r\n", action('#channel', 'HEX is working!'))
  end
  
  def test_topic
    assert_equal("TOPIC #channel :I like dried frog pills.\r\n", topic('#channel', 'I like dried frog pills.'))
  end
  
  def test_join_without_password
    assert_equal("JOIN #channel\r\n", join('#channel'))
  end
  
  def test_join_with_password
    assert_equal("JOIN #channel secret\r\n", join('#channel', 'secret'))
  end
  
  def test_part_without_message
    assert_equal("PART #channel\r\n", part('#channel'))
  end
  
  def test_part_with_message
    assert_equal("PART #channel :Partpart\r\n", part('#channel', 'Partpart'))
  end
  
  def test_quit_without_message
    quit
    
    assert_equal(["QUIT\r\n"], $output)
  end
    
  def test_quit_with_message
    quit('GONE')
    
    assert_equal(["QUIT :GONE\r\n"], $output)
  end
  
  def test_quit_reconnect_change
    assert_equal(true, @config.reconnect)
    
    quit
    
    assert_equal(false, @config.reconnect)
  end
end
