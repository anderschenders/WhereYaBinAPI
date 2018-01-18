class UserBinsController < ApplicationController

  def community_data
    user_bins = UserBin.all

    # all user_bins with action == "use"
    use_user_bins = user_bins.select { |user_bin| user_bin.action == "use" }
    use_user_bins_count = use_user_bins.length

    # count for all Users registered
    all_users = User.all.count

    # distance travelled by each user
    dist_travelled_all_users_array = []

    user_bins.each do |user_bin|
      dist_trav_user_hash = []
      user = User.find_by(id: user_bin.user_id)
      dist = user.total_distance_travelled
      dist_travelled_all_users_array << [user.id, dist]
    end

    # user who travelled the most
    most_travelled = dist_travelled_all_users_array[0]

    dist_travelled_all_users_array.each do |arr|
      if arr[1] > most_travelled[1]
        most_travelled = arr
      end
    end

    top_dist = most_travelled[1].round(2)
    top_dist_user_id = most_travelled[0]

    top_dist_user = User.find_by(id: top_dist_user_id)
    top_dist_username = top_dist_user.username

    # distance travelled by all users
    total_dist_travelled = 0
    dist_travelled_all_users_array.each do |arr|
      total_dist_travelled += arr[1]
    end

    # user with most activity
    user_activity_hash = {}

    user_bins.each do |user_bin|
      if user_activity_hash[user_bin.user_id]
        user_activity_hash[user_bin.user_id] += 1
      else
        user_activity_hash[user_bin.user_id] = 1
      end
    end

    top_user_activity_arr = user_activity_hash.max_by {|k, v| v}
    top_user_activity = top_user_activity_arr[1]
    top_user_activity_user_id = top_user_activity_arr[0]
    top_user_activity_user = User.find_by(id: top_user_activity_user_id)
    top_user_activity_username = top_user_activity_user.username

    json_response = {
      user_count: all_users,
      action_use_count: use_user_bins_count,
      total_dist_travelled: total_dist_travelled.round(2),
      top_dist: top_dist,
      top_dist_username: top_dist_username,
      top_user_activity: top_user_activity,
      top_user_activity_username: top_user_activity_username
    }

    render status: :ok, json: json_response
  end

  # def index

    # user_bins_array = get_user_bins(@user)
  #
  #   user_bins = UserBin.where(user_id: params[:user_id])
  #   user_bins_sorted = user_bins.order(:created_at).reverse
  #
  #   user_bins_array = user_bins_sorted.each_slice(1).to_a
  #
  #   user_bins_array.each do |user_bin|
  #     bin = Bin.find_by(id: user_bin[0].bin_id)
  #     if bin.bin_type === "RYPUBL"
  #       user_bin << { "bin_type" => "RECYCLING" }
  #     else
  #       user_bin << { "bin_type" => "GARBAGE" }
  #     end
  #   end
  #
  #   render status: :ok, json: user_bins_array
  # end

  def create

    @user = User.find_by(id: params[:user_id])
    @user.bin_count += 1
    @user.save

    bin = Bin.find_by(id: params[:bin_id])
    bin_latitude = bin.latitude
    bin_longitude = bin.longitude
    # add count to bin? First gotta make a new column

    # TODO: error handling if can't find user or bin

    new_user_bin = UserBin.new(
      user_id: params[:user_id],
      bin_id: params[:bin_id],
      action: params[:user_action],
      user_lat: params[:user_lat],
      user_lng: params[:user_lng]
    )

    if new_user_bin.save
      # get total distance user has travelled
      @user.reload
      total_distance_travelled = @user.total_distance_travelled

      # get all user_bins
      # user_bins_array = get_user_bins(@user)
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
        updated_user: @user,
        total_dist: total_distance_travelled,
        bin_location: "#{bin_latitude},#{bin_longitude}",
        # user_bins: user_bins_array
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

  #array of arrays:
  #   user_bins_sorted = user_bins.order(:created_at).reverse
  #
  #   user_bins_array = user_bins_sorted.each_slice(1).to_a
  #
  #   user_bins_array.each do |user_bin|
  #     bin = Bin.find_by(id: user_bin[0].bin_id)
  #     if bin.bin_type === "RYPUBL"
  #       user_bin << { "bin_type" => "RECYCLING" }
  #     else
  #       user_bin << { "bin_type" => "GARBAGE" }
  #     end
  #   end
  #
  #   return user_bins_array
  # end

end
