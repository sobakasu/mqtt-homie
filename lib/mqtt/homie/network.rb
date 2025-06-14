require "macaddr"

module MQTT
  module Homie
    module Network
      def default_localip
        addr = default_interface[:addresses][0] if default_interface
        addr ? addr.ip_address : nil
      end

      def default_mac
        (default_interface ? default_interface[:hwaddr] : nil) || Mac.addr
      end

      def default_interface
        @default_interface ||= interfaces.values.first
      end

      def interfaces
        @interfaces ||= begin
          interfaces = {}
          Socket.getifaddrs.each do |ifaddr|
            ifname = ifaddr.name
            next if ifname == "lo"
            next unless addr = ifaddr.addr

            data = interfaces[ifname] ||= { addresses: [] }
            data[:name] = ifname
            data[:hwaddr] = $1 if addr.inspect.match(/hwaddr=([0-9a-fA-F:]+)/)  # doesn't work on windows
            if (addr.ipv4? || addr.ipv6?) && usable_address?(addr)
              data[:addresses].push addr
            end
          end
          interfaces
        end
      end

      def usable_address?(addr)
        !(addr.ipv4_loopback? || addr.ipv6_loopback? || addr.ipv4_multicast? || addr.ipv6_linklocal?)
      end
    end
  end
end
