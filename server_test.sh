#/bin/bash

# Remove old results
[ -d output-rack ] && rm -f output-rack/*

# Test each kind of profile on its own
hack=wall-single    bundle exec rackup
hack=cpu-single     bundle exec rackup
hack=process-single bundle exec rackup

# Finally  profile using all 3 profiles
bundle exec rackup
