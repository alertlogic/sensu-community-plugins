#!/usr/bin/env ruby
#
# CHANGELOG:
# * 0.1.0:
#   - Initial release
#
# This handler deletes a Sensu client if it's been stopped or terminated in ECS.
#
# NOTE: The implementation for correlating Sensu clients to ECS instances may
# need to be modified to fit your organization.
#
# Requires the following Rubygems (`gem install $GEM`):
#   - sensu-plugin
#   - aws-sdk-core
#
# To use, you can set it as the keepalive handler for a client:
#   {
#     "client": {
#       "name": "i-424242",
#       "address": "127.0.0.1",
#       "keepalive": {
#         "handler": "ecs_node"
#       },
#       "subscriptions": ["all"]
#     }
#   }
#
# You can also use this handler with a filter:
#   {
#     "filters": {
#       "ghost_nodes": {
#         "attributes": {
#           "check": {
#             "name": "keepalive",
#             "status": 2
#           },
#           "occurences": "eval: value > 2"
#         }
#       }
#     },
#     "handlers": {
#       "ecs_node": {
#         "type": "pipe",
#         "command": "/etc/sensu/handlers/ecs_node.rb",
#         "severities": ["warning","critical"],
#         "filter": "ghost_nodes"
#       }
#     }
#   }
#
# Copyleft 2013 Yet Another Clever Name
#
#
# Released under the same terms as Sensu (the MIT license); see
# LICENSE for details

require 'timeout'
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'
require 'aws-sdk-core'
require 'json'
require 'open-uri'

class EcsNode < Sensu::Handler
  def filter; end

  def handle
    # #YELLOW
    delete_sensu_client!
  end

  def delete_sensu_client!
    response = api_request(:DELETE, '/clients/' + @event['client']['name']).code
    deletion_status(response)
  end

  def deletion_status(code)
    case code
    when '202'
      puts "[ECS Node] 202: Successfully deleted Sensu client: #{@event['client']['name']}"
    when '404'
      puts "[ECS Node] 404: Unable to delete #{@event['client']['name']}}, doesn't exist!"
    when '500'
      puts "[ECS Node] 500: Miscellaneous error when deleting #{@event['client']['name']}}"
    else
      puts "[ECS Node] #{res}: Completely unsure of what happened!"
    end
  end
end

