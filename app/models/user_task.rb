class UserTask < ActiveRecord::Base
  include PublicActivity::Model

  ATTRIBUTES_PARAMS = [
    :spent_time, :estimated_time, :redmine_task_id, :status, :progress,
      :user_id, :user_subject_id, :task_id
  ]

  tracked only: [:destroy],
    owner: ->(controller, model) {controller.current_user},
    recipient: ->(controller, model) {model.user_subject.course_subject}

  has_many :activities, as: :trackable, class_name: "PublicActivity::Activity",
    dependent: :destroy

  belongs_to :task
  belongs_to :user_subject
  belongs_to :user

  delegate :name, :avatar, :description, to: :task
  delegate :name, to: :user, prefix: true, allow_nil: true

  before_create :init_relation_user
  after_update :subject_progress

  def nil_master?
    task.task_master_id.nil?
  end

  def subject_in_progress?
    self.user_subject.progress?
  end

  private
  def init_relation_user
    self.user_id = self.user_subject.user_id
  end

  def subject_progress
    if self.status == Settings.tasks.statuses.closed
      total_time = self.user_subject.total_time_task_closed
      total_time += self.estimated_time.to_f
      self.user_subject.update_attributes(total_time_task_closed: total_time, progress: total_time * 100 /
        (self.user_subject.during_time * Settings.hours_working_day))
    end
  end
end
