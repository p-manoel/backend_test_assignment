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
        schema type: :object,
          properties: {
            cars: {
              type: :array,
              items: { '$ref' => '#/components/schemas/car' }
            },
            total_count: { type: :integer },
            page: { type: :integer }
          },
          required: ['cars', 'total_count', 'page']

        let(:user) { create(:user, preferred_price_range: 10_000..50_000) }
        let(:brand) { create(:brand, name: 'Toyota') }
        let!(:user_preferred_brand) { create(:user_preferred_brand, user: user, brand: brand) }
        let!(:car) { create(:car, brand: brand, price: 25_000) }
        let(:user_id) { user.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['cars']).to be_an(Array)
          expect(data['total_count']).to be_an(Integer)
          expect(data['page']).to be_an(Integer)
        end
      end

      response '400', 'bad request' do
        schema '$ref' => '#/components/schemas/error'

        run_test! do |response|
          expect(response.body).to include('Missing required parameters')
        end
      end

      response '404', 'user not found' do
        schema '$ref' => '#/components/schemas/error'
        let(:user_id) { 0 }

        run_test! do |response|
          expect(response.body).to include('Resource not found')
        end
      end
    end
  end
end 
