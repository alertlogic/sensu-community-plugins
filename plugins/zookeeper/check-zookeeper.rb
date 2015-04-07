#!/usr/bin/env ruby
require 'socket'
require 'timeout'

begin
  response = Timeout.timeout(30) do
    zk_socket = TCPSocket.new('localhost', 2181)
    zk_socket.print('ruok\n')
    zk_socket.read
  end

  rescue Timeout::Error
    puts "CRITICAL: Zookeeper health check timed out."
    exit 2
end

if ( response == 'imok' )
  puts "OK: Zookeeper is OK.  'imok' responded '#{response}'"
  exit 0
else
  puts "CRITICAL: Zookeeper is not OK.  'imok' responded '#{response}'"
  exit 2
end
