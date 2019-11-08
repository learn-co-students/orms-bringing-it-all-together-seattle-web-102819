class Dog

    attr_accessor :name, :breed, :id
    def initialize (hash)
        hash.each do |k, v|
            self.send(("#{k}="), v)
        end
    end

    def save
        #saves/updates the instance into the DB if it already exists
        #creates a new row in the table for the instance if it does not
        #updates id
        if self.id
            self.update
        else
            sql =<<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(hash)
        dog = Dog.new(hash) #create new dog
        dog.save            #saves to DB

    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        self.new(id: id, name: name, breed: breed)
    end

    def self.find_by_id(id)  #finds and creates new instance
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
        SQL
        dog = self.new_from_db(DB[:conn].execute(sql, id)[0])
    end

    def self.find_or_create_by(hash)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new_from_db(dog_data)
        else
            dog = self.create(hash)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
        SQL
        dog = self.new_from_db(DB[:conn].execute(sql, name)[0])
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, name, breed, id)
        
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    

end