class InvitesController < ApplicationController

  authorize_resource

  def new
    
  end

  def create
    begin
      @invite = Invite.create! invites_params
    rescue Exception => e
      redirect_to root_url, notice: t('invites.create.failure')
    else
      redirect_to root_url, notice: t('invites.create.success')
    end
  end

  private

  def invites_params
    params.require(:invite).permit(:name, :email)
  end

end
