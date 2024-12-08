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

        render json: result
      end
    end
  end
end
