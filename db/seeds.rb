# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#/db/seeds.rb
require 'open-uri' # Needed to open web urls

################### BIN SEEDS #####################
Bin.delete_all

URL = "http://gisrevprxy.seattle.gov/arcgis/rest/services/SDOT_EXT/ASSETS/MapServer/11/query?where=1%3D1&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&returnTrueCurves=false&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&resultOffset=&resultRecordCount=&queryByDistance=&returnExtentsOnly=false&datumTransformation=&parameterValues=&rangeValues=&f=pjson"

puts "@@@@@@@@@@@@@ about to call URL @@@@@@@@@@@@@@@"
response = HTTParty.get(URL)
parsed_response = JSON.parse(response)

if parsed_response["features"] == 0
  puts "SEEDING FAILED, no results"
else
  bins = parsed_response["features"].map do |feature|
    bin = Bin.create!({
      bin_type: feature["attributes"]["UNITDESC"],
      latitude: feature["attributes"]["SHAPE_LAT"],
      longitude: feature["attributes"]["SHAPE_LNG"]
      })
  end
  puts "SEEDING SUCCESSFUL?"
end

################### USER SEEDS #####################
puts "@@@@@@@@@@@@ Creating users @@@@@@@@@@@@@@@"
users = User.create!([{ username: 'ac', email: 'a@c.com', password: '123' }, { username: 'ace', email: 'a@ce.com', password: '456' }])
puts "Successfully created users?"
