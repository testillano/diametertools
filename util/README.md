# Util

## Anna-Diameter deprecated formats

[Anna-Diameter Suite](https://git.teslayout.com/public?p=anna.git;a=tree) diameter formats are based on [xml language](https://www.w3schools.com/xml/) which are ruled by project `dtd` templates.

The format used by our new project, [gtdt](https://github.com/testillano/diametertools) (aka, `github testillano diametertools`) is [json](https://www.json.org/json-en.html). So here we provide a bash script to convert the old ones.

XML conversion is based on `xmltodict` python module, which translates `xml` attributes to `json` nodes by mean prefixing the keys with '@' character. In our case, it is not a handicap as we provide also `json` schema's taking this into account.

The conversion is valid for Anna-Diameter **messages** and also Anna-Diameter **dictionaries**. Two `xml` example files are provided for those kind of Anna-Diameter resources, in order to play with them and check how the result looks. The bash script, also beautifies the resulting `json` to have a more compact output and improve readability:

```bash
$> cd util/AnnaDiameterConverter
$> ./anna2gtdt.sh ANNA_DIAMETER_MESSAGE__ccr.xml
...
$> ./anna2gtdt.sh ANNA_DIAMETER_DICTIONARY__DictionaryRx.16777236.xml
...
```

This project **never uses or log** `xml` data, but the script may be useful just in case some old format need to be translated to be used with tools developed in this repository.
