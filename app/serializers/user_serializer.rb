class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :surnames, :email, :phones, :avatar
end
