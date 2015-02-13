class SingleCodeGeneratorsController < ApplicationController
  before_filter :authenticate_user!
  # Currently the only use for this is to get single_code_generators associated with a given currency_id, which must be supplied
  before_filter :get_parent_currency, :only => [:index]
  # get_parent_currency has to come before ensure_admin_or_owner
  before_filter :ensure_admin_or_owner
  
  # GET /single_code_generators?currency_id=
  def index
    @generators = @currency.nil? ? [] : @currency.single_code_generators
  end

  # GET /single_code_generators/1
  def show
    @generator = SingleCodeGenerator.find(params[:id])
  end

  # DELETE /single_code_generators/1
  def destroy
    @generator = SingleCodeGenerator.find(params[:id])
    currency_id = @generator.currency.id
    @generator.destroy

    redirect_to single_code_generators_path(:currency_id => currency_id)
  end 
private
  def generator_params
    params.require(:single_code_generator).permit(:value, :currency_id, :start_date, :end_date, :code)    
  end
  
  def get_parent_currency
    @currency = Currency.find_by_id(params[:currency_id])
    
    redirect_to root_path, :alert => 'Unknown parent currency' if @currency.nil?
  end  
  
  def ensure_admin_or_owner
    unless current_user.admin? or (@currency.user.id == current_user.id)
      redirect_to root_path, :alert => 'Must be an admin or currency owner'
    end
  end 
end
