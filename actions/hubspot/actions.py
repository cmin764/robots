"""Set of actions operating on HubSpot resources.

Currently supporting:
- Searching: companies, contacts, deals, tasks
"""


import os
from pathlib import Path
from typing import Annotated

from dotenv import load_dotenv
from pydantic import BaseModel, Field
from robocorp.actions import Secret, action

from hubspot import HubSpot
from hubspot.crm.companies import PublicObjectSearchRequest as CompanySearchRequest


ACCESS_TOKEN_FIELD = "HUBSPOT_ACCESS_TOKEN"

load_dotenv(Path("devdata") / ".env")


class CompanyResult(BaseModel):
    """Company search result object holding the queried information."""

    names: Annotated[list[str], Field(description="Company names.")]


@action(is_consequential=False)
def hubspot_search_companies(
    query: str,
    limit: int = 10,
    access_token: Secret = Secret.model_validate(os.getenv(ACCESS_TOKEN_FIELD, "")),
) -> CompanyResult:
    """Search for HubSpot companies based on the provided string query.

    This is a basic search returning a list of company names that are matching the
    `query` among any of their properties. The search will be limited to at most
    `limit` results, therefore you have to increase this parameter if you want to
    obtain more.

    Args:
        query: String that is searched for in all the company properties for a match.
        limit: The maximum number of results the search can return.

    Returns:
        A structure with a list of company names matching the query.
    """
    api_client = HubSpot(access_token=access_token.value)
    search_request = CompanySearchRequest(query=query, limit=limit)
    response = api_client.crm.companies.search_api.do_search(
        public_object_search_request=search_request
    )
    names = [result.to_dict()["properties"]["name"] for result in response.results]
    print(f"Companies matching query: {', '.join(names)}")
    return CompanyResult(names=names)
