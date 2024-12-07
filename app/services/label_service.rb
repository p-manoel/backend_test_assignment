class LabelService
  def self.determine_label(car, user)
    return nil unless car && user

    if perfect_match?(car, user)
      'perfect_match'
    elsif good_match?(car, user)
      'good_match'
    end
  end

  private

  def self.perfect_match?(car, user)
    user.preferred_brands.include?(car.brand) &&
      user.preferred_price_range.cover?(car.price)
  end

  def self.good_match?(car, user)
    user.preferred_brands.include?(car.brand)
  end
end
