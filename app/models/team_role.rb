class TeamRole < ActiveRecord::Base

  has_many :team_role_assignments
  has_many :team_member_roles, :through => :team_role_assignment

  def self.find_roles()
    TeamRole.find_by_sql("SELECT id,role_names FROM team_roles");
  end

end
