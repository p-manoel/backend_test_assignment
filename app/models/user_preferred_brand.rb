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
class UserPreferredBrand < ApplicationRecord
  belongs_to :user
  belongs_to :brand
end
