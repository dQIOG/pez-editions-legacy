import os
import pandas as pd
from acdh_tei_pyutils.tei import TeiReader
from acdh_tei_pyutils.utils import get_xmlid
from acdh_xml_pyutils.xml import NSMAP


doc = TeiReader("./102_derived_tei/102_07_bequest/listperson.xml")

data = []
for x in doc.any_xpath(".//tei:person[@xml:id]"):
    try:
        name = x.xpath(".//tei:persName[@type='pref']/text()", namespaces=NSMAP)[0]
    except IndexError:
        name = ""
    try:
        provided_gnd = x.xpath(".//tei:idno[@type='GND']/text()", namespaces=NSMAP)[0]
    except IndexError:
        provided_gnd = ""
    try:
        forename = x.xpath(".//tei:forename/text()", namespaces=NSMAP)[0]
    except IndexError:
        forename = ""
    try:
        surname = x.xpath(".//tei:surname/text()", namespaces=NSMAP)[0]
    except IndexError:
        surname = ""
    item = {
        "id": get_xmlid(x),
        "name": name.replace('"', ""),
        "forename": forename.replace('"', ""),
        "surname": surname.replace('"', ""),
        "provided_gnd": provided_gnd,
    }

    data.append(item)


df = pd.DataFrame(data)
df.to_csv(os.path.join("openrefine", "persons.csv"), index=False)
