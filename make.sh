rm -f *.gem
gem uninstall elastic_tabstops
gem build ./elastic_tabstops.gemspec \
  && gem install --local elastic_tabstops-*.gem
