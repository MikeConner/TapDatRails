class VouchersController < ApplicationController
  before_filter :authenticate_user!
  # Currently the only use for this is to get vouchers associated with a given currency_id, which must be supplied
  before_filter :get_parent_currency, :only => [:index, :new]
  # get_parent_currency has to come before ensure_admin_or_owner
  before_filter :ensure_admin_or_owner
  
  # GET /vouchers?currency_id=
  def index
    @vouchers = @currency.nil? ? [] : @currency.vouchers
  end

  # GET /vouchers/1
  def show
    @voucher = Voucher.find(params[:id])
  end

  # GET /vouchers/new?currency_id=
  def new
    @voucher = @currency.vouchers.build(:uid => SecureRandom.hex(4))  
  end

  # POST /vouchers?currency_id=
  def create
    @voucher = Voucher.new(voucher_params)
    @currency = @voucher.currency
    
    if params[:voucher][:amount].to_i > @currency.reserve_balance
      # Should not happen, because UI has the max set
      redirect_to vouchers_path(:currency_id => @currency.id), :alert => 'Insufficient balance' and return
    end 
    
    if @voucher.save
      # Deduct from currency's reserve balance
      @currency.update_attribute(:reserve_balance, @currency.reserve_balance - @voucher.amount)
       
      redirect_to @voucher, notice: 'Voucher was successfully created.'
    else
      render 'new'
    end
  end

  # DELETE /vouchers/1
  def destroy
    @voucher = Voucher.find(params[:id])
    currency_id = @voucher.currency.id
    @voucher.destroy

    redirect_to vouchers_path(:currency_id => currency_id)
  end 
  
private
  def voucher_params
    params.require(:voucher).permit(:amount, :currency_id, :user_id, :uid, :status)    
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
