module Distance
  def distance_between_two_points(lat1, lon1, lat2, lon2)

    radlat1 = Math::PI * (lat1 / 180)
    radlat2 = Math::PI * (lat2 / 180)
    theta = lon1 - lon2
    radtheta = Math::PI * (theta / 180)
    dist = Math.sin(radlat1) * Math.sin(radlat2) + Math.cos(radlat1) * Math.cos(radlat2) * Math.cos(radtheta)
    dist = Math.acos(dist)
    dist = dist * (180 / Math::PI)
    dist = dist * 60 * 1.1515
    # if (unit=="K") { dist = dist * 1.609344 }
    # if (unit=="N") { dist = dist * 0.8684 }
    return dist
  end
end
