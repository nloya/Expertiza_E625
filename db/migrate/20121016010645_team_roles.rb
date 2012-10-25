class TeamRoles < ActiveRecord::Migration
  def self.up
    create_table "team_roles", :force => true do |t|
      t.string "role_names"
      t.integer "creator_id"
      t.timestamps
    end
    execute "ALTER TABLE `team_roles`
             ADD CONSTRAINT `fk_team_roles_users`
             FOREIGN KEY (creator_id) references users(id)"

    add_index "team_roles", ["creator_id"], :name => "fk_team_roles_creator_id"
  end


  def self.down
    drop_table :team_roles
  end
end