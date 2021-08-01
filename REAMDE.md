# Pez-Edition

## Pez-Nachlass

### `102_derived_tei/102_07_bequest`

* `102_derived_tei/102_07_bequest/listperson.xml` merges data from
  * `001_src/UNIDAM-Exporte/BildPersonen.xml`
  * `001_src/Personen_IR-bearbeitet_TW20180724.xml` with
  * `082_scripts_xsl/personbilder2listperson.xsl`

### handle-id

added handle ids with [acdh-tei-pyutils](https://acdh-tei-pyutils.readthedocs.io/en/latest/index.html) using a command similar like the one below

```shell
add-handles -g "../pez-edition/102_derived_tei/102_07_bequest/msDesc/*/*.xml" -user "user12.3456-01" -pw "verysecret" -hixpath ".//tei:publicationStmt"
```
