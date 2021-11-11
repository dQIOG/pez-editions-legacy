UNIDAM export patch README
==========================

## Background

For some unknown reason, the UNIDAM metadata export we used to 
generate the msDesc documents from misses to reference more than 
14300 TIFF images which are however present as image files.

Since the images are organized in one folder per item ("Verzeichnungseinheit") 
(i.e. per msDesc), it was possible to find out which image is missing in
which msDesc; and since the IDs/filenames of the images are consecutively 
numbered, we are able to identify the position where these images should 
be injected in the msDesc.

## UNIDAM Export Data Structure

UNIDAM / easydb does not support digital objects with more than one image. 
Thus, the full metadata of each physical item was entered *for the first image*
(`R_pez_unidam_export_8768/Bilder-1-794.xml`).

The rest of the images/pages of the item are organized in a dedicated UNIDAM
collection ("pool" in easydb terminology), called "Folgeseiten". Each of these 
objects only contain metadata relevant to the specific page / image (e.g. file 
reference, its ID and the ID of the first page it belongs to, and foliation). 
These are stored in one XML file per physical item in the directory `_verz_einh`,
e.g. in the case above `_verz_einh/045.xml`:

```
<Folgeseiten>
	…
	<bild id="410257">
		<verz_einh id="84">:: Kt. 07 Patres  09 :: Faszikel 1 :: Nr. 66 </verz_einh>
		<foliierung_paginierung>64</foliierung_paginierung>
		<file-original>/partitions/1/0/256000/256878/9b8a847cfb969fc89b0768acce840759d475f41d/image/tiff</file-original>
		<pool id="222">Folgeseiten</pool>
	</bild>
	…
</Folgeseiten>
```

## Workflow

(NB This was an iterative process so it contains some redundancies.)

### 1. Step 1: Create a list of all tif files 

```
cd /mnt/acdh_resources/container/C_pez_19366/R_pez_unidam_export_8768
find . -name *.tif > tifs
```

`tifs` then simply looks like 

```
…
./045/407971.tif
./045/407972.tif
./045/407973.tif
./045/407974.tif
./045/407975.tif
./045/407976.tif
./045/407977.tif
…
```

### 2. Identify missing image file references in the UNIDAM export

Implemented in `083_scripts_xquery/ueberschuessige_tifs.xquery`, which … 

* iterates over the tif file list produced in Step 1,
* locates the respective UNIDAM metadata XML file by the folder name (e.g. in the example above `R_pez_unidam_export_8768/_verz_einh/45.xml`), and 
* compares the files present on disk with the references in the export.

Result: 

```
<ueberschuessige_tifs>
   <vze n="084" first-id="410194" last-id="410303" cnt="91">
      <bild id="410203">./084/410203.tif</bild>
      <bild id="410304">./084/410304.tif</bild>
      <bild id="410305">./084/410305.tif</bild>
      <bild id="410306">./084/410306.tif</bild>
      …
```

Output: `ueberschuessige_tifs.xml`

### 3. Manual Checks 

CHECKME I'm not terribly sure if this is accurate.

`ueberschuessige_tifs.xml` is imported into a Google spreadsheet[1] via CSV 
for checking/commenting/curation (NB transformation is missing!). 

The Google spreadsheet is downloaded to `ueberschuessige_tifs-Zuordnung.xls` 
and exported to the stand-alone Excel-XML representation `ueberschuessige_tifs-Zuordnung.xml`
for easier processing with XSLT/XQuery. 

### 4. Creating Patch File

The Script `083_scripts_xquery/patch_unidam_export.xquery` groups the flat lines in the Excel-XML by msDesc. 
Output: `unidam_export_patches.xml`

NB This step could actually be removed. 

### 5. Applying the Path File

Running `082_scripts_xsl/apply_unidam_export_patches.xsl` on the msDesc documents in `102_derived_tei/102_07_bequest/msDesc/` inserts the missing file references in the orginal data.

The oxygen transformation scenario *Nachlass – Patch msDesc 05 – apply patches* is configured to 
be run as the standard transformation on that directory.

### 6. Verify 

Running `083_scripts_xquery/patch_unidam_export_verify.xquery` on `ueberschuessige_tifs.xml` should report if TIFF files which cannot be found in the msDesc documents.

(It **does** report the known bug of a duplicate object with ID 411000 which references the images 411994–411997.)

oXygen transformation scenario *Nachlass – Patch msDesc 05 – apply patches*


