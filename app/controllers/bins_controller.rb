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

    # organize all_bins to an arrays of hashes => {garbage: bin_object}
    all_bins_formatted = []

    unique_locations_format.each do |arr|
      hash = {}
      arr.each do |bin|
        puts bin
        hash[bin.bin_type] = bin
        puts hash
      end
      all_bins_formatted << hash
    end

    render status: :ok, json: all_bins_formatted

  end

  def create
    all_bins = Bin.all
    new_location = all_bins.last.location + 1
    @user = User.find_by(id: params[:user_id])

    if params[:bin_type] == "BOTH"
      # create two new bins
      new_garb_bin = Bin.new(
        bin_type: "GPUBL",
        latitude: params[:latitude],
        longitude: params[:longitude],
        created_by: @user,
        location: new_location
      )

      new_rec_bin = Bin.new(
        bin_type: "RYPUBL",
        latitude: params[:latitude],
        longitude: params[:longitude],
        created_by: @user,
        location: new_location
      )

      if (new_rec_bin.save && new_garb_bin.save)

        new_user_bin = UserBin.new(
          user_id: params[:user_id],
          bin_id: new_rec_bin.id,
          action: 'add',
          user_lat: params[:latitude],
          user_lng: params[:longitude]
        )

        new_user_bin2 = UserBin.new(
          user_id: params[:user_id],
          bin_id: new_garb_bin.id,
          action: 'add',
          user_lat: params[:latitude],
          user_lng: params[:longitude]
        )

        if (new_user_bin.save && new_user_bin2.save)
          # get total distance user has travelled
          @user.reload
          total_distance_travelled = @user.total_distance_travelled

          #get all user_bins
          user_bins_array = get_user_bins(@user)

          json_response = {
            new_user_bin: [new_user_bin, new_user_bin2],
            updated_user: @user,
            total_dist: total_distance_travelled,
            user_bins: user_bins_array
          }

          render status: :ok, json: json_response
        else
          render status: :bad_request, json: { errors: [new_user_bin.errors, new_user_bin2.errors] }
        end
      else
        render status: :bad_request, json: { errors: [new_garb_bin.errors, new_rec_bin.errors] }
      end

    else
      # create one new bin
      new_bin = Bin.new(
        bin_type: params[:bin_type],
        latitude: params[:latitude],
        longitude: params[:longitude],
        created_by: @user,
        location: new_location
      )

      if new_bin.save

        new_user_bin = UserBin.new(
          user_id: params[:user_id],
          bin_id: new_bin.id,
          action: 'add',
          user_lat: params[:latitude],
          user_lng: params[:longitude]
        )

        if new_user_bin.save
          # get total distance user has travelled
          @user.reload
          total_distance_travelled = @user.total_distance_travelled

          #get all user_bins
          user_bins_array = get_user_bins(@user)

          json_response = {
            new_user_bin: new_user_bin,
            updated_user: @user,
            total_dist: total_distance_travelled,
            user_bins: user_bins_array
          }

          render status: :ok, json: json_response
        else
          render status: :bad_request, json: { errors: new_user_bin.errors }
        end

      else
        render status: :bad_request, json: { errors: new_bin.errors }
      end
    end
  end

  private

  def get_user_bins(user)
    user_bins = UserBin.where(user_id: @user.id)
    user_bins_sorted = user_bins.order(:created_at).reverse

    user_bins_array = user_bins_sorted.each_slice(1).to_a

    user_bins_array.each do |user_bin|
      bin = Bin.find_by(id: user_bin[0].bin_id)
      if bin.bin_type === "RYPUBL"
        user_bin << { "bin_type" => "RECYCLING" }
      else
        user_bin << { "bin_type" => "GARBAGE" }
      end
    end

    return user_bins_array
  end
end
