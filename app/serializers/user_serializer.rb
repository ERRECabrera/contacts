class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :surnames, :email, :phones, :avatar

  attribute :relation do
    if @instance_options[:user_id]
      object.has_relation?(@instance_options[:user_id]).try(:_type)
    else
      'undefined'
    end
  end
end
