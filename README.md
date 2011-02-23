# command-line extlookup

Puppet's extlookup is nice. I want it in other places, so I wrote this.

## Example usage:

    % env FACTERLIB=/opt/puppet/modules/truth/plugins/facter/ \
      ruby extlookup.rb --datadir /opt/loggly/deployment \
        -p "%{deployment}/%{fqdn}" -p "%{deployment}/config" \
        -p common -p truth package/loggly-frontend

    3745.trunk

## TODO

* Take a manifest file and attempt to parse out the $extlookup_ settings rather than requiring --datadir and many -p flags
