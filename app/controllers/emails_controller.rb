class EmailsController < ApplicationController
  layout 'application'
  before_filter :login_required, :except => [:new,:create]
  before_filter :not_logged_in_required, :only => [:new, :create]


  # Checks once again that an id is included and makes sure that the email field isn't blank
  def update
    if params[:id].nil?
      flash[:notice] = "ID field cannot be blank."
      redirect_to dashboard_url
      return
    end
    if params[:email].blank?
      flash[:notice] = "Email field cannot be blank."
      redirect_to dashboard_url
      return
    end
    if !(params[:email] == params[:email_confirmation])
      flash[:notice] = "Email mismatch."
      redirect_to dashboard_url
      return
    end
    @user = User.find_by_login(params[:id]) if params[:id]
    raise if @user.nil?
    unless current_user == @user
      flash[:notice] = "You must be the owner of this account to change the email address."
      redirect_to dashboard_url
      return
    end
    return if @user unless params[:email]
    @user.email = params[:email]
    if @user.email_changed?
      flash[:notice] = @user.save ? "Email changed." : @user.errors.each{|attr, msg| '#{attr} - #{msg}' }
    else
      flash[:notice] = "New email address is the same as the old address."
    end
    redirect_to dashboard_url
  rescue => e
    logger.error(e)
    flash[:notice] = e
    redirect_to dashboard_url
  end

end
