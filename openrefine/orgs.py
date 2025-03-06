import os
import pandas as pd
from acdh_tei_pyutils.tei import TeiReader
from acdh_tei_pyutils.utils import get_xmlid, normalize_string
from acdh_xml_pyutils.xml import NSMAP


doc = TeiReader("./102_derived_tei/102_07_bequest/listorg.xml")

data = []
for x in doc.any_xpath(".//tei:org[@xml:id]"):
    try:
        name = normalize_string(x.xpath(".//tei:orgName[1]/text()", namespaces=NSMAP)[0])
    except IndexError:
        name = ""
    try:
        provided_gnd = x.xpath(".//tei:idno[@type='gnd']/text()", namespaces=NSMAP)[0]
    except IndexError:
        provided_gnd = ""
    name_part = name.split(" > ")[-1]
    item = {
        "id": get_xmlid(x),
        "name": name.replace('"', ""),
        "name_part": name_part,
        "provided_gnd": provided_gnd,
    }

    data.append(item)


df = pd.DataFrame(data)
df.to_csv(os.path.join("openrefine", "orgs.csv"), index=False)
