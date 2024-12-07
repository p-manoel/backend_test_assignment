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
require 'rails_helper'

RSpec.describe UserPreferredBrand, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:brand) }
  end

  describe 'validations' do
    subject { build(:user_preferred_brand) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:brand_id) }
  end
end
