from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import logging
import sys
import time
import httpx # We might need to install this if they want to call Spring Boot

# Configure logging to stdout
logging.basicConfig(
    level=logging.INFO,
    format="%(levelname)s:     %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger(__name__)

# Create FastAPI instance
app = FastAPI(title="Sri Lanka Disaster ML API")

# Simple middleware to log all requests
@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = (time.time() - start_time) * 1000
    # Log the full URL and status
    logger.info(f"Incoming: {request.method} {request.url} - Response Status: {response.status_code} - Time: {process_time:.2f}ms")
    return response

# Import and include routers independently
try:
    from app.routes.prediction_routes import router as prediction_router
    app.include_router(prediction_router, prefix="/predict")
    logger.info("Included prediction router")
except Exception:
    logger.exception("Error including prediction router")

try:
    from app.routes.cv_routes import router as cv_router
    app.include_router(cv_router, prefix="/cv")
    logger.info("Included CV router")
except Exception:
    logger.exception("Error including CV router")

try:
    from app.routes.vision_routes import router as vision_router
    app.include_router(vision_router, prefix="/api")
    logger.info("Included vision router at /api")
except Exception:
    logger.exception("Error including vision router")


# Root endpoint
@app.get("/")
def root():
    return {"message": "Sri Lanka Disaster ML API running"}

# Debug endpoint to list ALL routes
@app.get("/debug/routes")
def list_routes():
    routes = []
    for route in app.routes:
        methods = list(route.methods) if hasattr(route, "methods") else []
        routes.append({"path": route.path, "methods": methods})
    return {"routes": routes}

# Catch-all route to help diagnose 404s
@app.api_route("/{path_name:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH"])
async def catch_all(request: Request, path_name: str):
    logger.warning(f"CATCH-ALL: User requested {request.method} /{path_name} but no route was found.")
    
    # Dynamically gather available routes for the hint
    available_paths = []
    for route in app.routes:
        if hasattr(route, "path") and not route.path.startswith("/{path_name"):
            available_paths.append(route.path)
            
    return JSONResponse(
        status_code=404,
        content={
            "detail": f"Not Found: {request.method} /{path_name}",
            "hint": "Check /debug/routes for a full list of available endpoints.",
            "available_routes": sorted(list(set(available_paths)))
        }
    )
