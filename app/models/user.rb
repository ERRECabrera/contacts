class User < ApplicationRecord
  #relations
  has_many :relations
  has_many :contacts, source: :contact, through: :relations
  has_many :friends, -> { where "_type = 0" }, source: :contact, through: :relations
  has_many :family, -> { where "_type = 1" }, source: :contact, through: :relations
  has_many :partners, -> { where "_type = 2" }, source: :contact, through: :relations

  #validations
  validates :name, :surnames, :email, presence: true
  validates :email, uniqueness: true, email: true
  validates :phones, :avatar, allow: nil
  validate :check_phones, if: Proc.new {|u| u.phones and u.phones.any? }
  validate :check_avatar, if: Proc.new {|u| !u.avatar.nil? }

  #custom_validations
  def check_phones
    valid_phone = phones.any? do |phone|
      Phonelib.parse(phone).possible?
    end
    if not valid_phone
      errors.add(:phones, "There is not a valid phone")
    end
  end

  def check_avatar
    encode_b64 = true if Base64.strict_decode64(avatar) rescue false
    if not encode_b64
      errors.add(:avatar, "This image don't be encoded in Base64")
    end
  end

  #scopes
  scope :named, -> (name) { where(name: name) }
  scope :surnamed, -> (surnames) { where("surnames && ARRAY[?]::varchar[]",surnames) }

  #model methods
  def create_relation(type,new_contact_id)
    new_relation = relations.create
    new_relation.contact_id = new_contact_id
    new_relation._type = type
    new_relation.save
    #return true if it's saved
  end

  def has_relation?(contact_id)
    Relation.find_by(user_id: self.id, contact_id: contact_id)
    #return relation or nil
  end

end
