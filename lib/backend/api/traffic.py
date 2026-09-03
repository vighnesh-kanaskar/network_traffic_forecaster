from fastapi import APIRouter

from services.network_service import get_live_traffic


router = APIRouter()


@router.get("/traffic")
def traffic():

    return get_live_traffic()