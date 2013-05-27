require "recall/version"
require "sinatra"
require "datamapper"

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")

class Note
	include DataMapper::Resource
	property :id, Serial # id field which will be an integer primary key and auto-incrementing
	property :content, Text :required => true
	property :complete, Boolean, :required => true, :default => false
	property :created_at, DateTime
	property :updated_at, DateTime
end

DataMapper.finalize.auto_upgrade! # autmomatically update the database to contain the tables and fields
                                  # we've set, and to do so again if we make any changes to the schema

get '/' do
	@notes = Note.all :order => :id.desc # Retreive all the notes from the database. Using an @ instance variable here
	                                     # so that it wil be accessable from within the view file 
	@title = 'All Notes'
	erb :home
end

