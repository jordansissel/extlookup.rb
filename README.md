# command-line extlookup

Puppet's extlookup is nice. I want it in other places, so I wrote this.

The particular use case was being able to deploy a specific version+branch of
our internal puppet modules to production and other sites. For every other
package-specific case, we have an extlookup value of
"package/<packagename>,1234.branch" that we use to hint puppet on what version
of things to install or to upgrade.

The above works great except for puppet modules itself because I use masterless
puppet. My puppet runs are 3 phase, in a shell script:

1. update to latest version of "loggly-puppet" package 
2. run puppet with environment 'prerun' to ensure storeconfigs and friends work
3. run final, and real, puppet run with storeconfigs etc.

This tool (extlookup.rb) aims to help me augment #1 by allowing me to specify a
package version and branch the same way we already specify this for other
internal packages at Loggly.

## Example usage:

    % FACTERLIB=/opt/puppet/modules/truth/plugins/facter/ \
      ruby extlookup.rb --datadir /opt/loggly/deployment \
        -p "%{deployment}/%{fqdn}" -p "%{deployment}/config" \
        -p common -p truth package/loggly-frontend

    3745.trunk

    % ruby extlookup.rb ... config/infrastructure/iptables-management
    true

## TODO

* Take a manifest file and attempt to parse out the $extlookup_ settings rather
  than requiring --datadir and many -p flags
