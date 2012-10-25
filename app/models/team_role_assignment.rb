class TeamRoleAssignment < ActiveRecord::Base

  has_many :assignments
  has_many :team_roles

end
