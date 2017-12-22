# require "HTTParty"
# require "pry"

class BinWrapper
  BASE_URL= "http://gisrevprxy.seattle.gov/arcgis/rest/services/SDOT_EXT/ASSETS/MapServer/11/query?where=1%3D1&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&returnTrueCurves=false&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&resultOffset=&resultRecordCount=&queryByDistance=&returnExtentsOnly=false&datumTransformation=&parameterValues=&rangeValues=&f=pjson"

  def self.search

    # puts "@@@@@@@@@@@@@@@@@@@@"
    # puts "Getting all bin data"

    response = HTTParty.get(BASE_URL)

    if response["features"] == 0
      # puts "@@@@@@@@@@@@@@@@@@"
      # puts "in if conditional"
      # puts "response features:"
      # puts response["features"]
      return []
    else
      # puts "@@@@@@@@@@@@@@@@@"
      # puts "in else conditional:"
      bins = response["features"].map do |feature|
        self.construct_bin(result)
      end
      # puts "all new bins:"
      # puts bins
      return bins
    end
  end

  private

  def self.construct_bin(api_result)
    Bin.new(
      bin_type: api_result["attributes"]["UNITDESC"],
      latitude: api_result["attributes"]["SHAPE_LAT"],
      longitude: api_result["attributes"]["SHAPE_LNG"]
    )
  end

end
