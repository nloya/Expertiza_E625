class UpdateRolesTablesParentId < ActiveRecord::Migration
  def self.up
    execute "insert into roles values(7,'Manager',8,'The instructor, manager, or some other superior.',null,null,'2012-10-24 18:35:00','2012-10-24 18:35:00')"
    execute "insert into roles values(8,'Reader',1,'In various Expertiza projects, e.g., wiki textbooks, students work is presented to other students to read or use in some other way. These other students are Readers.',null,null,'2012-10-24 18:35:00','2012-10-24 18:35:00')"
    execute "update roles set parent_id = 7 where id = 6"
  end

  def self.down
    execute "delete from roles where id = 7"
    execute "delete from roles where id = 8"
    execute "update roles set parent_id = 1 where id = 6"
  end
end
