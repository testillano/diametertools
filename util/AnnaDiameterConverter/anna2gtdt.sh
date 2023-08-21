#!/bin/bash

#############
# FUNCTIONS #
#############

# $1: xml file
xml2gtdt() {
  local python_code=$(cat << EOF
import sys, xmltodict, json, re
with open(sys.argv[1]) as fd: xml_data = xmltodict.parse(fd.read())

# Firstly, we will remove '@' in every key:
def rename_keys(d, transformation_func):
  keys_to_rename = list(d.keys())
  for key in keys_to_rename:
    new_key = transformation_func(key)
    if isinstance(d[key], dict):
      d[new_key] = d.pop(key)
      rename_keys(d[new_key], transformation_func)
    elif isinstance(d[key], list):
      new_list = []
      for item in d.pop(key):
        if isinstance(item, dict):
          new_list.append(rename_keys(item, transformation_func))
        else:
          new_list.append(item)
      d[new_key] = new_list
    else:
      d[new_key] = d.pop(key)

  return d

def remove_leading_arroba(s):
  return s[1:] if s.startswith('@') else s

rename_keys(xml_data, remove_leading_arroba)

# Adaptations to newer dictionary / message GTDT format based on RFC 6733 improvements.
# 1) Remove AVP may-encrypt and p-bit. Simplify v-bit and m-bit to boolean: must->true, mustnot->false
# 2) Rename format-name to just format.
# 3) Command of type 'Request' sets r-bit true, and 'Answer' sets r-bit false.
# 4) Command p-bit is missing in Anna dictionaries (mistake), but it would be removed anyway in the
#    algorithm confused with encrypt AVP bit. This PXY bit will be set later, fixing the problem
#    with xml dictionaries.

def process_keys(d):
  keys_to_process = list(d.keys())
  for key in keys_to_process:
    if isinstance(d[key], dict):
      process_keys(d[key])
    elif isinstance(d[key], list):
      new_list = []
      for item in d.get(key):
        if isinstance(item, dict):
          new_list.append(process_keys(item))
        else:
          new_list.append(item)
      d[key] = new_list
    else:
      if(key != "may-encrypt" and key != "p-bit"):
        d[key] = d.get(key)
        if(d[key] == "must"): d[key] = True
        if(d[key] == "mustnot"): d[key] = False
        if(key == "format-name"): d["format"] = d.pop(key)
        elif(key == "type"):
          if (d[key] == "Request"):
            d["r-bit"] = True
            d.pop(key)
          elif (d[key] == "Answer"):
            d["r-bit"] = False
            d.pop(key)
      else: d.pop(key)

  return d

process_keys(xml_data)


# Finally we remove first level (dictionary/message) because we must know the kind of file
# In the case of dictionary:
# 1) We add field "application-id" that in old ones is present in the name.
# 2) We add p-bit true, to all the non-base protocol commands

dictionary = xml_data.get("dictionary")
message = xml_data.get("message")

if dictionary:

  # Extract application-id from name:
  numbers = re.findall('\d+\.\d+|\d+', dictionary["name"])
  if not numbers:
    print("ERROR: application id number not detected within dictionary name. Not being specific field for it, you must edit the xml dictionary name.")
    sys.exit(1)
  applicationId = numbers[0]

  xml_data = dictionary
  xml_data["application-id"] = applicationId

  for command in xml_data["command"]:
    code = command["code"]
    if code != "257" and code != "280" and code != "282": command["p-bit"] = True

elif message:
  xml_data = message


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

xml2gtdt $1 | jsonBeautifier
