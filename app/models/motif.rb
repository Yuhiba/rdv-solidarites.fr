class Motif < ApplicationRecord
  belongs_to :organisation
  belongs_to :specialite
  has_many :rdvs, dependent: :restrict_with_exception
  has_and_belongs_to_many :plage_ouvertures

  validates :name, presence: true, uniqueness: { scope: :organisation }
  validates :color, :default_duration_in_min, :min_booking_delay, :max_booking_delay, presence: true
  validates :max_users_limit, numericality: { greater_than_or_equal_to: 1 }, allow_nil: true
  validates :min_booking_delay, numericality: { greater_than_or_equal_to: 30.minutes, less_than_or_equal_to: 1.year.minutes }
  validates :max_booking_delay, numericality: { greater_than_or_equal_to: 30.minutes, less_than_or_equal_to: 1.year.minutes }
  validate :booking_delay_validation

  scope :active, -> { where(deleted_at: nil) }

  def soft_delete
    rdvs.any? ? update_attribute(:deleted_at, Time.zone.now) : destroy
  end

  private

  def booking_delay_validation
    return if min_booking_delay.zero? && max_booking_delay.zero?

    errors.add(:max_booking_delay, "doit être supérieur au délai de réservation minimum") if max_booking_delay <= min_booking_delay
  end

  def name_with_badge
    label = name
    label = "#{label} <span class='badge badge-danger'>En ligne</span>" if online
    label = "#{label} <span class='badge badge-info'>À domicile</span>" if at_home
    label.html_safe
  end
end
