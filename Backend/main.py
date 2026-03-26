# NOTE: to run the swaggerUI we need to go to the localhost:http://127.0.0.1:8080/docs#/
from dotenv import load_dotenv
load_dotenv()

from StartingPackages import *
from routers import otp,user,auth,meal,analyse,bot,risk,notification
from fastapi.middleware.cors import CORSMiddleware


app = FastAPI()

# Create all tables
models.Base.metadata.create_all(bind=engine)

app.add_middleware(CORSMiddleware,allow_origins=["*"],allow_credentials=True,allow_methods=["GET","POST","OPTIONS","PUT","DELETE"],allow_headers=["*"])


app.include_router(auth.router)
app.include_router(user.router)
app.include_router(bot.router)
app.include_router(risk.router)
app.include_router(meal.router)
app.include_router(analyse.router)
app.include_router(otp.router)
app.include_router(notification.router)


# === Scheduler Startup ===
@app.on_event("startup")
async def startup_event():
    notification.logger.info("Application startup - Starting notification scheduler...")
    notification.scheduler.add_job(
        notification.send_reminders,
        notification.IntervalTrigger(minutes=notification.SCHEDULER_INTERVAL_MINUTES),
        id="send_reminders",
        replace_existing=True
    )
    notification.scheduler.start()
    notification.logger.info(f"Notification scheduler started (every {notification.SCHEDULER_INTERVAL_MINUTES} minutes)")


@app.on_event("shutdown")
async def shutdown_event():
    notification.logger.info("Application shutdown - Stopping scheduler...")
    if notification.scheduler.running:
        notification.scheduler.shutdown()
        notification.logger.info("Scheduler stopped")



