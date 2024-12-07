# == Schema Information
#
# Table name: cars
#
#  id         :bigint           not null, primary key
#  model      :string
#  brand_id   :bigint           not null, indexed
#  price      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Car < ApplicationRecord
  belongs_to :brand
end
