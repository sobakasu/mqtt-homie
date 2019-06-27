RSpec.describe MQTT::Homie::Node do
  context "new" do
    it "creates a node" do
      node = described_class.new(id: "test", name: "test", type: "test", properties: [])
      expect(node).to be
      expect(node.name).to eq("test")
    end
  end

  context "homie_attributes" do
    it "has homie attributes" do
      node = described_class.new(id: "test", name: "test", type: "test", properties: [])
      data = node.homie_attributes
      expect(data).to be
      expect(data).to include("$name")
    end

    it "includes property attributes" do
      property = MQTT::Homie::Property.new(id: "prop", datatype: "string", name: "test property")
      node = described_class.new(id: "test", name: "test", type: "test", properties: [property])
      data = node.homie_attributes
      #p data
      expect(data).to be
      expect(data).to include("prop/$name")
    end
  end
end
