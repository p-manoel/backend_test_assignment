# == Schema Information
#
# Table name: user_preferred_brands
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null, indexed
#  brand_id   :bigint           not null, indexed
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :user_preferred_brand do
    association :user
    association :brand
  end
end
