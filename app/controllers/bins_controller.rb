require 'distance'

class BinsController < ApplicationController

  include Distance

  def index

    all_bins = Bin.all

    user_lat = params[:user_lat].to_f
    user_lng = params[:user_lng].to_f

    # only send back bins within certain distance from user
    filtered_bins = all_bins.select { |bin| distance_between_two_points(user_lat, user_lng, bin.latitude, bin.longitude) < 0.5 }

    #organize all_bins into arrays of arrays with same locations together
    unique = true
    all_bins_arrays = filtered_bins.each_slice(1).to_a
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
    @user = User.find_by(id: params[:user_id])
    new_location = all_bins.last.location + 1

    # check that there isn't a bin of this type already at this location
    new_lat = params[:latitude].to_f
    new_lng = params[:longitude].to_f
    bin_type = params[:bin_type]

    rec_already_there = false
    rec_already_there_lat = nil
    rec_already_there_lng = nil
    rec_already_there_loc = nil

    gar_already_there = false
    gar_already_there_lat = nil
    gar_already_there_lng = nil
    gar_already_there_loc = nil

    if bin_type != "BOTH" #bin_type = GPUBL or RYPUBL

      all_bins.each do |bin|
        # TODO: why doesn't the below work?
        # dist_btwn_bins = Distance::distance_between_two_points(new_lat, new_lng, bin.latitude, bin.longitude)
        dist_btwn_bins = distance_between_two_points(new_lat, new_lng, bin.latitude, bin.longitude)

        if (bin.bin_type == bin_type) && (dist_btwn_bins < 0.003)
          render status: :bad_request, json: { errors: "There is already that type of bin there!" }
          return
        end
      end

    else
      #bin_type = "BOTH"
      all_bins.each do |bin|
        # TODO: why doesn't the below work?
        # dist_btwn_bins = Distance::distance_between_two_points(new_lat, new_lng, bin.latitude, bin.longitude)
        dist_btwn_bins = distance_between_two_points(new_lat, new_lng, bin.latitude, bin.longitude)

        if (bin.bin_type == "RYPUBL") && (dist_btwn_bins < 0.003)
          rec_already_there = true
          rec_already_there_lat = bin.latitude
          rec_already_there_lng = bin.longitude
          rec_already_there_loc = bin.location
        elsif (bin.bin_type == "GPUBL") && (dist_btwn_bins < 0.003)
          gar_already_there = true
          gar_already_there_lat = bin.latitude
          gar_already_there_lng = bin.longitude
          gar_already_there_loc = bin.location
        end
      end

      user_message = nil

      if rec_already_there && gar_already_there
        render status: :bad_request, json: { errors: "There are already garbage and recycling bins there!" }
        return
      elsif rec_already_there && !(gar_already_there)
        user_message = "There is already a recycling bin here, but not a garbage bin, so we've added that!"
        # only create new garbage bin

        if (new_lat == rec_already_there_lat) && (new_lng == rec_already_there_lng)
        # give same location id as recycling bin

          new_garb_bin = Bin.new(
          bin_type: "GPUBL",
          latitude: new_lat,
          longitude: new_lng,
          created_by: @user,
          location: rec_already_there_loc
        )

        else
          # give new location id
          new_garb_bin = Bin.new(
            bin_type: "GPUBL",
            latitude: new_lat,
            longitude: new_lng,
            created_by: @user,
            location: new_location
          )
        end

        if new_garb_bin.save

          new_user_bin = UserBin.new(
            user_id: params[:user_id],
            bin_id: new_garb_bin.id,
            action: 'add',
            user_lat: new_lat,
            user_lng: new_lng
          )

          if new_user_bin.save
            # get total distance user has travelled
            @user.reload
            @user.bin_count += 1
            @user.save

            total_distance_travelled = @user.total_distance_travelled

            #get all user_bins
            user_bins_formatted = get_user_bins(@user)

            # user total
            user_bins_use = user_bins_formatted.select { |user_bin| user_bin["action"] == "use" }

            user_bins_use_total = user_bins_use.count

            # recycling total
            user_bins_rec = user_bins_use.select { |user_bin|
              user_bin["bin_type"] == "RYPUBL" }

            user_bins_total_rec = user_bins_rec.count

            # garbage total
            user_bins_gar = user_bins_use.select { |user_bin|
              user_bin["bin_type"] == "GPUBL" }

            user_bins_total_gar = user_bins_gar.count

            # report total
            user_bins_reports = user_bins_formatted.select { |user_bin| user_bin["action"] == "full" || user_bin["action"] == "missing" || user_bin["action"] == "add" }

            user_bins_total_reports = user_bins_reports.count

            # full total
            user_bins_full = user_bins_reports.select { |user_bin| user_bin["action"] == "full"}

            user_bins_full_reports = user_bins_full.count

            # missing total
            user_bins_missing = user_bins_reports.select { |user_bin| user_bin["action"] == "missing" }

            user_bins_missing_reports = user_bins_missing.count

            # add total
            user_bins_add = user_bins_reports.select { |user_bin| user_bin["action"] == "add" }

            user_bins_add_reports = user_bins_add.count

            json_response = {
              new_user_bin: new_garb_bin,
              user: @user,
              total_dist: total_distance_travelled,
              user_message: user_message,
              user_bins: user_bins_formatted,
              use_total: user_bins_use_total,
              total_rec: user_bins_total_rec,
              total_gar: user_bins_total_gar,
              total_reports: user_bins_total_reports,
              full_reports: user_bins_full_reports,
              missing_reports: user_bins_missing_reports,
              add_reports: user_bins_add_reports
            }

            render status: :ok, json: json_response
            return
          else
            render status: :bad_request, json: { errors: new_user_bin.errors }
            return
          end
        else
          render status: :bad_request, json: { errors: new_garb_bin.errors }
          return
        end

      elsif gar_already_there && !(rec_already_there)
        user_message = "There is already a garbage bin here, but not a recycling bin, so we've added that!"

        # only create new recycling bin
        if ((new_lat == gar_already_there_lat) && (new_lng == gar_already_there_lng))
          # give same location id as garbage bin already there
          new_rec_bin = Bin.new(
            bin_type: "RYPUBL",
            latitude: new_lat,
            longitude: new_lng,
            created_by: @user,
            location: gar_already_there_loc
          )

        else
          # give new location id
          new_rec_bin = Bin.new(
            bin_type: "RYPUBL",
            latitude: new_lat,
            longitude: new_lng,
            created_by: @user,
            location: new_location
          )
        end

        if new_rec_bin.save

          # create new userbin resource
          new_user_bin = UserBin.new(
            user_id: params[:user_id],
            bin_id: new_rec_bin.id,
            action: 'add',
            user_lat: new_lat,
            user_lng: new_lng
          )

          if new_user_bin.save
            # get total distance user has travelled
            @user.reload
            @user.bin_count += 1
            @user.save

            total_distance_travelled = @user.total_distance_travelled

            #get all user_bins
            user_bins_formatted = get_user_bins(@user)

            # user total
            user_bins_use = user_bins_formatted.select { |user_bin| user_bin["action"] == "use" }

            user_bins_use_total = user_bins_use.count

            # recycling total
            user_bins_rec = user_bins_use.select { |user_bin|
              user_bin["bin_type"] == "RYPUBL" }

            user_bins_total_rec = user_bins_rec.count

            # garbage total
            user_bins_gar = user_bins_use.select { |user_bin|
              user_bin["bin_type"] == "GPUBL" }

            user_bins_total_gar = user_bins_gar.count

            # report total
            user_bins_reports = user_bins_formatted.select { |user_bin| user_bin["action"] == "full" || user_bin["action"] == "missing" || user_bin["action"] == "add" }

            user_bins_total_reports = user_bins_reports.count

            # full total
            user_bins_full = user_bins_reports.select { |user_bin| user_bin["action"] == "full"}

            user_bins_full_reports = user_bins_full.count

            # missing total
            user_bins_missing = user_bins_reports.select { |user_bin| user_bin["action"] == "missing" }

            user_bins_missing_reports = user_bins_missing.count

            # add total
            user_bins_add = user_bins_reports.select { |user_bin| user_bin["action"] == "add" }

            user_bins_add_reports = user_bins_add.count

            json_response = {
              new_user_bin: new_user_bin,
              user: @user,
              total_dist: total_distance_travelled,
              user_message: user_message,
              user_bins: user_bins_formatted,
              use_total: user_bins_use_total,
              total_rec: user_bins_total_rec,
              total_gar: user_bins_total_gar,
              total_reports: user_bins_total_reports,
              full_reports: user_bins_full_reports,
              missing_reports: user_bins_missing_reports,
              add_reports: user_bins_add_reports
            }

            render status: :ok, json: json_response
            return
          else
            render status: :bad_request, json: { errors: new_user_bin.errors }
            return
          end
        else
          render status: :bad_request, json: { errors: new_rec_bin.errors }
        end

      end
    end

    # new_location = all_bins.last.location + 1
    # @user = User.find_by(id: params[:user_id])

    if params[:bin_type] == "BOTH" && !(rec_already_there) && !(gar_already_there)
      # create two new bins
      new_garb_bin = Bin.new(
        bin_type: "GPUBL",
        latitude: new_lat,
        longitude: new_lng,
        created_by: @user,
        location: new_location
      )

      new_rec_bin = Bin.new(
        bin_type: "RYPUBL",
        latitude: new_lat,
        longitude: new_lng,
        created_by: @user,
        location: new_location
      )

      if (new_rec_bin.save && new_garb_bin.save)

        new_user_bin = UserBin.new(
          user_id: params[:user_id],
          bin_id: new_rec_bin.id,
          action: 'add',
          user_lat: new_lat,
          user_lng: new_lng
        )

        new_user_bin2 = UserBin.new(
          user_id: params[:user_id],
          bin_id: new_garb_bin.id,
          action: 'add',
          user_lat: new_lat,
          user_lng: new_lng
        )

        if (new_user_bin.save && new_user_bin2.save)
          # get total distance user has travelled
          @user.reload
          @user.bin_count += 2
          @user.save

          total_distance_travelled = @user.total_distance_travelled

          #get all user_bins
          user_bins_formatted = get_user_bins(@user)

          # user total
          user_bins_use = user_bins_formatted.select { |user_bin| user_bin["action"] == "use" }

          user_bins_use_total = user_bins_use.count

          # recycling total
          user_bins_rec = user_bins_use.select { |user_bin|
            user_bin["bin_type"] == "RYPUBL" }

          user_bins_total_rec = user_bins_rec.count

          # garbage total
          user_bins_gar = user_bins_use.select { |user_bin|
            user_bin["bin_type"] == "GPUBL" }

          user_bins_total_gar = user_bins_gar.count

          # report total
          user_bins_reports = user_bins_formatted.select { |user_bin| user_bin["action"] == "full" || user_bin["action"] == "missing" || user_bin["action"] == "add" }

          user_bins_total_reports = user_bins_reports.count

          # full total
          user_bins_full = user_bins_reports.select { |user_bin| user_bin["action"] == "full"}

          user_bins_full_reports = user_bins_full.count

          # missing total
          user_bins_missing = user_bins_reports.select { |user_bin| user_bin["action"] == "missing" }

          user_bins_missing_reports = user_bins_missing.count

          # add total
          user_bins_add = user_bins_reports.select { |user_bin| user_bin["action"] == "add" }

          user_bins_add_reports = user_bins_add.count

          json_response = {
            new_user_bin: [new_user_bin, new_user_bin2],
            user: @user,
            total_dist: total_distance_travelled,
            user_message: user_message,
            user_bins: user_bins_formatted,
            use_total: user_bins_use_total,
            total_rec: user_bins_total_rec,
            total_gar: user_bins_total_gar,
            total_reports: user_bins_total_reports,
            full_reports: user_bins_full_reports,
            missing_reports: user_bins_missing_reports,
            add_reports: user_bins_add_reports
          }

          render status: :ok, json: json_response
          return
        else
          render status: :bad_request, json: { errors: [new_user_bin.errors, new_user_bin2.errors] }
          return
        end
      else
        render status: :bad_request, json: { errors: [new_garb_bin.errors, new_rec_bin.errors] }
        return
      end


    # elsif params[:bin_type] == "BOTH" && rec_already_there
    #   # only create new garbage bin
    #
    #   # if lat+lng is exactly the same, give same location id
    #   if (new_lat == rec_already_there_lat) && (params[:longitude] == rec_already_there_lng)
    #
    #     new_garb_bin = Bin.new(
    #     bin_type: "GPUBL",
    #     latitude: params[:latitude],
    #     longitude: params[:longitude],
    #     created_by: @user,
    #     location: rec_already_there_loc
    #   )
    #
    #   else
    #     # give new location id
    #     new_garb_bin = Bin.new(
    #       bin_type: "GPUBL",
    #       latitude: params[:latitude],
    #       longitude: params[:longitude],
    #       created_by: @user,
    #       location: new_location
    #     )
    #   end
    #
    #   if new_garb_bin.save
    #
    #     new_user_bin = UserBin.new(
    #       user_id: params[:user_id],
    #       bin_id: new_garb_bin.id,
    #       action: 'add',
    #       user_lat: params[:latitude],
    #       user_lng: params[:longitude]
    #     )
    #
    #     if new_user_bin.save
    #       # get total distance user has travelled
    #       @user.reload
    #       @user.bin_count += 1
    #       @user.save
    #
    #       total_distance_travelled = @user.total_distance_travelled
    #
    #       #get all user_bins
    #       user_bins_formatted = get_user_bins(@user)
    #
    #       # user total
    #       user_bins_use = user_bins_formatted.select { |user_bin| user_bin["action"] == "use" }
    #
    #       user_bins_use_total = user_bins_use.count
    #
    #       # recycling total
    #       user_bins_rec = user_bins_use.select { |user_bin|
    #         user_bin["bin_type"] == "RYPUBL" }
    #
    #       user_bins_total_rec = user_bins_rec.count
    #
    #       # garbage total
    #       user_bins_gar = user_bins_use.select { |user_bin|
    #         user_bin["bin_type"] == "GPUBL" }
    #
    #       user_bins_total_gar = user_bins_gar.count
    #
    #       # report total
    #       user_bins_reports = user_bins_formatted.select { |user_bin| user_bin["action"] == "full" || user_bin["action"] == "missing" || user_bin["action"] == "add" }
    #
    #       user_bins_total_reports = user_bins_reports.count
    #
    #       # full total
    #       user_bins_full = user_bins_reports.select { |user_bin| user_bin["action"] == "full"}
    #
    #       user_bins_full_reports = user_bins_full.count
    #
    #       # missing total
    #       user_bins_missing = user_bins_reports.select { |user_bin| user_bin["action"] == "missing" }
    #
    #       user_bins_missing_reports = user_bins_missing.count
    #
    #       # add total
    #       user_bins_add = user_bins_reports.select { |user_bin| user_bin["action"] == "add" }
    #
    #       user_bins_add_reports = user_bins_add.count
    #
    #       json_response = {
    #         new_user_bin: [new_user_bin, new_user_bin2],
    #         user: @user,
    #         total_dist: total_distance_travelled,
    #         user_message: user_message,
    #         user_bins: user_bins_formatted,
    #         use_total: user_bins_use_total,
    #         total_rec: user_bins_total_rec,
    #         total_gar: user_bins_total_gar,
    #         total_reports: user_bins_total_reports,
    #         full_reports: user_bins_full_reports,
    #         missing_reports: user_bins_missing_reports,
    #         add_reports: user_bins_add_reports
    #       }
    #
    #       render status: :ok, json: json_response
    #     else
    #       render status: :bad_request, json: { errors: new_user_bin.errors }
    #     end
    #   else
    #     render status: :bad_request, json: { errors: new_garb_bin.errors }
    #   end

    # elsif params[:bin_type] == "BOTH" && gar_already_there
    #   # only create new recycling bin
    #
    #   # if lat+lng is exactly the same, give same location id
    #   if (params[:latitude] == gar_already_there_lat) && (params[:longitude] == gar_already_there_lng)
    #
    #     new_rec_bin = Bin.new(
    #       bin_type: "RYPUBL",
    #       latitude: params[:latitude],
    #       longitude: params[:longitude],
    #       created_by: @user,
    #       location: gar_already_there_loc
    #     )
    #
    #   else
    #     # give new location id
    #     new_rec_bin = Bin.new(
    #       bin_type: "RYPUBL",
    #       latitude: params[:latitude],
    #       longitude: params[:longitude],
    #       created_by: @user,
    #       location: new_location
    #     )
    #   end
    #
    #   if new_rec_bin.save
    #
    #     new_user_bin = UserBin.new(
    #       user_id: params[:user_id],
    #       bin_id: new_rec_bin.id,
    #       action: 'add',
    #       user_lat: params[:latitude],
    #       user_lng: params[:longitude]
    #     )
    #
    #     if new_user_bin.save
    #       # get total distance user has travelled
    #       @user.reload
    #       @user.bin_count += 1
    #       @user.save
    #
    #       total_distance_travelled = @user.total_distance_travelled
    #
    #       #get all user_bins
    #       user_bins_formatted = get_user_bins(@user)
    #
    #       # user total
    #       user_bins_use = user_bins_formatted.select { |user_bin| user_bin["action"] == "use" }
    #
    #       user_bins_use_total = user_bins_use.count
    #
    #       # recycling total
    #       user_bins_rec = user_bins_use.select { |user_bin|
    #         user_bin["bin_type"] == "RYPUBL" }
    #
    #       user_bins_total_rec = user_bins_rec.count
    #
    #       # garbage total
    #       user_bins_gar = user_bins_use.select { |user_bin|
    #         user_bin["bin_type"] == "GPUBL" }
    #
    #       user_bins_total_gar = user_bins_gar.count
    #
    #       # report total
    #       user_bins_reports = user_bins_formatted.select { |user_bin| user_bin["action"] == "full" || user_bin["action"] == "missing" || user_bin["action"] == "add" }
    #
    #       user_bins_total_reports = user_bins_reports.count
    #
    #       # full total
    #       user_bins_full = user_bins_reports.select { |user_bin| user_bin["action"] == "full"}
    #
    #       user_bins_full_reports = user_bins_full.count
    #
    #       # missing total
    #       user_bins_missing = user_bins_reports.select { |user_bin| user_bin["action"] == "missing" }
    #
    #       user_bins_missing_reports = user_bins_missing.count
    #
    #       # add total
    #       user_bins_add = user_bins_reports.select { |user_bin| user_bin["action"] == "add" }
    #
    #       user_bins_add_reports = user_bins_add.count
    #
    #       json_response = {
    #         new_user_bin: [new_user_bin, new_user_bin2],
    #         user: @user,
    #         total_dist: total_distance_travelled,
    #         user_message: user_message,
    #         user_bins: user_bins_formatted,
    #         use_total: user_bins_use_total,
    #         total_rec: user_bins_total_rec,
    #         total_gar: user_bins_total_gar,
    #         total_reports: user_bins_total_reports,
    #         full_reports: user_bins_full_reports,
    #         missing_reports: user_bins_missing_reports,
    #         add_reports: user_bins_add_reports
    #       }
    #
    #       render status: :ok, json: json_response
    #     else
    #       render status: :bad_request, json: { errors: new_user_bin.errors }
    #     end
      # else
      #   render status: :bad_request, json: { errors: new_rec_bin.errors }
      # end

    else
      # create one new bin
      new_bin = Bin.new(
        bin_type: params[:bin_type],
        latitude: new_lat,
        longitude: new_lng,
        created_by: @user,
        location: new_location
      )

      if new_bin.save

        new_user_bin = UserBin.new(
          user_id: params[:user_id],
          bin_id: new_bin.id,
          action: 'add',
          user_lat: new_lat,
          user_lng: new_lng
        )

        if new_user_bin.save
          # get total distance user has travelled
          @user.reload
          @user.bin_count += 1
          @user.save

          total_distance_travelled = @user.total_distance_travelled

          #get all user_bins
          user_bins_formatted = get_user_bins(@user)

          # user total
          user_bins_use = user_bins_formatted.select { |user_bin| user_bin["action"] == "use" }

          user_bins_use_total = user_bins_use.count

          # recycling total
          user_bins_rec = user_bins_use.select { |user_bin|
            user_bin["bin_type"] == "RYPUBL" }

          user_bins_total_rec = user_bins_rec.count

          # garbage total
          user_bins_gar = user_bins_use.select { |user_bin|
            user_bin["bin_type"] == "GPUBL" }

          user_bins_total_gar = user_bins_gar.count

          # report total
          user_bins_reports = user_bins_formatted.select { |user_bin| user_bin["action"] == "full" || user_bin["action"] == "missing" || user_bin["action"] == "add" }

          user_bins_total_reports = user_bins_reports.count

          # full total
          user_bins_full = user_bins_reports.select { |user_bin| user_bin["action"] == "full"}

          user_bins_full_reports = user_bins_full.count

          # missing total
          user_bins_missing = user_bins_reports.select { |user_bin| user_bin["action"] == "missing" }

          user_bins_missing_reports = user_bins_missing.count

          # add total
          user_bins_add = user_bins_reports.select { |user_bin| user_bin["action"] == "add" }

          user_bins_add_reports = user_bins_add.count

          json_response = {
            new_user_bin: new_user_bin,
            user: @user,
            total_dist: total_distance_travelled,
            user_bins: user_bins_formatted,
            use_total: user_bins_use_total,
            total_rec: user_bins_total_rec,
            total_gar: user_bins_total_gar,
            total_reports: user_bins_total_reports,
            full_reports: user_bins_full_reports,
            missing_reports: user_bins_missing_reports,
            add_reports: user_bins_add_reports
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
    user_bins = UserBin.where(user_id: user.id)
    user_bins_sorted = user_bins.order(:created_at).reverse


    user_bins_formatted = []
    user_bins_sorted.each do |user_bin|
      bin = Bin.find_by(id: user_bin.bin_id)
      user_bin_attributes = user_bin.attributes
      user_bin_attributes["bin_type"] = bin.bin_type
      user_bins_formatted << user_bin_attributes
    end

    return user_bins_formatted
  end

  # def get_user_bins(user)
  #   user_bins = UserBin.where(user_id: @user.id)
  #   user_bins_sorted = user_bins.order(:created_at).reverse
  #
  #   user_bins_array = user_bins_sorted.each_slice(1).to_a
  #
  #   user_bins_array.each do |user_bin|
  #     bin = Bin.find_by(id: user_bin[0].bin_id)
  #     if bin.bin_type == "RYPUBL"
  #       user_bin << { "bin_type" => "RECYCLING" }
  #     else
  #       user_bin << { "bin_type" => "GARBAGE" }
  #     end
  #   end
  #
  #   return user_bins_array
  # end

  # def distance_between_two_points(lat1, lon1, lat2, lon2)
  #
  #   radlat1 = Math::PI * (lat1 / 180)
  #   radlat2 = Math::PI * (lat2 / 180)
  #   theta = lon1 - lon2
  #   radtheta = Math::PI * (theta / 180)
  #   dist = Math.sin(radlat1) * Math.sin(radlat2) + Math.cos(radlat1) * Math.cos(radlat2) * Math.cos(radtheta)
  #   dist = Math.acos(dist)
  #   dist = dist * (180 / Math::PI)
  #   dist = dist * 60 * 1.1515
  #   # if (unit=="K") { dist = dist * 1.609344 }
  #   # if (unit=="N") { dist = dist * 0.8684 }
  #   return dist
  # end
end
