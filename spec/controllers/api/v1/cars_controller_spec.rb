require 'rails_helper'

RSpec.describe Api::V1::CarsController, type: :controller do
  describe 'GET #index' do
    let(:user) { create(:user, preferred_price_range: 10_000..50_000) }
    let(:toyota) { create(:brand, name: 'Toyota') }
    let(:honda) { create(:brand, name: 'Honda') }
    let!(:user_preferred_brand) { create(:user_preferred_brand, user: user, brand: toyota) }

    let!(:perfect_match_car) do
      create(:car, brand: toyota, price: 25_000, model: 'Camry')
    end

    let!(:good_match_car) do
      create(:car, brand: toyota, price: 75_000, model: 'Land Cruiser')
    end

    let!(:high_rank_car) do
      create(:car, brand: honda, price: 60_000, model: 'CR-V')
    end

    let!(:low_rank_car) do
      create(:car, brand: honda, price: 30_000, model: 'Civic')
    end

    let(:rank_scores) do
      {
        perfect_match_car.id.to_s => 0.95,
        good_match_car.id.to_s => 0.75,
        high_rank_car.id.to_s => 0.85,
        low_rank_car.id.to_s => 0.45
      }
    end

    before do
      allow(RecommendationCacheService).to receive(:get_recommendations)
        .with(user.id.to_s)
        .and_return(rank_scores)
    end

    context 'with valid parameters' do
      it 'returns cars sorted by label priority, rank score, and price' do
        get :index, params: { user_id: user.id }

        expect(response).to have_http_status(:success)

        json_response = JSON.parse(response.body)
        cars = json_response['cars']

        expect(cars[0]).to include(
          'id' => perfect_match_car.id,
          'brand' => 'Toyota',
          'model' => 'Camry',
          'price' => 25_000,
          'label' => 'perfect_match'
        )

        expect(cars[1]).to include(
          'id' => good_match_car.id,
          'brand' => 'Toyota',
          'model' => 'Land Cruiser',
          'price' => 75_000,
          'label' => 'good_match'
        )

        expect(cars[2]).to include(
          'id' => high_rank_car.id,
          'brand' => 'Honda',
          'model' => 'CR-V',
          'price' => 60_000,
          'label' => nil
        )

        expect(cars[3]).to include(
          'id' => low_rank_car.id,
          'brand' => 'Honda',
          'model' => 'Civic',
          'price' => 30_000,
          'label' => nil
        )

        expect(json_response['total_count']).to eq(4)
        expect(json_response['page']).to eq(1)
      end
    end

    context 'with brand name filter' do
      it 'returns only Toyota cars' do
        get :index, params: { user_id: user.id, query: 'toy' }

        json_response = JSON.parse(response.body)
        expect(json_response['cars'].size).to eq(2)
        expect(json_response['cars'].map { |c| c['brand'] }).to all(eq('Toyota'))
      end

      it 'returns only Honda cars' do
        get :index, params: { user_id: user.id, query: 'hon' }

        json_response = JSON.parse(response.body)
        expect(json_response['cars'].size).to eq(2)
        expect(json_response['cars'].map { |c| c['brand'] }).to all(eq('Honda'))
      end
    end

    context 'with price range filter' do
      it 'returns cars within user preferred price range' do
        get :index, params: {
          user_id: user.id,
          price_min: 20_000,
          price_max: 35_000
        }

        json_response = JSON.parse(response.body)
        cars = json_response['cars']

        expect(cars.size).to eq(2)
        expect(cars.map { |c| c['price'] }).to all(be_between(20_000, 35_000))
      end
    end

    context 'with pagination' do
      before do
        stub_const("CarQueryService::PER_PAGE", 2)
      end

      it 'returns first page' do
        get :index, params: { user_id: user.id, page: 1 }

        json_response = JSON.parse(response.body)
        expect(json_response['cars'].size).to eq(2)
        expect(json_response['total_count']).to eq(4)
        expect(json_response['page']).to eq(1)
      end

      it 'returns second page' do
        get :index, params: { user_id: user.id, page: 2 }

        json_response = JSON.parse(response.body)
        expect(json_response['cars'].size).to eq(2)
        expect(json_response['total_count']).to eq(4)
        expect(json_response['page']).to eq(2)
      end
    end
  end
end