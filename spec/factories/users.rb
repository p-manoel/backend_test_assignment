# == Schema Information
#
# Table name: users
#
#  id                    :bigint           not null, primary key
#  email                 :string
#  preferred_price_range :int8range
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    preferred_price_range { (10_000..50_000) }
  end
end
