require_relative '../helpers/encrypt_decrypt_helper'

class UserMailer < ApplicationMailer
  default from: ENV['EMAIL_USERNAME']

  def confirm_event_registration
    @user = params[:user]
    @event = params[:event]
    @event_type = params[:event_type]
    mail(to: @user.email, subject: 'Confirm Event Registration')
  end

  def new_user_administrator_alert(user)
    @users = User.where(admin: true)
    emails = @users.collect(&:email).join(', ')

    return if emails.length <= 0

    @latest_user = user
    @uin = EncryptDecryptHelper.decrypt(@latest_user.uin)

    mail(to: emails, subject: 'New Member Registration')
  end
end
