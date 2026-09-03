from fastapi import APIRouter

from services.history_service import get_network_history


router = APIRouter()


@router.get("/history")
def history():

    return get_network_history()