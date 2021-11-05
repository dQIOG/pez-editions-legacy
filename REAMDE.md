# Pez-Edition

This README describes the artifacts in the Pez dataset in their finale state. For information on how this was generated (including the temporary files found in the git repository, please refer to pez_PROCESS.csv.xlsx or https://docs.google.com/spreadsheets/d/1vXyVMggpMo43d0jk0Q5wXQiNj1dCiaG1dVI_OwmY5U4/edit#gid=930549692

## Edition data

* letters vols 1 and 2: `102_derived_tei/102_03_extracted_letters`
* letters currently being edited (vol 3+):  `102_derived_tei/102_08_BandIIIf`

Each letter has its ID / a running number in `<idno type="pezEd">14<idno>` in `/TEI/teiHeader/fileDesc/publicationStmt`. For vols 1 and 2 this is the same as in the printed edition (with stripped square brackets in case of missing letters).

### Indexes and auxiliary lists

* **Index I** (places/institutions/persons/works): `102_derived_tei/102_02_extracted_index_entries/Pez_Register_Bd2/*.xml`
* **Index II** (Redensarten, Zitate, Leitbegriffe etc.): `102_derived_tei/102_02_extracted_index_entries/II_Redensarten_etc-merged.xml`
* **Index III** (manuscripts mentioned in the letters):  `102_derived_tei/102_02_extracted_index_entries/index-ms-vol2.xml` (NB This index appears only in Vol. 2)
* **letters exchanged between third parties** 
	* Vol. 1 (*Appendix II.3*): `102_derived_tei/102_04_auxiliary_files/drittbriefe.xml` (NB this file contains only the content of Vol. 1)
	* Vol. 2: not converted yet
* **attachments**: (NB ? currently missing, but AFAIR I had a working copy)

References from indexes to letters via `<ref type="letter">1020</ref>` where the value corresponds to a letter ID.

**Notes on Index I**

Originally, each of the printed volume came with its own set of indexes which were both converted to TEI separatedly. For *Index I*, the entries of vol. 1 were integrated into the structure of vol. 2 by hand using a simple interface at https://pez-curation.acdh-dev.oeaw.ac.at/mergeIndexes.html. Thus, the "final" version is found in the directory of vol 2 (which is a static export of the above mentioned webapp).

It was explicitly asked to keep the hierarchical organisation of *Index I* as it was in the printed volumes so we refrained from representing the index with more semantic markup (like `<listPerson>` / `<person>` or `<listPlace>`/`<place>`) but to employ a very generic structure of nested `<list>/<item>` elements which allowed us to represent the index hierarchy by document structure. This would not have been possible with the content model of more semantic markup.

The type information on each index entry is encoded via an `@ana` attribute, e.g. `ana="indextypes:person"` on `<item ana="indextypes:work" status="checked" xml:id="d14380e13787">`. This information was added by hand during merging the index entries of vol. 1 and 2. The `@status` attribute (illegal on `<item>`) was only used during editing and should be removed from the final data. 

Only references to *Index I* are tagged in the text of the letters using `<rs key="index:d10854e23695">Enzyklik</rs>` – i.e. the type of the targeted index entry (person, institution/place, work etc.) could be automatically added by a simple script, reading the `@ana` attribute on the respective index entry. 

**Notes on Index II**

Given the much more simple structure of Index II, data of both Volumes were merged into one document programmatically.


### Bibliography 

#### Printed Sources and Literature

cf. https://redmine.acdh.oeaw.ac.at/issues/18628 

derived from MS Word manuscripts via MODS, imported into Zotero and manually curated there (i.e. this is the authoritative source)

https://www.zotero.org/groups/514939

Temporary / auxiliary versions:

A static TEI export from Zotero of the bibliography Since the ediarium plugin used for tagging the TEI documents has shown performance issues with the full TEI export of the bibligraphy and moreover misses XML namespace support, a simple list of short citations (`bibliography.xml`) is used instead. 

* `102_derived_tei/102_04_auxiliary_files/bibliography.xml`: simplified representation of short citations (pairs of ID and short citation) used by the ediarium oXygen plugin 
* `102_derived_tei/102_04_auxiliary_files/bibliography_TEI.xml`: full export of Zotero library

References from letters to bibliography via `<rs type="bibl" key="bibl:17490">` where the ID part after `bibl:` in `@key` corresponds to an `<ID>` value in `102_derived_tei/102_04_auxiliary_files/bibliography.xml`.

#### Archival Sources and cited manuscripts

* Vol. 1 (*Appendix III.1*): `102_derived_tei/102_derived_tei/102_04_auxiliary_files/bibl_sources1.xml`
* Vol. 2 (*Appendix IV.1*): `102_derived_tei/102_derived_tei/102_04_auxiliary_files/bibl_sources2.xml` 


### Biographical Sketches 

Both volumes feature a series of short biographical sketches of persons nor covered in other literature. These have been converted to TEI and merged into one `<listPerson>` in the document `102_derived_tei/102_04_auxiliary_files/biographica.xml`. The text of the sketch is encoded in a `<note>` element; in cases where the automatic merge script has discovered differences in the texts about the same person in both volumes, two `<note>` elements have been inserted which should be manually reconciled.
 

## Pez-Nachlass

### `102_derived_tei/102_07_bequest`

* `102_derived_tei/102_07_bequest/listperson.xml` merges data from
  * `001_src/UNIDAM-Exporte/BildPersonen.xml`
  * `001_src/Personen_IR-bearbeitet_TW20180724.xml` with
  * `082_scripts_xsl/personbilder2listperson.xsl`

### Institutions / Groups

A hierachically ordered list of groups/institutions is used as a finding aid in UNIDAM. This has been manually enriched with references to authority file by Irene Rabl and Thomas Wallnig and converted into a TEI taxonomy.

Cf. `102_derived_tei/102_04_auxiliary_files/institutions.xml` (NB given that this list stems from the bequest context, it should be probably moved to `102_07_bequest`.)

### handle-id

added handle ids with [acdh-tei-pyutils](https://acdh-tei-pyutils.readthedocs.io/en/latest/index.html) using a command similar like the one below

```shell
add-handles -g "../pez-edition/102_derived_tei/102_07_bequest/msDesc/*/*.xml" -user "user12.3456-01" -pw "verysecret" -hixpath ".//tei:publicationStmt"
```
