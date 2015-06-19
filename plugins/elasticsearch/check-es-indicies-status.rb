#! /usr/bin/env ruby
#
#  check-es-indices-status
#
# DESCRIPTION:
#   This plugin checks the ElasticSearch indices status, using its API.
#   Works with ES ES 1.4+
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: rest-client
#
# USAGE:
#   #YELLOW
#
# NOTES:
#
# LICENSE:
#   Copyright 2015 Alert Logic, Inc
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'json'
require 'open-uri'

class ESIndicesStatus < Sensu::Plugin::Check::CLI
    def run
        indicies_status = JSON.parse(open('http://localhost:9200/_cluster/health?level=indices').read)
        yellow = []
        red = []
        indicies_status["indices"].sort_by { |name| name }.each do |name, details|
            next if details["status"] == "green"
            yellow << name if details["status"] == "yellow"
            red << name if details["status"] == "red"
            puts "Index '#{name}' is not healthy. Status: #{details["status"]}"
        end

        exit 2 unless red.empty?
        exit 1 unless yellow.empty?
        puts "All #{indicies_status["indices"].size} indices are healthy"
        exit 0
    end
end
