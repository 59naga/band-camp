# Dependencies
bandcamp= require './bandcamp'
objectAssign= require 'object-assign'

# singleton & constructor
API= objectAssign bandcamp.summaries,bandcamp

module.exports= API
