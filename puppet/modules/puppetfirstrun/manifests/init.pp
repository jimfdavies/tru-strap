# Class: puppetfirstrun
#
# This module manages puppetagent on the first SIGNED connection
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class puppetfirstrun ($output_text = "nope Im default") {
  include puppetfirstrun::config

  notify {$output_text :}

}