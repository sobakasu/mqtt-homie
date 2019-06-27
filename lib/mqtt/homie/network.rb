module MQTT
  module Homie
    module Network
      def default_localip
        addr = default_interface[:addresses][0] if default_interface
        addr ? addr.ip_address : nil
      end

      def default_mac
        (default_interface ? default_interface[:hwaddr] : nil) || "00:00:00:00:00:00"
      end

      def default_interface
        @default_interface ||= interfaces.values.find { |i| i[:default] }
      end

      def interfaces
        @interfaces ||= begin
          interfaces = {}
          found = false
          Socket.getifaddrs.each do |ifaddr|
            ifname = ifaddr.name
            data = interfaces[ifname] ||= { addresses: [] }
            next unless addr = ifaddr.addr
            data[:addresses].push addr if (addr.ipv4? || addr.ipv6?) && usable_address?(addr)
            data[:hwaddr] = $1 if addr.inspect.match(/hwaddr=([0-9a-fA-F:]+)/)  # doesn't work on windows
            data[:default] = true unless found
            data[:name] = ifname
            found = true
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
