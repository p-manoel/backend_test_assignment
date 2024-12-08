require 'swagger_helper'

RSpec.describe 'Cars API', type: :request do
  path '/api/v1/cars' do
    get 'Lists cars' do
      tags 'Cars'
      description 'Returns a list of cars sorted by match quality and recommendations'
      produces 'application/json'

      parameter name: :user_id, in: :query, type: :integer, required: true,
                description: 'ID of the user to get preferences and recommendations'
      parameter name: :query, in: :query, type: :string, required: false,
                description: 'Filter cars by brand name (case insensitive)'
      parameter name: :price_min, in: :query, type: :integer, required: false,
                description: 'Minimum price filter'
      parameter name: :price_max, in: :query, type: :integer, required: false,
                description: 'Maximum price filter'
      parameter name: :page, in: :query, type: :integer, required: false,
                description: 'Page number (defaults to 1)'

      response '200', 'cars found' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              brand: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string }
                },
                required: ['id', 'name']
              },
              model: { type: :string },
              price: { type: :integer },
              rank_score: { type: :number },
              label: { type: :string, nullable: true }
            },
            required: ['id', 'brand', 'model', 'price', 'rank_score', 'label']
          }

        let(:user) { create(:user, preferred_price_range: 10_000..50_000) }
        let(:brand) { create(:brand, name: 'Toyota') }
        let!(:user_preferred_brand) { create(:user_preferred_brand, user: user, brand: brand) }
        let!(:car) { create(:car, brand: brand, price: 25_000) }
        let(:user_id) { user.id }

        before do
          allow(RecommendationCacheService).to receive(:get_recommendations)
            .with(user.id)
            .and_return({ car.id => 0.95 })
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.first).to include(
            'id' => car.id,
            'brand' => {
              'id' => brand.id,
              'name' => brand.name
            },
            'model' => car.model,
            'price' => car.price,
            'rank_score' => 0.95,
            'label' => 'perfect_match'
          )
        end
      end
    end
  end
end
