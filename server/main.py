from fastapi import FastAPI, Header
from database import engine
from database import SessionLocal

from models import Base
from models import Member
from models import Notice
from models import Meeting
from models import Resolution
from models import ActivityLog
import json
import bcrypt
from jose import jwt
from datetime import datetime
from datetime import timedelta

app = FastAPI()

SECRET_KEY = "gsa_secret_key"

ALGORITHM = "HS256"

ACCESS_TOKEN_EXPIRE_HOURS = 24

def hash_password(password: str) -> str:
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')

def verify_password(password: str, hashed_password: str) -> bool:
    return bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8'))

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(hours=ACCESS_TOKEN_EXPIRE_HOURS)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def get_current_user(token: str):

    try:

        payload = jwt.decode(
            token,
            SECRET_KEY,
            algorithms=[ALGORITHM]
        )

        return payload

    except:

        return None
# Create tables
Base.metadata.create_all(bind=engine)

def seed_admin():
    db = SessionLocal()
    try:
        admin_exists = db.query(Member).filter(
            Member.phoneNumber == "9999999999"
        ).first()

        if not admin_exists:
            hashed_admin_password = hash_password("admin123")
            admin = Member(
                name="Admin",
                phoneNumber="9999999999",
                password=hashed_admin_password,
                accessRole="Admin",
            )
            db.add(admin)
            db.commit()
    finally:
        db.close()

seed_admin()

@app.get("/")
def home():
    return {
        "message": "GSA Governance Server Running"
    }


@app.get("/members")
def get_members():
    db = SessionLocal()
    try:
        members = db.query(Member).all()
        result = []
        for member in members:
            result.append({
                "name": member.name,
                "phoneNumber": member.phoneNumber,
                "password": member.password,
                "accessRole": member.accessRole,
            })
        return result
    finally:
        db.close()


@app.post("/members")
def add_member(
        data: dict,
        authorization: str = Header(
            default=None,
            alias="Authorization"
        )
):
    db = SessionLocal()
    auth_header = authorization

    if not auth_header:

        return {
            "success": False,
            "message": "Token missing"
        }

    token = auth_header.replace(
        "Bearer ",
        ""
    )

    payload = get_current_user(token)

    if not payload:

        return {
            "success": False,
            "message": "Invalid token"
        }

    if payload.get("accessRole") != "Admin":

        return {
            "success": False,
            "message": "Admin access required"
        }
    try:
        existing_member = db.query(Member).filter(
            Member.phoneNumber == data.get("phoneNumber")
        ).first()

        if existing_member:

                return {
                    "success": False,
                    "message": "Phone number already exists"
                    }
        member = Member(
            name=data.get("name"),
            phoneNumber=data.get("phoneNumber"),
            password=hash_password(data.get("password")),
            accessRole=data.get("accessRole"),
        )
        db.add(member)
        db.commit()
        log = ActivityLog(

            action="Member Added",

            performedBy=
            payload.get(
                "phoneNumber"
            ),

            timestamp=str(
                datetime.utcnow()
            )
        )

        db.add(log)

        db.commit()
        return {"success": True}
    finally:
        db.close()


@app.get("/notices")
def get_notices():
    db = SessionLocal()
    try:
        notices = db.query(Notice).all()
        result = []
        for notice in notices:
            result.append({
                "title": notice.title,
                "message": notice.message,
                "priority": notice.priority,
            })
        return result
    finally:
        db.close()


@app.post("/notices")
def add_notice(
    data: dict,
    authorization: str = Header(
        default=None,
        alias="Authorization"
    )
):
    db = SessionLocal()
    auth_header = authorization

    if not auth_header:

        return {
            "success": False,
            "message": "Token missing"
        }

    token = auth_header.replace(
        "Bearer ",
        ""
    )

    payload = get_current_user(token)

    if not payload:

        return {
            "success": False,
            "message": "Invalid token"
        }

    if payload.get("accessRole") != "Admin":

        return {
            "success": False,
            "message": "Admin access required"
        }

    try:
        notice = Notice(
            title=data.get("title"),
            message=data.get("message"),
            priority=data.get("priority"),
        )
        db.add(notice)
        db.commit()
        return {"success": True}
    finally:
        db.close()


