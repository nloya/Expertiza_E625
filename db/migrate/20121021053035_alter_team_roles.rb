class AlterTeamRoles < ActiveRecord::Migration
  def self.up
    add_column "team_roles", "role_questionnaire_id",:integer
  end

  def self.down
    remove_column "team_roles", "role_questionnaire_id",:integer
  end
end
