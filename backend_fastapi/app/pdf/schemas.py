from pydantic import BaseModel
from typing import List, Optional

class MedicationInfo(BaseModel):
    name: str
    dosage: str

class PatientReportData(BaseModel):
    name: str
    age: int
    height: int
    weight: int
    blood_sugar: str
    systolic: str
    diastolic: str
    heart_rate: str
    underlying_disease: str
    symptoms: str
    allergy: str
    medications: List[MedicationInfo]

class PatientReportResponse(BaseModel):
    success: bool
    message: str
    data: Optional[PatientReportData] = None