@app.get("/meetings")
def get_meetings():
    db = SessionLocal()
    try:
        meetings = db.query(Meeting).all()
        result = []
        for meeting in meetings:
            result.append({
                "title": meeting.title,
                "date": meeting.date,
                "venue": meeting.venue,
                "type": meeting.type,
                "status": meeting.status,
            })
        return result
    finally:
        db.close()


@app.post("/meetings")
def add_meeting(
        data: dict,
        authorization: str = Header(
            default=None,
            alias="Authorization"
        )
):
    db = SessionLocal()
    auth_header = authorization

    if not auth_header:

        return {
            "success": False,
            "message": "Token missing"
        }

    token = auth_header.replace(
        "Bearer ",
        ""
    )

    payload = get_current_user(token)

    if not payload:

        return {
            "success": False,
            "message": "Invalid token"
        }

    if payload.get("accessRole") != "Admin":

        return {
            "success": False,
            "message": "Admin access required"
        }
    try:
        meeting = Meeting(
            title=data.get("title"),
            date=data.get("date"),
            venue=data.get("venue"),
            type=data.get("type"),
            status=data.get("status"),
        )
        db.add(meeting)
        db.commit()
        log = ActivityLog(

            action="Meeting Created",

            performedBy=
            payload.get(
                "phoneNumber"
            ),

            timestamp=str(
                datetime.utcnow()
            )
        )

        db.add(log)

        db.commit()
        return {"success": True}
    finally:
        db.close()


@app.get("/resolutions")
def get_resolutions():
    db = SessionLocal()
    try:
        resolutions = db.query(Resolution).all()
        result = []
        for resolution in resolutions:
            result.append({
                "title": resolution.title,
                "description": resolution.description,
                "meetingTitle": resolution.meetingTitle,
                "forVotes": resolution.forVotes,
                "againstVotes": resolution.againstVotes,
                "abstainVotes": resolution.abstainVotes,
                "votedMembers": json.loads(resolution.votedMembers) if resolution.votedMembers else [],
                "status": resolution.status,
            })
        return result
    finally:
        db.close()

@app.get("/activity-logs")
def get_activity_logs():

    db = SessionLocal()

    try:

        logs = db.query(
            ActivityLog
        ).all()

        return [

            {
                "action":
                    log.action,

                "performedBy":
                    log.performedBy,

                "timestamp":
                    log.timestamp,
            }

            for log in logs
        ]

    finally:

        db.close()

@app.get("/create-tables")
def create_tables():

    Base.metadata.create_all(
        bind=engine
    )

    return {
        "message":
            "Tables created"
    }


@app.post("/resolutions")
def add_resolution(
        data: dict,
        authorization: str = Header(
            default=None,
            alias="Authorization"
        )
):
    db = SessionLocal()
    auth_header = authorization

    if not auth_header:

        return {
            "success": False,
            "message": "Token missing"
        }

    token = auth_header.replace(
        "Bearer ",
        ""
    )

    payload = get_current_user(token)

    if not payload:

        return {
            "success": False,
            "message": "Invalid token"
        }

    if payload.get("accessRole") != "Admin":

        return {
            "success": False,
            "message": "Admin access required"
        }
    try:
        resolution = Resolution(
            title=data.get("title"),
            description=data.get("description"),
            meetingTitle=data.get("meetingTitle"),
            forVotes=data.get("forVotes", 0),
            againstVotes=data.get("againstVotes", 0),
            abstainVotes=data.get("abstainVotes", 0),
            votedMembers=json.dumps(data.get("votedMembers", [])),
            status=data.get("status", "Draft"),
        )
        db.add(resolution)
        db.commit()
        return {"success": True}
    finally:
        db.close()


@app.post("/login")
def login(data: dict):
    db = SessionLocal()
    try:
        member = db.query(Member).filter(
            Member.phoneNumber == data.get("phoneNumber")
        ).first()

        if member and verify_password(data.get("password"), member.password):
            token = create_access_token({

                "phoneNumber":
                    member.phoneNumber,

                "accessRole":
                    member.accessRole,
            })
            return {
                "success": True,
                "token": token,
                "member": {

                    "name": member.name,

                    "role": "",

                    "department": "",

                    "phoneNumber": member.phoneNumber,

                    "password": "",

                    "accessRole": member.accessRole,
                }
            }
        return {"success": False}
    finally:
        db.close()
