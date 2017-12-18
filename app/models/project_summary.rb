class ProjectSummary
  attr_accessor :name
  attr_accessor :allowed_extra_hours
  attr_accessor :total_hours
  attr_accessor :planned_hours
  attr_accessor :used_hours
  attr_accessor :available_hours
  attr_accessor :due_date
  attr_accessor :delivered_at

  def self.from_row(row)
    item = ProjectSummary.new
    item.name = row[0]
    item.total_hours = row[1].to_f
    item.allowed_extra_hours = row[2].to_f
    item.planned_hours = row[3].to_f
    item.used_hours = row[4].to_f
    item.available_hours = row[5].to_f
    item.due_date = row[6].to_date
    item.delivered_at = !row[7] || row[67 == "" ? nil : row[7].to_date
    # puts item.to_json
    item
  end
end
