class Api::V1::CapturesController < ApplicationController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  respond_to :json


  def show
    binding.pry
  end


  private
    def captures_params
      params.require(:capture).permit(:client_id, :event, :archived, data: {})
    end
end
