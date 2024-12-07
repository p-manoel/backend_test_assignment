require 'rails_helper'

RSpec.describe CarQueryService do
  let(:user) { create(:user, preferred_price_range: 10_000..50_000) }
  let(:brand) { create(:brand, name: 'Toyota') }
  let(:other_brand) { create(:brand, name: 'Honda') }
  let!(:user_preferred_brand) { create(:user_preferred_brand, user: user, brand: brand) }

  let!(:perfect_match_car) { create(:car, brand: brand, price: 25_000) }
  let!(:good_match_car) { create(:car, brand: brand, price: 75_000) }
  let!(:no_match_car) { create(:car, brand: other_brand, price: 75_000) }

  let(:rank_scores) do
    {
      perfect_match_car.id.to_s => 0.8,
      good_match_car.id.to_s => 0.6,
      no_match_car.id.to_s => 0.4
    }
  end

  before do
    allow(RecommendationCacheService).to receive(:get_recommendations)
      .with(user.id)
      .and_return(rank_scores)
  end

  describe '#call' do
    context 'with no filters' do
      subject(:service) { described_class.new(user_id: user.id) }

      it 'returns cars sorted by label priority and rank score' do
        result = service.call
        expect(result[:cars]).to eq([perfect_match_car, good_match_car, no_match_car])
      end
    end

    context 'with brand name filter' do
      subject(:service) { described_class.new(user_id: user.id, query: 'toy') }

      it 'returns only matching brand cars' do
        result = service.call
        expect(result[:cars]).to eq([perfect_match_car, good_match_car])
      end
    end

    context 'with price range filter' do
      subject(:service) { described_class.new(user_id: user.id, price_min: 20_000, price_max: 30_000) }

      it 'returns only cars within price range' do
        result = service.call
        expect(result[:cars]).to eq([perfect_match_car])
      end
    end

    context 'with pagination' do
      before do
        stub_const("#{described_class}::PER_PAGE", 2)
      end

      it 'returns first page' do
        service = described_class.new(user_id: user.id, page: 1)
        result = service.call
        expect(result[:cars]).to eq([perfect_match_car, good_match_car])
        expect(result[:page]).to eq(1)
        expect(result[:total_count]).to eq(3)
      end

      it 'returns second page' do
        service = described_class.new(user_id: user.id, page: 2)
        result = service.call
        expect(result[:cars]).to eq([no_match_car])
        expect(result[:page]).to eq(2)
        expect(result[:total_count]).to eq(3)
      end
    end

    context 'with invalid page number' do
      subject(:service) { described_class.new(user_id: user.id, page: 0) }

      it 'defaults to page 1' do
        result = service.call
        expect(result[:page]).to eq(1)
      end
    end
  end
end 
