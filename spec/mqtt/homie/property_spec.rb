RSpec.describe MQTT::Homie::Property do
  context "new" do
    it "creates a read only property by default" do
      property = described_class.new(id: "test")
      expect(property.settable?).to be_falsey
    end

    it "creates an enum property" do
      property = described_class.new(id: "test", settable: false, datatype: :enum, format: "value1,value2")
      expect(property).to be
      expect(property.datatype).to eq(:enum)
    end

    it "requires a format for an enum property" do
      expect {
        described_class.new(id: "test", settable: false, datatype: :enum)
      }.to raise_error(/format is required/)
    end

    it "creates an enum property and sets format" do
      property = described_class.new(id: "test", settable: false, enum: [:value1, :value2])
      expect(property).to be
      expect(property.datatype).to eq(:enum)
      expect(property.format).to eq("value1,value2")
    end

    it "creates an integer property" do
      property = described_class.new(id: "test", settable: false, datatype: :integer)
      expect(property).to be
      expect(property.datatype).to eq(:integer)
    end
  end

  context "homie_attributes" do
    it "has homie attributes" do
      property = described_class.new(id: "test", settable: false, datatype: :integer, value: 1)
      data = property.homie_attributes
      expect(data).to be
      expect(data).to include("$datatype")
    end
  end
end
