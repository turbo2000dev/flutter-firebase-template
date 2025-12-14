"""
Firebase Cloud Functions for {{PROJECT_DISPLAY_NAME}}

This module contains the Cloud Functions entry points.
Add your functions here and they will be automatically deployed.
"""

from firebase_functions import https_fn, options
from firebase_admin import initialize_app

# Initialize Firebase Admin SDK
initialize_app()


@https_fn.on_request(
    cors=options.CorsOptions(
        cors_origins=["*"],
        cors_methods=["GET", "POST", "OPTIONS"],
    )
)
def hello_world(req: https_fn.Request) -> https_fn.Response:
    """
    Example Cloud Function.

    This is a simple hello world function to verify your setup works.
    Replace with your actual functions.

    Args:
        req: The HTTP request object.

    Returns:
        A JSON response with a greeting message.
    """
    return https_fn.Response(
        response='{"message": "Hello from {{PROJECT_DISPLAY_NAME}}!"}',
        status=200,
        headers={"Content-Type": "application/json"},
    )


# Add more functions below
# Example:
#
# @https_fn.on_request(cors=options.CorsOptions(cors_origins=["*"]))
# def my_function(req: https_fn.Request) -> https_fn.Response:
#     """Your function description."""
#     # Your implementation
#     pass
