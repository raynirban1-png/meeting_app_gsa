from fastapi import FastAPI
from database import engine
from database import SessionLocal

from models import Base
from models import Member
from models import Notice
from models import Meeting
from models import Resolution
import json

app = FastAPI()

Base.metadata.create_all(
    bind=engine
)

db = SessionLocal()

admin_exists = db.query(Member).filter(
    Member.phoneNumber == "9999999999"
).first()

if not admin_exists:

    admin = Member(
        name="Admin",
        phoneNumber="9999999999",
        password="admin123",
        accessRole="Admin",
    )

    db.add(admin)

    db.commit()

db.close()


@app.get("/")
def home():

    return {
        "message":
        "GSA Governance Server Running"
    }


@app.get("/members")
def get_members():

    db = SessionLocal()

    members = db.query(Member).all()

    result = []

    for member in members:

        result.append({

            "name": member.name,

            "phoneNumber": member.phoneNumber,

            "password": member.password,

            "accessRole": member.accessRole,

        })

    db.close()

    return result


@app.post("/members")
def add_member(data: dict):

    db = SessionLocal()

    member = Member(

        name=data.get("name"),

        phoneNumber=data.get("phoneNumber"),

        password=data.get("password"),

        accessRole=data.get("accessRole"),
    )

    db.add(member)

    db.commit()

    db.refresh(member)

    db.close()

    return {
        "success": True
    }


@app.get("/notices")
def get_notices():

    db = SessionLocal()

    notices = db.query(Notice).all()

    result = []

    for notice in notices:

        result.append({

            "title": notice.title,

            "message": notice.message,

            "priority": notice.priority,

        })

    db.close()

    return result


@app.post("/notices")
def add_notice(data: dict):

    db = SessionLocal()

    notice = Notice(

        title=data.get("title"),

        message=data.get("message"),

        priority=data.get("priority"),
    )

    db.add(notice)

    db.commit()

    db.close()

    return {
        "success": True
    }


@app.get("/meetings")
def get_meetings():

    db = SessionLocal()

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

    db.close()

    return result


@app.post("/meetings")
def add_meeting(data: dict):

    db = SessionLocal()

    meeting = Meeting(

        title=data.get("title"),

        date=data.get("date"),

        venue=data.get("venue"),

        type=data.get("type"),

        status=data.get("status"),
    )

    db.add(meeting)

    db.commit()

    db.close()

    return {
        "success": True
    }


@app.get("/resolutions")
def get_resolutions():

    db = SessionLocal()

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

    db.close()

    return result


@app.post("/resolutions")
def add_resolution(data: dict):

    db = SessionLocal()

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

    db.close()

    return {
        "success": True
    }


@app.post("/login")
def login(data: dict):

    db = SessionLocal()

    member = db.query(Member).filter(

        Member.phoneNumber == data.get("phoneNumber")

    ).first()

    if member and member.password == data.get("password"):

        result = {

            "success": True,

            "member": {

                "name": member.name,

                "phoneNumber": member.phoneNumber,

                "accessRole": member.accessRole,
            }
        }

        db.close()

        return result

    db.close()

    return {
        "success": False
    }
