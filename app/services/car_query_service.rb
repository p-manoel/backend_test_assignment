class CarQueryService
  PER_PAGE = 20

  def initialize(user_id:, query: nil, price_min: nil, price_max: nil, page: 1)
    @user = User.find(user_id)
    @query = query
    @price_min = price_min.presence&.to_i
    @price_max = price_max.presence&.to_i
    @page = [page.to_i, 1].max
    @recommendations = RecommendationCacheService.get_recommendations(@user.id)
  end

  def call
    cars = Car.joins(:brand).select('cars.*, brands.name as brand_name, brands.id as brand_id')
    cars = filter_by_brand_name(cars)
    cars = filter_by_price_range(cars)
    sorted_cars = sort_cars(cars)

    paginated_cars = paginate(sorted_cars)
    format_response(paginated_cars)
  end

  private

  def filter_by_brand_name(cars)
    return cars if @query.blank?

    cars.where('LOWER(brands.name) LIKE LOWER(?)', "%#{@query}%")
  end

  def filter_by_price_range(cars)
    return cars.where(price: @price_min..@price_max) if @price_min && @price_max

    cars = cars.where('price >= ?', @price_min) if @price_min
    cars = cars.where('price <= ?', @price_max) if @price_max
    cars
  end

  def sort_cars(cars)
    # Cache user preferences to avoid repeated lookups
    preferred_brand_ids = @user.preferred_brands.pluck(:id)
    price_range = @user.preferred_price_range

    cars
      .select("
        cars.*,
        brands.name as brand_name,
        brands.id as brand_id,
        CASE
          WHEN brands.id = ANY(ARRAY[#{preferred_brand_ids.join(',')}])
           AND cars.price BETWEEN #{price_range.begin} AND #{price_range.end}
          THEN 2
          WHEN brands.id = ANY(ARRAY[#{preferred_brand_ids.join(',')}])
          THEN 1
          ELSE 0
        END as label_priority,
        #{rank_score_sql} as rank_score
      ")
      .joins(:brand)  # Use Active Record association instead of raw LEFT JOIN
      .order('label_priority DESC, rank_score DESC, price ASC')
  end

  def rank_score_sql
    scores = @recommendations.map { |id, score| "(CASE WHEN cars.id = #{id} THEN #{score} ELSE 0 END)" }

    scores.any? ? "GREATEST(#{scores.join(', ')})" : '0'
  end

  def paginate(cars)
    start_index = (@page - 1) * PER_PAGE
    cars[start_index, PER_PAGE] || []
  end

  def format_response(cars)
    car_ids = cars.map(&:id)
    recommendations = @recommendations.slice(*car_ids)

    cars.map do |car|
      {
        id: car.id,
        brand: {
          id: car.brand_id,
          name: car.brand_name
        },
        model: car.model,
        price: car.price,
        rank_score: recommendations[car.id] || 0,
        label: LabelService.determine_label(car, @user)
      }
    end
  end
end
