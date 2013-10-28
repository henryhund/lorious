class CreditsController < ActionController::Base
  
  def add_credit
    @credit = CreditTransaction.new params.require(:credits).permit!
    
    respond_to do |format|
      if @credit.save
        format.html { redirect_to root_url, notice: 'Credits added successfully.' }
        format.json { render json: @credit, status: :created, location: @credit }
      else
        format.html { render action: "new" }
        format.json { render json: @credit.errors, status: :unprocessable_entity }
      end
    end
  end
end
