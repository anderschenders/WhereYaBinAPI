################### USER SEEDS #####################
puts "@@@@@@@@@@@@ Creating users @@@@@@@@@@@@@@@"
users = User.create!([{ username: 'ac', email: 'A@c.com', password: '123' }, { username: 'ace', email: 'A@ce.com', password: '456' }])
puts "Successfully created users!"

################# BIN JSON FILE #####################
require 'json'

puts "@@@@@@@@@@@ Creating bins @@@@@@@@@@@@@@@"

BIN_FILE = Rails.root.join('db', 'seed_data', 'citybindata.json')
puts "Loading raw bin data from #{BIN_FILE}"

file = File.read(BIN_FILE)
parsed_file = JSON.parse(file)

bin_failures = []

if parsed_file["features"] == 0
  puts "SEEDING FAILED, no results"
else
  parsed_file["features"].map do |feature|
    bin = Bin.new({
      bin_type: feature["attributes"]["PC_SVC_TYPE"],
      latitude: feature["attributes"]["PC_LAT_COORD"],
      longitude: feature["attributes"]["PC_LONG_COORD"]
    })
    successful = bin.save
    if !successful
      bin_failures << bin
    end
  end

  puts "Successfully created bins!!"
end

################## USER_BIN SEEDS ##################
# puts "@@@@@@@@@@@ Creating user-bins @@@@@@@@@@@@@@@"
# user_bins = UserBin.create!([{ user_id: 1, bin_id: 1 }, { user_id: 1, bin_id: 2 }])
# puts "Successfully created user-bins!"




############ CALLING CITY PAYSTATION API  ###########
# require 'open-uri' # Needed to open web urls

################### BIN SEEDS #####################
# Bin.delete_all
#
# URL = "http://gisrevprxy.seattle.gov/arcgis/rest/services/SDOT_EXT/ASSETS/MapServer/11/query?where=1%3D1&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&returnTrueCurves=false&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&resultOffset=&resultRecordCount=&queryByDistance=&returnExtentsOnly=false&datumTransformation=&parameterValues=&rangeValues=&f=pjson"
#
# puts "@@@@@@@@@@@@@ about to call URL @@@@@@@@@@@@@@@"
# response = HTTParty.get(URL)
# parsed_response = JSON.parse(response)
#
# if parsed_response["features"] == 0
#   puts "SEEDING FAILED, no results"
# else
#   bins = parsed_response["features"].map do |feature|
#     bin = Bin.create!({
#       bin_type: feature["attributes"]["UNITDESC"],
#       latitude: feature["attributes"]["SHAPE_LAT"],
#       longitude: feature["attributes"]["SHAPE_LNG"]
#       })
#   end
#   puts "SEEDING SUCCESSFUL?"
# end
