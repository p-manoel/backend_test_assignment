require 'rails_helper'

RSpec.describe ExternalRecommendationService do
  describe '.fetch_recommendations' do
    let(:user_id) { 1 }
    let(:api_url) { "https://bravado-images-production.s3.amazonaws.com/recomended_cars.json" }

    context 'when the API request is successful' do
      let(:response_data) do
        [
          { "car_id" => 179, "rank_score" => 0.945 },
          { "car_id" => 5, "rank_score" => 0.4552 }
        ]
      end

      before do
        stub_request(:get, api_url)
          .with(query: { user_id: user_id })
          .to_return(
            status: 200,
            body: response_data.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns parsed recommendations' do
        result = described_class.fetch_recommendations(user_id)
        expect(result).to eq(response_data)
      end
    end

    context 'when the API returns 500 error' do
      before do
        stub_request(:get, api_url)
          .with(query: { user_id: user_id })
          .to_return(status: 500, body: '')
      end

      it 'returns an empty array' do
        result = described_class.fetch_recommendations(user_id)
        expect(result).to eq([])
      end
    end

    context 'when the API request times out' do
      before do
        stub_request(:get, api_url)
          .with(query: { user_id: user_id })
          .to_timeout
      end

      it 'returns an empty array' do
        result = described_class.fetch_recommendations(user_id)
        expect(result).to eq([])
      end

      it 'logs the timeout error' do
        expect(Rails.logger).to receive(:error).with(/Failed to fetch recommendations: execution expired/)
        described_class.fetch_recommendations(user_id)
      end
    end
  end
end
