%w(collect sources filters source nil nil).combination(3).to_a.uniq.select { |a| !(a.include?(source) && a.include?(sources)) }
