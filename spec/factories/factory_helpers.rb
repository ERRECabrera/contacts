module FactoryHelpers

  def self.get_surnames
    (1..2).map{Faker::Name.last_name}
  end

  def self.get_valid_phones
    ['6','9'].map do |num|
      '+34'+num+Faker::Number.number(8).to_s
    end
  end

  def self.get_invalid_phones
    ['a','9'].map do |num|
      '+34'+num
    end
  end

  def self.get_valid_image(name)
    Base64.strict_encode64(File.read("#{Rails.root}/spec/fixtures/#{name}.jpg"))
  end

  def self.get_invalid_image(name)
    File.read("#{Rails.root}/spec/fixtures/#{name}.jpg")
  end

end