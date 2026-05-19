from database import SessionLocal, engine
from models import Base, Member

def seed_data():
    # Create tables if they don't exist
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()

    # Check if admin already exists
    admin = db.query(Member).filter(Member.phoneNumber == "9999999999").first()

    if not admin:
        print("Seeding initial admin user...")
        new_admin = Member(
            name="Dr. Nirban Ray",
            phoneNumber="9999999999",
            password="admin123",
            accessRole="Admin"
        )
        db.add(new_admin)
        db.commit()
        print("Admin user created successfully!")
    else:
        print("Admin user already exists.")

    db.close()

if __name__ == "__main__":
    seed_data()
