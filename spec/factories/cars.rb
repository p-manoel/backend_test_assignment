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
FactoryBot.define do
  factory :car do
    model { Faker::Vehicle.model }
    price { Faker::Number.between(from: 1_000, to: 100_000) }
    association :brand
  end
end
