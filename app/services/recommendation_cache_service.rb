class RecommendationCacheService
  CACHE_KEY_PREFIX = "user_recommendations"
  CACHE_EXPIRY = 24.hours

  def self.get_recommendations(user_id)
    Rails.cache.fetch("#{CACHE_KEY_PREFIX}:#{user_id}", expires_in: CACHE_EXPIRY) do
      recommendations = ExternalRecommendationService.fetch_recommendations(user_id)
      recommendations.each_with_object({}) do |rec, hash|
        hash[rec["car_id"]] = rec["rank_score"]
      end
    end
  end
end
