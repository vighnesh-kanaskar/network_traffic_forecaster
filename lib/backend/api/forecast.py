from fastapi import APIRouter

from services.forecast_service import get_forecast


router = APIRouter()


@router.get("/forecast")
def forecast():

    return get_forecast()