import glob
from acdh_tei_pyutils.tei import TeiReader


files = sorted(glob.glob('./102_derived_tei/102_07_bequest/msDesc/*/*.xml'))
for x in files:
    doc = TeiReader(x)
    date_el = doc.any_xpath('.//tei:date')[0]

    for key, value in date_el.items():
        if len(value) == 4:
            date_el.attrib[key] = f"{value}-01-01"
        elif len(value) > 10:
            print(x, key, value)
    doc.tree_to_file(x)
