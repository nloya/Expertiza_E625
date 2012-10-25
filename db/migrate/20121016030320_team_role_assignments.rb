class TeamRoleAssignments < ActiveRecord::Migration
  def self.up

    create_table "team_role_assignments", :force => true do |t|
      t.integer "role_id"
      t.integer "assignment_id"
      t.timestamps
    end
    execute "ALTER TABLE `team_role_assignments`
             ADD CONSTRAINT `fk_tra_role_id`
             FOREIGN KEY (role_id) references team_roles(id)"

    execute "ALTER TABLE `team_role_assignments`
             ADD CONSTRAINT `fk_tra_assignment_id`
             FOREIGN KEY (assignment_id) references assignments(id)"

    add_index "team_role_assignments", ["role_id"], :name => "idx_tra_role_id"
    add_index "team_role_assignments", ["assignment_id"], :name => "idx_tra_assignment_id"

  end

  def self.down
    drop_table :team_role_assignments
  end
end
