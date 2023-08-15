#!/bin/bash

#############
# FUNCTIONS #
#############

# $1: xml file
xml2json() {
  local python_code=$(cat << EOF
import sys, xmltodict, json
with open(sys.argv[1]) as fd: xml_data = xmltodict.parse(fd.read())
json_data=json.dumps(xml_data, indent=4)
print(json_data)
EOF
)
  python -c "${python_code}" $1
}

# $1: cin
jsonBeautifier() {
  # courtesy of yanOnGithub: https://github.com/jqlang/jq/issues/643#issuecomment-392384015
  # '$' are escaped below:
  local perl_code=$(cat << EOF
#!/bin/perl -0
while(<>) {
    my @array = split(/(\{[^{}]+\})/, \$_);
    for(my \$a = 1; \$a < scalar(@array); \$a += 2) {
        \$array[\$a] =~ s!^\s+!!mg;
        \$array[\$a] =~ s![\r\n]+! !g;
    }
    print join "", @array;
}
EOF
)
  perl -e "${perl_code}"
}

#############
# EXECUTION #
#############

# Basic checkings
[ -z "$1" ] && echo -e "\nUsage: $0 <xml file>\n" && exit 1
[ ! -f "$1" ] && echo -e "\nFile '$1' not found !\n" && exit 1
xml2json $1 | jsonBeautifier
