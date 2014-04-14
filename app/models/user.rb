class User < ActiveRecord::Base

  devise :database_authenticatable,
         :confirmable,
         :lockable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable,

         authentication_keys: [:login]

  has_many :enrollments, dependent: :destroy, foreign_key: :student_id
  has_many :work_groups, through: :enrollments

  has_many :task_assignments, dependent: :destroy
  has_many :tasks, through: :task_assignments

  validates :login, format: { with: /\A[A-Za-z0-9]+\z/ }, presence: true, uniqueness: { case_sensitive: false }
  validates :nick,  format: { with: /\A[A-Za-z0-9]+\z/ }, presence: true, uniqueness: { case_sensitive: false }

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/ }, presence: true, uniqueness: { case_sensitive: false }

  validates :first, format: { with: /\A\p{Lu}\p{Ll}*\z/u }, allow_blank: true
  validates :last,  format: { with: /\A\p{Lu}\p{Ll}*\z/u }, allow_blank: true

  def login=(value)
    write_attribute :login, value.to_s.downcase

    self.nick ||= login
  end

  def name
    (value = "#{first} #{last}".squeeze(' ').strip).blank? ? nil : value
  end

  def self.create_without_confirmation!(attributes)
    user = User.new(attributes)

    user.skip_confirmation!
    user.save!
    user
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    login      = conditions.delete(:login)

    return where(conditions).first unless login

    where(conditions).where(["login = :value OR email = :value", { value: login.downcase }]).first
  end
end
