module MQTT
  module Homie
    # https://homieiot.github.io/specification/

    class Client
      DEFAULT_ROOT_TOPIC = "homie"

      attr_accessor :host, :root_topic
      attr_reader :device

      def initialize(options = {})
        @device = options[:device]
        @host = options[:host]
        @root_topic = options[:root_topic] || DEFAULT_ROOT_TOPIC

        raise "device required" unless @device

        # next version of homie doesn't use stats or firmware details
        @use_stats = true
        if options[:develop]
          @device.use_stats = false
          @device.use_fw = false
          @use_stats = false
        end

        # observe all node properties so we can publish values when they change
        @device.nodes.each do |node|
          node.properties.each do |property|
            property.add_observer(self)
          end
        end
      end

      def connect
        return if connected?

        @device.state = :init
        @client = create_mqtt_client
        @client.connect

        publish(@device, topic)
        publish_statistics if @use_stats

        @threads = []

        # run a thread to publish statistics
        @threads << Thread.new { run_statistics } if @use_stats

        # run a thread to listen for settings
        @threads << Thread.new { run_set_listener }

        @device.state = :ready
        publish_state
      end

      def disconnect
        @device.state = :disconnected
        publish_state

        @client.disconnect
        @client = nil

        @threads.each { |i| i[:done] = true }
        @threads = []
      end

      def topic
        @root_topic + "/" + @device.id
      end

      def connected?
        @device.state == :ready
      end

      def update(time, object)
        if object.kind_of?(MQTT::Homie::Property)
          publish_property_value(object)
        end
      end

      private

      def create_mqtt_client
        client = ::MQTT::Client.new
        client.host = @host
        client.will_topic = topic + "/$state"
        client.will_payload = :lost
        client.will_retain = true
        client
      end

      def run_set_listener
        # subscribe to 'set' topics for all settable properties
        @device.nodes.each do |node|
          node.properties.each do |property|
            if property.settable?
              set_topic = topic + "/" + node.topic + "/" + property.topic + "/set"
              debug("subscribe #{set_topic}")
              @client.subscribe(set_topic) if @client
            end
          end
        end

        if @client
          @client.get do |topic, message|
            debug("received message: #{topic}, message: #{message}")
            property = find_property_by_set_topic(topic)
            property.value = message if property
            break if Thread.current[:done]
          end
        end
        debug("set listener thread exiting")
      end

      def run_statistics
        while !Thread.current[:done]
          publish_statistics

          # halve interval, if we miss a notification then we will be marked as offline
          sleep @device.stats.interval / 2
        end
        debug("statistics thread exiting")
      end

      def find_property_by_set_topic(set_topic)
        @device.nodes.each do |node|
          node.properties.each do |property|
            return property if set_topic == topic + "/" + node.topic + "/" + property.topic + "/set"
          end
        end
        nil
      end

      def publish_statistics
        publish(@device.stats, topic + "/$stats")
      end

      def publish_property_value(property)
        node = @device.nodes.find { |i| i.properties.include?(property) }
        data = {
          property.id => property.value,
        }
        publish(data, topic + "/" + node.topic)
      end

      def publish_state
        data = {
          "$state" => @device.state,
        }
        publish(data, topic)
      end

      def publish(object, prefix = nil)
        data = {}
        if object.respond_to?(:homie_attributes)
          data = object.homie_attributes
        else
          data = object
        end

        data.each do |k, v|
          topic = prefix + "/" + k
          debug("mqtt publish #{topic} -> #{v}")
          @client.publish(topic, v, true)
        end
      end

      def debug(message)
        MQTT::Homie.debug(message)
      end
    end
  end
end
