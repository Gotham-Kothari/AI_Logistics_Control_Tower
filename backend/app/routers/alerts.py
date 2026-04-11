from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.repositories.exception_repo import ExceptionRepository
from app.services.serializers import FlutterSerializer

router = APIRouter(prefix="/alerts", tags=["Alerts"])


@router.get("")
def list_alerts(db: Session = Depends(get_db)) -> list[dict]:
    repo = ExceptionRepository(db)
    return [FlutterSerializer.alert(item) for item in repo.list_alerts()]