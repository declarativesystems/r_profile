# @summary A generic 'baseleve' style class
class r_profile::base {
  include "r_profile::${downcase($kernel)}::base"
}
