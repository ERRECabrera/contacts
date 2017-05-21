class Relation < ApplicationRecord
  #relations
  belongs_to :user
  belongs_to :contact, class_name: 'User'

  #constants
  TYPE_RELATIONS = {
    friend: 0,
    family: 1,
    partner: 2
  }

  #validations
  validates :user_id, :contact_id, :_type, presence: true
  validates :user_id, :contact_id, numericality: true
  validate :is_duplicated?
  validate :exist_user_references?
  # enum _type has his own validation inclusion

  #vars
  enum _type: TYPE_RELATIONS

  #custom_validations
  def is_duplicated?
    if Relation.exist_before?(self.user_id,self.contact_id)
      errors.add(:contact_id, "There is a relation before")
    end
  end

  def exist_user_references?
    {user_id: user_id, contact_id: contact_id}.each do |key,id|
      begin
        User.find(id)
      rescue ActiveRecord::RecordNotFound => e
        errors.add(key, e.message)
      end
    end
  end

  #callbacks
  #auto create inverse relation between users
  after_commit(on: :create) do
    if not exist_inverse_relation?
      create_inverse_relation
    end
  end

  #class method
  def self.exist_before?(user_id,contact_id)
    return find_by(user_id: user_id, contact_id: contact_id) ? true : false
  end

  private

  def exist_inverse_relation?
    return contact.has_relation?(self.user_id) ? true : false
  end

  def create_inverse_relation
    contact.create_relation(self._type,self.user_id)
  end

end
