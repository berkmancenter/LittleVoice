class StylesheetsController < ApplicationController

  caches_page :buttons

  def buttons

    @color_array = ["grey","blue","orange"]

    @color_hash = {
    "light_grey" => "#DBDBDB",
    "dark_grey" => "#7C7C7C",
    "light_orange" => "#FFE6D5",
    "dark_orange" => "#DC5E1B",
    "light_blue" => "#D3E6EA",
    "dark_blue" => "#2382a1"
    }

    @button_size_array = [75, 100, 125, 150, 200]

    respond_to do |format|
      format.css do
        render :layout => false
      end
    end
  end


end
