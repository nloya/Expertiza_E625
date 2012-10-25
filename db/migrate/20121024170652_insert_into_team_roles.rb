class InsertIntoTeamRoles < ActiveRecord::Migration
  def self.up
    timestamp = Time.now
    execute "insert into team_roles values(1,'Developer',2,'2012-10-24 14:18:00','2012-10-24 14:18:00',null)"
    execute "insert into team_roles values(2,'Tester',2,'2012-10-24 14:18:00','2012-10-24 14:18:00',null)"
    execute "insert into team_roles values(3,'Architect',2,'2012-10-24 14:18:00','2012-10-24 14:18:00',null)"
    execute "insert into team_roles values(4,'Designer',2,'2012-10-24 14:18:00','2012-10-24 14:18:00',null)"
  end

  def self.down
    execute "delete from team_roles where id = 1"
    execute "delete from team_roles where id = 2"
    execute "delete from team_roles where id = 3"
    execute "delete from team_roles where id = 4"
  end
end
