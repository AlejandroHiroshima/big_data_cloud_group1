#========================================#
#                                        #
#    This script loads job ads for       #
#    "Yrken med teknisk inriktning"      #
#                                        #
#========================================#


import dlt
import requests
import json


# truncate staging_staging schema produced by dlt together with dagster by default
dlt.config["load.truncate_staging_dataset"] = True

params = {
    "q": "",
    "limit": 100,
    "occupation-field": ["MVqp_eS8_kDZ", "E7hm_BLq_fqZ", "ASGV_zcE_bWf"],
}

def _get_ads(url_for_search, params):
    response = requests.get(url_for_search, params=params)
    response.raise_for_status()  # check for http errors
    return json.loads(response.content.decode("utf8"))


@dlt.resource(table_name = "job_ads",
        write_disposition="replace")
def jobsearch_resource(params):
    url = "https://jobsearch.api.jobtechdev.se"
    url_for_search = f"{url}/search"
    limit = params.get("limit", 100)
    offset = 0

    while True:
        # build this page’s params
        page_params = dict(params, offset=offset)
        data = _get_ads(url_for_search, page_params)

        hits = data.get("hits", [])
        if not hits:
            # no more results
            break

        # yield each ad on this page
        for ad in hits:
            yield ad

        # if fewer than a full page was returned, we’re done
        if len(hits) < limit or offset > 1900:
            break

        offset += limit

# dagster only works with dlt source, not dlt resource
@dlt.source
def jobads_source():
    return jobsearch_resource(params)
