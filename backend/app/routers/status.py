from fastapi import APIRouter

router = APIRouter(tags=["Status"])


@router.get("/status")
def get_status() -> dict:
    return {"status": "ok"}