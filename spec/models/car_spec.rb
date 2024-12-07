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
require 'rails_helper'

RSpec.describe Car, type: :model do
  describe 'associations' do
    it { should belong_to(:brand) }
  end

  describe 'validations' do
    it { should validate_presence_of(:model) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than(0) }
  end
end
