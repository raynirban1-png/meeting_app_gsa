from sqlalchemy import Column
from sqlalchemy import Integer
from sqlalchemy import String
from sqlalchemy import Text

from database import Base


class Member(Base):

    __tablename__ = "members"

    id = Column(
        Integer,
        primary_key=True,
        index=True,
    )

    name = Column(String)

    phoneNumber = Column(
        String,
        unique=True,
    )

    password = Column(String)

    accessRole = Column(String)


class Notice(Base):

    __tablename__ = "notices"

    id = Column(
        Integer,
        primary_key=True,
        index=True,
    )

    title = Column(String)

    message = Column(Text)

    priority = Column(String)


class Meeting(Base):

    __tablename__ = "meetings"

    id = Column(
        Integer,
        primary_key=True,
        index=True,
    )

    title = Column(String)

    date = Column(String)

    venue = Column(String)

    type = Column(String)

    status = Column(String)


class Resolution(Base):

    __tablename__ = "resolutions"

    id = Column(
        Integer,
        primary_key=True,
        index=True,
    )

    title = Column(String)

    description = Column(Text)

    meetingTitle = Column(String)

    forVotes = Column(Integer)

    againstVotes = Column(Integer)

    abstainVotes = Column(Integer)

    votedMembers = Column(Text)

    status = Column(String)


    class ActivityLog(Base):

    __tablename__ = "activity_logs"

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    action = Column(String)

    performedBy = Column(String)

    timestamp = Column(String)