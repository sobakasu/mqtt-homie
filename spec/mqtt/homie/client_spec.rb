RSpec.describe MQTT::Homie::Client do
  context "new" do
    it "creates a client" do
      device = MQTT::Homie::Device.new(id: "device")
      client = described_class.new(device: device, host: "localhost")
      expect(client).to be
    end

    it "requires a device" do
      expect {
        client = described_class.new
      }.to raise_error(/device required/)
    end
  end

  context "publishing" do
    it "should publish changes to property values" do
      client = create_client
      client.connect
      property = client.device.node("node").property("prop1")
      expect(client).to receive(:publish_property_value)
      property.value = "new value"
      client.disconnect
      sleep(1)
    end
  end

  context "connect" do
    it "connects to a MQTT broker" do
      client = create_client
      client.connect
      expect(client).to be_connected
      client.disconnect
      sleep(1)
    end
  end

  private

  def create_client
    mqtt_client = double(:mqtt_client)
    allow(mqtt_client).to receive(:will_topic=)
    allow(mqtt_client).to receive(:will_payload=)
    allow(mqtt_client).to receive(:will_retain=)
    expect(mqtt_client).to receive(:connect)
    allow(mqtt_client).to receive(:disconnect)
    allow(mqtt_client).to receive(:publish)
    allow(mqtt_client).to receive(:get)

    device = MQTT::Homie.device_builder(id: "device").node(id: "node", name: "node", type: "node").
      property(id: "prop1", settable: true).build
    client = described_class.new(device: device, host: "localhost")
    allow(client).to receive(:create_mqtt_client).and_return(mqtt_client)
    client
  end
end
