class TeamMemberRole < ActiveRecord::Base

   has_many :users
   belongs_to :team_role_assignment
   has_many :team_roles, :through => :team_role_assignments

end
