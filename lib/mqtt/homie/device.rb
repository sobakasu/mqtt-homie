require "sys/uname"

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
        @name = options[:name]
        @start_time = Time.now
        @interval = set(options, :interval, default: DEFAULT_STAT_REFRESH)
        @nodes = set(options, :nodes, data_type: Array, default: [])
        @state = :init
        @localip = set(options, :localip, default: default_localip)
        @mac = set(options, :mac, default: default_mac)
        @implementation = set(options, :implementation, default: DEFAULT_IMPLEMENTATION)
        @fw_name = set(options, :fw_name, default: default_fw_name)
        @fw_version = set(options, :fw_version, default: default_fw_version)
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
          "$fw/name" => @fw_name || "mqtt-homie",
          "$fw/version" => @fw_version || MQTT::Homie::VERSION,
          "$nodes" => @nodes.collect { |i| i.id }.join(","),
          "$implementation" => @implementation,
          "$state" => @state.to_s,
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
          "uptime" => (Time.now - @start_time).to_i,
          #"signal" => 100,  # TODO wifi signal strength
          #"cputemp" => 0,
          #"cpuload" => stats.load_average.one_minute,
          #"battery" => 100,
          #"freeheap" => stats.memory.free,
          #"supply" => 5,
          "interval" => @interval * 2,
        }
      end

      def update(time, node)
        # node value updated
      end

      def default_localip
        nil # TODO
      end

      def default_mac
        nil # TODO
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
    end
  end
end
