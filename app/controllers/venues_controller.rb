class VenuesController < ApplicationController
  def new
    @venue = Venue.new
  end
  
  def create
    @venue = Venue.new(venue_params)
    @venue.name = URI.encode(params[:name] || "")
    
    unless Venue.find_by_name(@venue.name).nil?
      @venue.errors.add :base, "Venue name already taken"
      render 'new' and return
    end
    
    if params[:admin_first_name].blank? or params[:admin_last_name].blank? or params[:admin_email].blank?
      @venue.errors.add :base, 'Missing administrator name'
      render 'new' and return
    end
    
    unless User.find_by_email(params[:admin_email]).nil?
      @venue.errors.add :base, 'Email already in use'
      render 'new' and return      
    end
    
    if params[:currency].blank? or (params[:currency].length > 24)
      @venue.errors.add :base, 'Currency name too long'
      render 'new' and return
    end
    
    unless Currency.find_by_name(params[:currency]).nil?
      @venue.errors.add :base, 'Currency name already taken'
      render 'new' and return      
    end
    
    ActiveRecord::Base.transaction do
      # Create a currency and a user, then store the venue
      password = SecureRandom.hex(32)
      user = User.create!(:email => params[:admin_email],
                          :password => password,
                          :password_confirmation => password,
                          :name => "#{params[:admin_first_name]} #{params[:admin_last_name]}",
                          :phone_secret_key => SecureRandom.hex(8),
                          :role => User::MANAGER_ROLE)
      user.currencies.create!(:name => params[:currency], :expiration_days => 180)
      user.create_venue!(venue_params)   
      
      redirect_to venue_path(Venue.last), :notice => 'New Venue created successfully' and return
    end
    
    render 'new'  
  end
  
  def show
    @venue = Venue.find(params[:id])
  end

  def edit
    @venue = Venue.find(params[:id])
    @activities = ActivityType.all
  end
  
  def update
    
  end
  
private
  def venue_params
    params.require(:venue).permit(:name, :address_1, :address_2, :city, :state, :zipcode, :website, :facebook, :twitter)
  end
end
