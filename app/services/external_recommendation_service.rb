class ExternalRecommendationService
  API_URL = "https://bravado-images-production.s3.amazonaws.com/recomended_cars.json"

  def self.fetch_recommendations(user_id)
    response = HTTParty.get(API_URL, query: { user_id: user_id })

    return [] unless response.success?

    response.parsed_response
  rescue StandardError => e
    Rails.logger.error("Failed to fetch recommendations: #{e.message}")
    []
  end
end
