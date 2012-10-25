class UpdateTeamRolesQuestionnaireId < ActiveRecord::Migration
  def self.up
    execute "update team_roles set role_questionnaire_id = (select id from questionnaires where name='Developer Rubric') where id = 1"
    execute "update team_roles set role_questionnaire_id = (select id from questionnaires where name='Tester Rubric') where id = 2"
    execute "update team_roles set role_questionnaire_id = (select id from questionnaires where name='Architect Rubric') where id = 3"
    execute "update team_roles set role_questionnaire_id = (select id from questionnaires where name='Designer Rubric') where id = 4"
  end

  def self.down
    execute "update team_roles set role_questionnaire_id = null where id = 1"
    execute "update team_roles set role_questionnaire_id = null where id = 2"
    execute "update team_roles set role_questionnaire_id = null where id = 3"
    execute "update team_roles set role_questionnaire_id = null where id = 4"
  end
end
