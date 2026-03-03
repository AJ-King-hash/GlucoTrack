# NOTE: to run the swaggerUI we need to go to the localhost:http://127.0.0.1:8080/docs#/
from StartingPackages import *
from routers import otp,user,auth,meal,analyse,bot,risk,notification



app = FastAPI()

# Create all tables
models.Base.metadata.create_all(bind=engine)



app.include_router(auth.router)
app.include_router(user.router)
app.include_router(bot.router)
app.include_router(risk.router)
app.include_router(meal.router)
app.include_router(analyse.router)
app.include_router(otp.router)
app.include_router(notification.router)




