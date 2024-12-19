import glob
import json
import lxml.etree as ET
import os
from collections import defaultdict
from acdh_tei_pyutils.tei import TeiReader

print("creating list of organizations")

nsmap = {"ead": "http://ead3.archivists.org/schema/"}


files = glob.glob("101_derived/ead/*/*.xml")


d = defaultdict(dict)
org_list = set()
org_index_map = {}
index_counter = 1

for x in files:
    heads, tail = os.path.split(x)
    doc = TeiReader(x)
    doc = doc.tree
    title = doc.xpath(".//ead:unittitle/text()", namespaces=nsmap)[0]
    orgs = doc.xpath(
        ".//ead:controlaccess[./ead:head/text() = 'Institutionen']/ead:corpname",
        namespaces=nsmap,
    )
    for org in orgs:
        name = " > ".join(
            org.xpath("./ead:part[not(@localtype)]/text()", namespaces=nsmap)
        )
        if name not in org_index_map:
            org_index_map[name] = f"org_{index_counter:04}"
            index_counter += 1
        org_list.add(name)
        xmlid = org_index_map[name]

        if "mentiones" not in d[xmlid]:
            d[xmlid]["mentiones"] = list()

        d[xmlid]["mentiones"].append(
            {
                "title": title,
                "id": tail,
            }
        )
        d[xmlid]["name"] = name
        d[xmlid]["ids"] = org.xpath("./ead:part[@localtype]/text()", namespaces=nsmap)
with open("hansi.json", "w", encoding="utf-8") as f:
    json.dump(d, f, ensure_ascii=False, indent=2)

template = """
<TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">
   <teiHeader>
      <fileDesc>
         <titleStmt>
            <title>Organisationsverzeichnis</title>
         </titleStmt>
         <publicationStmt>
            <p>Publication Information</p>
         </publicationStmt>
         <sourceDesc>
            <p>born digital, created with create_listorg.py</p>
         </sourceDesc>
      </fileDesc>
   </teiHeader>
   <text>
      <body>
         <p>Some text here.</p>
         <listOrg />
      </body>
   </text>
</TEI>
"""

doc = TeiReader(template)
listorg = doc.any_xpath(".//tei:listOrg")[0]
for key, value in d.items():
    org = ET.Element("{http://www.tei-c.org/ns/1.0}org")
    org.attrib["{http://www.w3.org/XML/1998/namespace}id"] = key
    orgname = ET.Element("{http://www.tei-c.org/ns/1.0}orgName")
    orgname.text = value["name"]
    org.append(orgname)
    for mention in value["mentiones"]:
        ptr = ET.Element("{http://www.tei-c.org/ns/1.0}ptr")
        ptr.attrib["target"] = mention["id"]
        ptr.attrib["n"] = mention["title"]
        org.append(ptr)
    for idno in value["ids"]:
        idno_el = ET.Element("{http://www.tei-c.org/ns/1.0}idno")
        idno_el.text = idno
        if "gnd" in idno:
            idno_el.attrib["type"] = "gnd"
        elif "viaf" in idno:
            idno_el.attrib["type"] = "viaf"
        elif "wikidata" in idno:
            idno_el.attrib["type"] = "wikidata"
        else:
            idno_el.attrib["type"] = "other"
        org.append(idno_el)
    listorg.append(org)
doc.tree_to_file("102_derived_tei/102_07_bequest/listorg.xml")

print("Done.")
