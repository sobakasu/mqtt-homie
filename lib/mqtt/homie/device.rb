require "sys/uname"
require "socket"

module MQTT
  module Homie
    class Device < HomieObject
      HOMIE_VERSION = "3.0.1"
      DEFAULT_STAT_REFRESH = 60  # seconds
      DEFAULT_IMPLEMENTATION = "mqtt-homie"

      attr_reader :nodes, :id, :mac, :fw_name, :fw_version, :name, :implementation, :interval
      attr_accessor :state

      def initialize(options = {})
        super(options)
        @boot_time = Time.now
        @state = :init

        @name = set(options, :name, required: true)
        @interval = set(options, :interval, default: DEFAULT_STAT_REFRESH, required: true)
        @nodes = set(options, :nodes, data_type: Array, default: [])
        @localip = set(options, :localip, default: default_localip, required: true)
        @mac = set(options, :mac, default: default_mac, required: true)
        @implementation = set(options, :implementation, default: DEFAULT_IMPLEMENTATION)
        @fw_name = set(options, :fw_name, default: default_fw_name, required: true)
        @fw_version = set(options, :fw_version, default: default_fw_version, required: true)
      end

      def topic
        @id
      end

      def node(id)
        @nodes.find { |i| i.id == id }
      end

      # device attributes must be sent when connection to broker is established or re-established
      # homie/device_id/
      def homie_attributes
        data = {
          "$homie" => HOMIE_VERSION,
          "$name" => @name,
          "$localip" => @localip,
          "$mac" => @mac,
          "$fw/name" => @fw_name,
          "$fw/version" => @fw_version,
          "$nodes" => @nodes.collect { |i| i.id }.join(","),
          "$implementation" => @implementation,
          "$state" => @state,
        }
        @nodes.each do |node|
          node.homie_attributes.each do |k, v|
            data[node.topic + "/" + k] = v
          end
        end
        data
      end

      # statistics should be sent every INTERVAL seconds
      # homie/device_id/$stats
      def statistics
        {
          "uptime" => (Time.now - @boot_time).to_i,
          #"signal" => 100,  # TODO wifi signal strength
          #"cputemp" => 0,
          #"cpuload" => stats.load_average.one_minute,
          #"battery" => 100,
          #"freeheap" => stats.memory.free,
          #"supply" => 5,
          "interval" => @interval * 2,
        }
      end

      def default_localip
        default_interface[:addresses][0] if default_interface
      end

      def default_mac
        (default_interface ? default_interface[:hwaddr] : nil) || "00:00:00:00:00:00"
      end

      def default_fw_name
        uname.sysname rescue uname.caption rescue "Unknown"
      end

      def default_fw_version
        uname.release rescue uname.build_number rescue "Unknown"
      end

      def uname
        @uname ||= Sys::Uname.uname
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
            data[:addresses].push addr if (addr.ipv4? || addr.ipv6?) && !(addr.ipv4_loopback? || addr.ipv6_loopback?)
            data[:hwaddr] = $1 if addr.inspect.match(/hwaddr=([0-9a-fA-F:]+)/)  # doesn't work on windows
            data[:default] = true unless found
            data[:name] = ifname
            found = true
          end
          interfaces
        end
      end
    end
  end
end
