class User < ApplicationRecord

  #validations
  validates :name, :surnames, :email, presence: true
  validates :email, uniqueness: true, email: true
  validates :phones, :avatar, allow: nil
  validate :check_phones, if: Proc.new {|u| u.phones and u.phones.any? }
  validate :check_avatar, if: Proc.new {|u| !u.avatar.nil? }

  def check_phones
    valid_phone = phones.any? do |phone|
      Phonelib.parse(phone).possible?
    end
    if not valid_phone
      errors.add(:phones, "there is no valid phone")
    end
  end

  def check_avatar
    encode_b64 = true if Base64.strict_decode64(avatar) rescue false
    if not encode_b64
      errors.add(:avatar, "this image don't be encoded in Base64")
    end
  end

end
