class Capture < ActiveRecord::Base
  belongs_to :client

  scope :active,   -> {where(archived: false)}
  scope :archived, -> {where(archived: true)}

  validates :event, presence: true


  def self.complex_where(opts = {})
    opts[:details] ||= []
    # opts[:client_id] = opts[:client_id].id if opts[:client_id].is_a?(Client)

    query_in_progress = self.where(client_id: opts[:client_id])

    if opts[:event].present?
      query_in_progress = query_in_progress.where(event: opts[:event])
    end

    opts[:details].each do |key, value|
      query_in_progress = query_in_progress.where(
        "data @> hstore(:key, :value)", key: key, value: value
      )
    end

    query_in_progress
  end

end


# User.where("preferences @> hstore(:key, :value)",
#   key: "github", value: "fnando"
# )
