import glob
import os
from acdh_tei_pyutils.tei import TeiReader
from acdh_handle_pyutils.client import HandleClient


HANDLE_USERNAME = os.environ.get("HANDLE_USERNAME")
HANDLE_PASSWORD = os.environ.get("HANDLE_PASSWORD")
hdl_client = HandleClient(HANDLE_USERNAME, HANDLE_PASSWORD)


files = glob.glob('./102_derived_tei/102_07_bequest/msDesc/*/*.xml')
for x in files:
    _ , tail = os.path.split(x)
    doc = TeiReader(x)
    to_update = doc.any_xpath('.//tei:idno[@type="handle"]')[0].text
    new_url = f"https://id.acdh.oeaw.ac.at/pez-nachlass/{tail}"
    try:
        updated = hdl_client.update_handle(to_update, new_url)
        print(updated.status_code)
    except Exception as e:
        print(x, e)
    