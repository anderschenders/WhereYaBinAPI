class BinsController < ApplicationController

  def index
    all_bins = Bin.all

    #organize all_bins into arrays of arrays with same locations together
    unique = true
    all_bins_arrays = all_bins.each_slice(1).to_a
    unique_locations_format = []

    all_bins_arrays.each do |bin|
      unique_locations_format.each do |b|
        if b[0].location == bin[0].location
          b << bin[0]
          unique = false
        end
      end
      if unique == true
        unique_locations_format << bin
      end
      unique = true
    end

    render status: :ok, json: unique_locations_format
  end

end
