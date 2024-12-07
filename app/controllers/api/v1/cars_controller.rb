module Api
  module V1
    class CarsController < ApplicationController
      def index
        result = CarQueryService.new(
          user_id: params.require(:user_id),
          query: params[:query],
          price_min: params[:price_min],
          price_max: params[:price_max],
          page: params[:page]
        ).call

        render json: {
          cars: result[:cars].map { |car| car_response(car) },
          total_count: result[:total_count],
          page: result[:page]
        }
      end

      private

      def car_response(car)
        {
          id: car.id,
          brand: car.brand.name,
          model: car.model,
          price: car.price,
          label: LabelService.determine_label(car, User.find(params[:user_id]))
        }
      end
    end
  end
end 
