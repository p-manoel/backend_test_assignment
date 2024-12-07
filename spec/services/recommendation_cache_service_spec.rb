require 'rails_helper'

RSpec.describe RecommendationCacheService do
  describe '.get_recommendations' do
    let(:user_id) { 1 }
    let(:cache_key) { "#{described_class::CACHE_KEY_PREFIX}:#{user_id}" }

    let(:api_response) do
      [
        { "car_id" => 179, "rank_score" => 0.945 },
        { "car_id" => 5, "rank_score" => 0.4552 }
      ]
    end

    let(:formatted_response) do
      {
        179 => 0.945,
        5 => 0.4552
      }
    end

    context 'when cache is empty' do
      before do
        Rails.cache.clear
        allow(ExternalRecommendationService).to receive(:fetch_recommendations)
          .with(user_id)
          .and_return(api_response)
      end

      it 'fetches data from external service' do
        expect(ExternalRecommendationService).to receive(:fetch_recommendations).with(user_id)
        described_class.get_recommendations(user_id)
      end

      it 'formats and returns the recommendations' do
        expect(described_class.get_recommendations(user_id)).to eq(formatted_response)
      end

      it 'caches the formatted response' do
        described_class.get_recommendations(user_id)
        expect(Rails.cache.read(cache_key)).to eq(formatted_response)
      end
    end

    context 'when cache exists' do
      before do
        Rails.cache.write(cache_key, formatted_response)
      end

      it 'returns cached data without calling external service' do
        expect(ExternalRecommendationService).not_to receive(:fetch_recommendations)
        expect(described_class.get_recommendations(user_id)).to eq(formatted_response)
      end
    end

    context 'when external service returns empty array' do
      before do
        Rails.cache.clear
        allow(ExternalRecommendationService).to receive(:fetch_recommendations)
          .with(user_id)
          .and_return([])
      end

      it 'returns empty hash' do
        expect(described_class.get_recommendations(user_id)).to eq({})
      end
    end
  end
end
