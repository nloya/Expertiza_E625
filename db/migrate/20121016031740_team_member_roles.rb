class TeamMemberRoles < ActiveRecord::Migration
  def self.up
    create_table "team_member_roles", :force => true do |t|
      t.integer "assignment_role_id"
      t.integer "user_id"
      t.timestamps
    end
    execute "ALTER TABLE `team_member_roles`
             ADD CONSTRAINT `fk_tmr_assignment_role_id`
             FOREIGN KEY (assignment_role_id) references team_role_assignments(id)"

    execute "ALTER TABLE `team_member_roles`
             ADD CONSTRAINT `fk_tmr_user_id`
             FOREIGN KEY (user_id) references users(id)"

    add_index "team_member_roles", ["assignment_role_id"], :name => "idx_tmr_assignment_role_id"
    add_index "team_member_roles", ["user_id"], :name => "idx_tmr_user_id"
  end

  def self.down
    drop_table :team_member_roles
  end
end
