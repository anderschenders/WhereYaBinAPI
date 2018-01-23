module UserStats
  def user_stats(user)

    total_distance_travelled = user.total_distance_travelled

    #get all user_bins
    user_bins_formatted = get_user_bins(user)

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

    data_object = {
      total_distance_travelled: total_distance_travelled,
      user_bins_formatted: user_bins_formatted,
      user_bins_use_total: user_bins_use_total,
      user_bins_total_rec: user_bins_total_rec,
      user_bins_total_gar: user_bins_total_gar,
      user_bins_total_reports: user_bins_total_reports,
      user_bins_full_reports: user_bins_full_reports,
      user_bins_missing_reports: user_bins_missing_reports,
      user_bins_add_reports: user_bins_add_reports
    }

    return data_object
  end
end
