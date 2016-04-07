class UserCourse < ActiveRecord::Base
  include PublicActivity::Model
  include InitUserSubject

  after_create :create_user_subjects_when_assign_new_user

  tracked only: [:destroy],
    owner: ->(controller, model) {controller.current_user},
    recipient: ->(controller, model) {model && model.course},
    params: {
      user: proc {|controller, model| model.user}
    }
  belongs_to :user
  belongs_to :course

  delegate :name, :description, :start_date, :end_date, :status, to: :course, prefix: true, allow_nil: true

  has_many :user_subjects, dependent: :destroy

  scope :actived, ->{where active: true}
  scope :course_progress, ->{joins(:course)
    .where("courses.status = ?", Course.statuses[:progress]).order :updated_at}
  scope :course_finished, ->{joins(:course)
    .where("courses.status = ?", Course.statuses[:finish])}

  private
  def create_user_subjects_when_assign_new_user
    create_user_subjects [self], course.course_subjects, course_id, false
  end
end
