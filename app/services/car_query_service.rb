class CarQueryService
  PER_PAGE = 20

  def initialize(user_id:, query: nil, price_min: nil, price_max: nil, page: 1)
    @user = User.find(user_id)
    @query = query
    @price_min = price_min.presence&.to_i
    @price_max = price_max.presence&.to_i
    @page = [page.to_i, 1].max
    @rank_scores = RecommendationCacheService.get_recommendations(user_id)
  end

  def call
    cars = Car.includes(:brand)
    cars = filter_by_brand_name(cars)
    cars = filter_by_price_range(cars)

    sorted_cars = sort_cars(cars)
    paginate(sorted_cars)
  end

  private

  def filter_by_brand_name(cars)
    return cars if @query.blank?
    cars.joins(:brand).where('brands.name ILIKE ?', "%#{@query}%")
  end

  def filter_by_price_range(cars)
    cars = cars.where('price >= ?', @price_min) if @price_min
    cars = cars.where('price <= ?', @price_max) if @price_max
    cars
  end

  def sort_cars(cars)
    cars.sort_by do |car|
      [
        -label_priority(car),
        -(@rank_scores[car.id.to_s] || 0),
        car.price
      ]
    end
  end

  def label_priority(car)
    case LabelService.determine_label(car, @user)
    when 'perfect_match' then 2
    when 'good_match'   then 1
    else                     0
    end
  end

  def paginate(cars)
    start_index = (@page - 1) * PER_PAGE
    {
      cars: cars[start_index, PER_PAGE] || [],
      total_count: cars.size,
      page: @page
    }
  end
end 
