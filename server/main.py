from fastapi import FastAPI
import json

app = FastAPI()


def load_members():

    with open(
        "members.json",
        "r"
    ) as file:

        return json.load(file)


def save_members(members):

    with open(
        "members.json",
        "w"
    ) as file:

        json.dump(
            members,
            file,
            indent=2
        )


def load_notices():

    with open(
        "notices.json",
        "r"
    ) as file:

        return json.load(file)


def save_notices(notices):

    with open(
        "notices.json",
        "w"
    ) as file:

        json.dump(
            notices,
            file,
            indent=2
        )


def load_meetings():

    with open(
        "meetings.json",
        "r"
    ) as file:

        return json.load(file)


def save_meetings(meetings):

    with open(
        "meetings.json",
        "w"
    ) as file:

        json.dump(
            meetings,
            file,
            indent=2
        )


def load_resolutions():

    with open(
        "resolutions.json",
        "r"
    ) as file:

        return json.load(file)


def save_resolutions(resolutions):

    with open(
        "resolutions.json",
        "w"
    ) as file:

        json.dump(
            resolutions,
            file,
            indent=2
        )


@app.get("/")
def home():

    return {
        "message":
        "GSA Governance Server Running"
    }


@app.get("/members")
def get_members():

    return load_members()


@app.post("/members")
def add_member(data: dict):

    members = load_members()

    members.append({

        "name":
        data.get("name"),

        "phoneNumber":
        data.get("phoneNumber"),

        "password":
        data.get("password"),

        "accessRole":
        data.get("accessRole"),
    })

    save_members(members)

    return {
        "success": True
    }

@app.get("/notices")
def get_notices():

    return load_notices()


@app.post("/notices")
def add_notice(data: dict):

    notices = load_notices()

    notices.append({

        "title":
        data.get("title"),

        "message":
        data.get("message"),

        "priority":
        data.get("priority"),
    })

    save_notices(notices)

    return {
        "success": True
    }


@app.get("/meetings")
def get_meetings():

    return load_meetings()


@app.post("/meetings")
def add_meeting(data: dict):

    meetings = load_meetings()

    meetings.append({

        "title":
        data.get("title"),

        "date":
        data.get("date"),

        "venue":
        data.get("venue"),

        "type":
        data.get("type"),

        "status":
        data.get("status"),
    })

    save_meetings(meetings)

    return {
        "success": True
    }


@app.get("/resolutions")
def get_resolutions():

    return load_resolutions()


@app.post("/resolutions")
def add_resolution(data: dict):

    resolutions = load_resolutions()

    resolutions.append({

        "title":
        data.get("title"),

        "description":
        data.get("description"),

        "meetingTitle":
        data.get("meetingTitle"),

        "forVotes":
        data.get("forVotes", 0),

        "againstVotes":
        data.get("againstVotes", 0),

        "abstainVotes":
        data.get("abstainVotes", 0),

        "votedMembers":
        data.get("votedMembers", []),

        "status":
        data.get("status",),
    })

    save_resolutions(resolutions)

    return {
        "success": True
    }


@app.post("/login")
def login(data: dict):

    members = load_members()

    phoneNumber = data.get(
        "phoneNumber"
    )

    password = data.get(
        "password"
    )

    for member in members:

        if (

            member["phoneNumber"]
            == phoneNumber

            and

            member["password"]
            == password
        ):

            return {

                "success": True,

                "member": member
            }

    return {
        "success": False
    }
