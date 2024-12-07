require 'rails_helper'

RSpec.describe "Cars API Integration", type: :request do
  let(:user) { create(:user, preferred_price_range: 20_000..50_000) }
  let(:toyota) { create(:brand, name: 'Toyota') }
  let(:honda) { create(:brand, name: 'Honda') }
  let!(:user_preferred_brand) { create(:user_preferred_brand, user: user, brand: toyota) }

  let!(:perfect_match) { create(:car, brand: toyota, model: 'Camry', price: 25_000) }
  let!(:good_match) { create(:car, brand: toyota, model: 'Land Cruiser', price: 80_000) }
  let!(:high_rank_no_match) { create(:car, brand: honda, model: 'CR-V', price: 35_000) }

  let(:rank_scores) do
    {
      perfect_match.id.to_s => 0.95,
      good_match.id.to_s => 0.75,
      high_rank_no_match.id.to_s => 0.85
    }
  end

  before do
    allow(ExternalRecommendationService).to receive(:fetch_recommendations)
      .with(user.id.to_s)
      .and_return(rank_scores.map { |id, score| { "car_id" => id, "rank_score" => score } })
  end

  describe "GET /api/v1/cars" do
    it "returns a complete response with all components working together" do
      get "/api/v1/cars", params: { user_id: user.id }

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)

      expect(json).to include('cars', 'total_count', 'page')

      cars = json['cars']
      expect(cars.size).to eq(3)

      expect(cars[0]).to include(
        'brand' => 'Toyota',
        'model' => 'Camry',
        'price' => 25_000,
        'label' => 'perfect_match'
      )

      expect(cars[1]).to include(
        'brand' => 'Toyota',
        'model' => 'Land Cruiser',
        'price' => 80_000,
        'label' => 'good_match'
      )

      expect(cars[2]).to include(
        'brand' => 'Honda',
        'model' => 'CR-V',
        'price' => 35_000,
        'label' => nil
      )
    end

    it "uses caching for recommendations" do
      expect(ExternalRecommendationService).to receive(:fetch_recommendations).once

      2.times do
        get "/api/v1/cars", params: { user_id: user.id }
        expect(response).to have_http_status(:success)
      end
    end

    it "handles all filters together" do
      get "/api/v1/cars", params: {
        user_id: user.id,
        query: 'toy',
        price_min: 20_000,
        price_max: 30_000
      }

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)

      expect(json['cars'].size).to eq(1)
      expect(json['cars'].first).to include(
        'brand' => 'Toyota',
        'model' => 'Camry',
        'price' => 25_000
      )
    end
  end
end
