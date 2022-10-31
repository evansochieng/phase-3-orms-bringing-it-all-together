class Dog
    #attributes macros
    attr_accessor :id, :name, :breed

    #initialize
    def initialize(name:, breed:, id: nil)
        @id = id
        @name = name
        @breed = breed
    end

    #.create_table
    def self.create_table
        #query to create table
        sql = <<-SQL
          CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
          );
        SQL
        #run querry
        DB[:conn].execute(sql)
    end

    #.drop_table
    def self.drop_table
        sql = <<-SQL
          DROP TABLE IF EXISTS dogs;
        SQL
        DB[:conn].execute(sql)
    end

    # #save - insert data into table
    # def save
    #     #query to insert data as row
    #     sql = <<-SQL
    #       INSERT INTO dogs (name, breed)
    #       VALUES (?, ?)
    #     SQL
    #     #execute
    #     DB[:conn].execute(sql, self.name, self.breed)

    #     #assign id attribute a value equal to the id value from the database
    #     self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]

    #     #return the instance
    #     self
    # end

    #.create
    def self.create(name:, breed:)
        dog = self.new(name: name, breed: breed)
        dog.save
    end

    #.new_from_db
    def self.new_from_db row
        #create an instance from the query results as arguments
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    #.all
    #return array of instances for all rows in the table
    def self.all
        #query to extract all rows
        sql = <<-SQL
          SELECT * FROM dogs;
        SQL

        #execute query => result is an array
        #loop over the array using #map, return an instance for every row
        DB[:conn].execute(sql).map do |row|
            self.new_from_db(row)
        end
    end

    #.find_by_name(name)
    def self.find_by_name name
        #query to extract only record whose name matches the name passed
        sql = <<-SQL
          SELECT * FROM dogs
          WHERE name = ?
          LIMIT 1;
        SQL

        #execute code and return instance for the query results above
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first #return the first element in the array
    end

    #.find(id)
    def self.find id
        #query to select rows that matches a certain id
        sql = <<-SQL
          SELECT * FROM dogs
          WHERE id = ?
        SQL

        #execute code and return that instance
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

    #Bonus deliverables
    #.find_or_create_by
    def self.find_or_create_by(name:, breed:)
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
      if !dog.empty?
        dog_data = dog[0]
        dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
      else
        dog = self.create(name: name, breed: breed)
      end
      dog
    end

    # def self.find_or_create_by(name:, breed:)
    #     #check if the there is a dog with the name and breed passed
    #     if self.find_by_name(name).breed == breed 
    #         self.find_by_name(name)
    #     else
    #         self.create(name: name, breed: breed)
    #     end
    # end

    #update method to update name
    def update
        #update statement
        sql = <<-SQL
         UPDATE dogs
         SET name = ?
        SQL

        #execute query
        DB[:conn].execute(sql, self.name) #set name of that row(instance) to the updated name
    end

    #Version 2 of save - Expand functionality
    # Insert data to the table if id doesn't exist, otherwise update the record
    def save
        if self.id == nil
            #query to insert data as row
            sql = <<-SQL
              INSERT INTO dogs (name, breed)
              VALUES (?, ?)
            SQL
            #execute
            DB[:conn].execute(sql, self.name, self.breed)

            #assign id attribute a value equal to the id value from the database
            self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]

            #return the instance
            self
        else
            self.update

            #return updated dog instance
            self
        end
    end
end
