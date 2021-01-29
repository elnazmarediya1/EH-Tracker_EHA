require 'csv'
require_relative '../helpers/encrypt_decrypt_helper'

class User < ApplicationRecord
  has_many :user_events, dependent: :destroy
  has_many :events, through: :user_events, dependent: :destroy

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :uin, presence: true, length: { is: 9 }, numericality: { only_integer: true }
  validates :email, presence: true
  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :volunteer_hours, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :uniqueness_of_uin, on: :create

  before_save :encrypt_uin
  after_find  :decrypt_uin

  def uniqueness_of_uin
    new_uin = uin
    encrypted_uins = []

    User.all.each do |user|
      encrypted_uins.append(user.uin)
    end

    encrypted_uins.each do |uin|
      errors.add(:uin, 'has already been taken') if uin == new_uin
    end
  end

  def after_confirmation
    UserMailer.new_user_administrator_alert(self).deliver_now
  end

  def encrypt_uin
    self.uin = EncryptDecryptHelper.encrypt(uin)
  end

  def decrypt_uin
    self.uin = EncryptDecryptHelper.decrypt(uin)
  end

  # source: https://gorails.com/episodes/export-to-csv
  def self.to_csv
    columns = %w[uin email admin superadmin first_name last_name points volunteer_hours]

    CSV.generate(headers: true) do |csv|
      csv << columns

      find_each do |user|
        row_to_write = columns.map { |column| user.send(column) }
        csv << row_to_write
      end
    end
  end
end
