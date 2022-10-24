class MeigensController < ApplicationController
  def show_by_category
    @meigen = session[:meigen]
    @is_session_existed = true
    if @meigen.nil?
      @is_session_existed = false
    else
      @meigen = Meigen.find(@meigen["id"])
    end
    render 'meigens/show'
  end
end
