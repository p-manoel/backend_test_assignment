require 'rails_helper'

RSpec.describe LabelService do
  describe '.determine_label' do
    let(:brand) { create(:brand) }
    let(:user) { create(:user, preferred_price_range: 10_000..50_000) }
    let!(:user_preferred_brand) { create(:user_preferred_brand, user: user, brand: brand) }

    context 'when car matches both brand and price preferences' do
      let(:car) { create(:car, brand: brand, price: 25_000) }

      it 'returns perfect_match' do
        expect(described_class.determine_label(car, user)).to eq('perfect_match')
      end
    end

    context 'when car matches only brand preference' do
      let(:car) { create(:car, brand: brand, price: 75_000) }

      it 'returns good_match' do
        expect(described_class.determine_label(car, user)).to eq('good_match')
      end
    end

    context 'when car matches neither preference' do
      let(:other_brand) { create(:brand) }
      let(:car) { create(:car, brand: other_brand, price: 75_000) }

      it 'returns nil' do
        expect(described_class.determine_label(car, user)).to be_nil
      end
    end

    context 'when car is nil' do
      it 'returns nil' do
        expect(described_class.determine_label(nil, user)).to be_nil
      end
    end

    context 'when user is nil' do
      let(:car) { create(:car) }

      it 'returns nil' do
        expect(described_class.determine_label(car, nil)).to be_nil
      end
    end
  end
end
