class VouchersController < ApplicationController
  before_filter :authenticate_user!
  # Currently the only use for this is to get vouchers associated with a given currency_id, which must be supplied
  before_filter :get_parent_currency, :only => [:index, :new]
  
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
    @voucher = @currency.vouchers.build    
  end

  # GET /vouchers/1/edit
  def edit
    @voucher = Voucher.find(params[:id])
  end

  # POST /vouchers?currency_id=
  def create
    #@currency = Currency.find_by_id(params[:voucher][:currency_id])
    @voucher = Voucher.new(params[:voucher])
        
    if @voucher.save
      redirect_to @voucher, notice: 'Voucher was successfully created.'
    else
      render 'new'
    end
  end

  # PUT /vouchers/1
  def update
    @voucher = Voucher.find(params[:id])

    if @voucher.update_attributes(params[:voucher])
      redirect_to @voucher, notice: 'Voucher was successfully updated.'
    else
      render 'edit'
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
  def get_parent_currency
    @currency = Currency.find_by_id(params[:currency_id])
    
    redirect_to root_path, :alert => 'Unknown parent currency' if @currency.nil?
  end 
end
