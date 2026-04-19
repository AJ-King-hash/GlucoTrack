from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
# 1:24:00 ORM


# it is in built-in memory
SQLALCHAMY_DATABASE_URL="sqlite:///./HealthApp2.db"
engine=create_engine(SQLALCHAMY_DATABASE_URL,connect_args={"check_same_thread":False})




SessionLocal=sessionmaker(bind=engine,autocommit=False,autoflush=False)


Base=declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


""" 
from sqlmodel import SQLModel,create_engine

#MYSQL database connection 
mysql_username="root"
mysql_password=""
mysql_host="localhost"
mysql_port="3306"
mysql_database="healthApp"

mysql_url=f"mysql+mysqlconnection://{mysql_username}:{mysql_password}@{mysql_host}:{mysql_port}/{mysql_database}"

engine=create_engine(mysql_url,echo=True)
def get_db():
    SQLModel.metadata.create_all(engine)
"""