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
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:user_preferred_brands).dependent(:destroy) }
    it { should have_many(:preferred_brands).through(:user_preferred_brands) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:preferred_price_range) }
  end
end
