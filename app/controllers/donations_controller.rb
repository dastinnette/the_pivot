class DonationsController < ApplicationController
  before_action :confirm_current_user, only: [:create]

  def create
    @donation = Donation.new(donation_params)

    Rails.configuration.stripe = {
      :publishable_key => ENV['PUBLISHABLE_KEY'],
      :secret_key      => ENV['SECRET_KEY']
    }

    # Set your secret key: remember to change this to your live secret key in production
    # See your keys here https://dashboard.stripe.com/account/apikeys
    Stripe.api_key = Rails.application.secrets.SECRET_KEY

    # Get the credit card details submitted by the form
    token = @donation.stripe_token

    # Create the charge on Stripe's servers - this will charge the user's card
    begin
      charge = Stripe::Charge.create(
        :amount => @donation.amount * 100,
        :currency => "usd",
        :source => token
      )
    rescue Stripe::CardError => e
      flash[:danger] = "This card has been declined"
    end
    if @donation.save
      flash[:notice] = "Thank you for making this dream come true!"
      redirect_to user_cause_path(@donation.cause.user, @donation.cause)
    else
      @cause = Cause.find(params[:donation][:cause_id])
      flash.now[:danger] = "Invalid donation, please try again"
      redirect_to user_cause_path(@cause.user, @cause)
    end
  end

  private

  def donation_params
    params.require(:donation).permit(:amount, :user_id, :cause_id, :cause_name, :stripe_name)
  end

  def confirm_current_user
    unless current_user
      flash[:notice] = "Please create an account or login to donate"
      session[:attempted_donation] = URI(request.referrer).path
      redirect_to new_user_path
    end
  end
end
