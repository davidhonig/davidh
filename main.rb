require 'socket'

Socket.ip_address_list.each do |addr|
  puts addr.ip_address if addr.ipv4? && !addr.ipv4_loopback?
end